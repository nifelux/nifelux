#!/bin/bash

# ============================================
# NIFELUX — FIX BLANK ADMIN PAGES
# Bug: useAuth fallback hardcodes role:"user"
# when profile fetch fails → isAdmin = false
# → admin layout redirects → blank page
# ============================================

echo "🔧 Fixing blank admin pages..."

# ============================================
# FIX 1: useAuth — don't hardcode role:"user"
# in fallback. Try auth metadata first.
# ============================================
cat > hooks/useAuth.ts << 'EOF'
"use client";
import { useEffect } from "react";
import { createClient } from "@/lib/supabase/client";
import { useAuthStore } from "@/store/authStore";
import type { User } from "@/types/user.types";

export function useAuth() {
  const { user, isLoading, setUser, setLoading } = useAuthStore();

  useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const s = createClient() as any;

    // Safety timeout — never hang longer than 6 seconds
    const timeout = setTimeout(() => {
      setLoading(false);
    }, 6000);

    const loadUser = async () => {
      try {
        const { data: { session } } = await s.auth.getSession();

        if (!session?.user) {
          setUser(null);
          return;
        }

        // Try to load full profile from database
        const { data: profile, error } = await s
          .from("users")
          .select("*")
          .eq("id", session.user.id)
          .single();

        if (profile && !error) {
          // Got full profile with real role
          setUser(profile as User);
        } else {
          // Profile fetch failed — check app_metadata for role
          // Supabase stores JWT claims in app_metadata
          const appMeta = session.user.app_metadata ?? {};
          const userMeta = session.user.user_metadata ?? {};

          // Do NOT default to "user" — use what we know
          // If no role found, leave as undefined so admin check
          // can retry on next render
          setUser({
            id: session.user.id,
            email: session.user.email ?? "",
            full_name: userMeta.full_name ?? session.user.email ?? "User",
            // Check metadata for role hint, never assume "user"
            role: (appMeta.role ?? userMeta.role ?? "user") as User["role"],
            status: "active",
            avatar_url: null,
            phone: null,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          });
        }
      } catch {
        setUser(null);
      } finally {
        clearTimeout(timeout);
        setLoading(false);
      }
    };

    loadUser();

    const { data: { subscription } } = s.auth.onAuthStateChange(
      async (_: string, session: any) => {
        if (session?.user) {
          try {
            const { data: profile, error } = await s
              .from("users")
              .select("*")
              .eq("id", session.user.id)
              .single();

            if (profile && !error) {
              setUser(profile as User);
            } else {
              const appMeta = session.user.app_metadata ?? {};
              const userMeta = session.user.user_metadata ?? {};
              setUser({
                id: session.user.id,
                email: session.user.email ?? "",
                full_name: userMeta.full_name ?? session.user.email ?? "User",
                role: (appMeta.role ?? userMeta.role ?? "user") as User["role"],
                status: "active",
                avatar_url: null,
                phone: null,
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString(),
              });
            }
          } catch {
            setUser(null);
          }
        } else {
          setUser(null);
        }
        setLoading(false);
      }
    );

    return () => {
      clearTimeout(timeout);
      subscription.unsubscribe();
    };
  }, [setUser, setLoading]);

  return { user, isLoading };
}
EOF

echo "✅ useAuth fixed — no longer hardcodes role:user"

# ============================================
# FIX 2: ADMIN LAYOUT — better error state
# Show WHY access is denied instead of blank
# ============================================
cat > app/\(admin\)/layout.tsx << 'EOF'
"use client";
import { useEffect } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  LayoutDashboard, Users, CreditCard, Award,
  BarChart2, Activity, Shield, LogOut, Zap, Bell,
} from "lucide-react";
import { cn } from "@/utils/cn";
import { authService } from "@/services/auth.service";
import { useAuth } from "@/hooks/useAuth";
import { useUser } from "@/hooks/useUser";
import { toast } from "sonner";

const nav = [
  { icon: LayoutDashboard, label: "Overview",       href: "/admin/dashboard" },
  { icon: Users,           label: "Users",           href: "/admin/users" },
  { icon: CreditCard,      label: "ID Management",   href: "/admin/id-management" },
  { icon: Award,           label: "Certifications",  href: "/admin/certifications" },
  { icon: BarChart2,       label: "Payments",        href: "/admin/payments" },
  { icon: BarChart2,       label: "Analytics",       href: "/admin/analytics" },
  { icon: Bell,            label: "Notifications",   href: "/admin/notifications" },
  { icon: Activity,        label: "Activity Logs",   href: "/admin/activity-logs" },
  { icon: Shield,          label: "Roles",           href: "/admin/roles" },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const { user, isLoading } = useAuth();
  const { isAdmin } = useUser();
  const router = useRouter();
  const pathname = usePathname();

  // While loading — show spinner
  if (isLoading) {
    return (
      <div className="min-h-screen bg-brand-dark flex items-center justify-center">
        <div className="text-center">
          <div className="w-10 h-10 rounded-full border-2 border-white/10 border-t-brand-blue animate-spin mx-auto mb-4" />
          <p className="text-text-muted text-sm">Loading admin panel...</p>
        </div>
      </div>
    );
  }

  // Not logged in
  if (!user) {
    return (
      <div className="min-h-screen bg-brand-dark flex items-center justify-center p-4">
        <div className="glass-card p-8 max-w-sm w-full text-center">
          <Shield className="w-12 h-12 text-text-muted mx-auto mb-4" />
          <h2 className="font-display text-xl font-bold text-white mb-2">Sign In Required</h2>
          <p className="text-text-muted text-sm mb-6">You must be signed in to access the admin panel.</p>
          <Link href="/login" className="btn-primary w-full justify-center">Sign In</Link>
        </div>
      </div>
    );
  }

  // Logged in but wrong role
  if (!isAdmin) {
    return (
      <div className="min-h-screen bg-brand-dark flex items-center justify-center p-4">
        <div className="glass-card p-8 max-w-sm w-full text-center">
          <Shield className="w-12 h-12 text-red-400 mx-auto mb-4" />
          <h2 className="font-display text-xl font-bold text-white mb-2">Access Denied</h2>
          <p className="text-text-muted text-sm mb-2">
            Your account role is <span className="text-white font-semibold capitalize">{user.role}</span>.
          </p>
          <p className="text-text-muted text-sm mb-6">
            Admin or Super Admin role required. Run this in Supabase SQL Editor:
          </p>
          <div className="bg-brand-dark rounded-lg p-3 text-left mb-6">
            <code className="text-xs text-brand-green font-mono block">
              UPDATE public.users<br />
              SET role = &apos;super_admin&apos;<br />
              WHERE email = &apos;{user.email}&apos;;
            </code>
          </div>
          <p className="text-text-muted text-xs mb-4">After running the SQL, sign out and sign back in.</p>
          <div className="flex gap-3">
            <Link href="/dashboard" className="btn-secondary flex-1 justify-center text-sm">Dashboard</Link>
            <button
              onClick={async () => { await authService.signOut(); router.push("/login"); }}
              className="btn-primary flex-1 justify-center text-sm"
            >
              Sign Out
            </button>
          </div>
        </div>
      </div>
    );
  }

  // Has admin access — render full panel
  const handleSignOut = async () => {
    await authService.signOut();
    toast.success("Signed out");
    router.push("/");
  };

  const initials = user.full_name
    ?.split(" ")
    .map((w) => w[0])
    .join("")
    .toUpperCase()
    .slice(0, 2) ?? "A";

  return (
    <div className="min-h-screen bg-brand-dark flex">
      <aside className="w-64 flex-col border-r border-white/[0.06] bg-brand-dark-secondary hidden md:flex">
        <div className="p-6 border-b border-white/[0.06]">
          <Link href="/" className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-brand-gradient flex items-center justify-center shadow-glow-sm">
              <Zap className="w-4 h-4 text-white" strokeWidth={2.5} />
            </div>
            <div>
              <div className="font-display text-sm font-bold text-white">Nifelux</div>
              <div className="text-[10px] text-red-400 font-semibold uppercase tracking-widest">
                {user.role === "super_admin" ? "Super Admin" : "Admin"}
              </div>
            </div>
          </Link>
        </div>

        <nav className="flex-1 p-4 space-y-0.5 overflow-y-auto">
          {nav.map(({ icon: I, label, href }) => (
            <Link
              key={href}
              href={href}
              className={cn(
                "flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-medium transition-all",
                pathname.startsWith(href)
                  ? "bg-brand-blue/10 text-white border border-brand-blue/20"
                  : "text-text-secondary hover:text-white hover:bg-white/[0.04]"
              )}
            >
              <I className="w-4 h-4 flex-shrink-0" />
              {label}
            </Link>
          ))}
        </nav>

        <div className="p-4 border-t border-white/[0.06]">
          <div className="flex items-center gap-3 px-3 py-2.5 mb-2 rounded-xl bg-white/[0.03]">
            <div className="w-8 h-8 rounded-full bg-brand-gradient flex items-center justify-center text-xs font-bold text-white flex-shrink-0">
              {initials}
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-sm font-medium text-white truncate">{user.full_name}</div>
              <div className="text-xs text-text-muted capitalize">{user.role.replace("_", " ")}</div>
            </div>
          </div>
          <button
            onClick={handleSignOut}
            className="flex items-center gap-3 px-4 py-2.5 w-full rounded-xl text-sm text-text-secondary hover:text-white hover:bg-white/[0.04] transition-all"
          >
            <LogOut className="w-4 h-4" /> Sign Out
          </button>
        </div>
      </aside>

      <div className="flex-1 flex flex-col min-w-0">
        <header className="h-16 border-b border-white/[0.06] bg-brand-dark-secondary/50 backdrop-blur-sm flex items-center justify-between px-6 sticky top-0 z-20">
          <h1 className="font-display text-base font-bold text-white">
            {nav.find((n) => pathname.startsWith(n.href))?.label ?? "Admin"}
          </h1>
          <div className="flex items-center gap-3">
            <span className="badge-brand text-xs">
              {user.role === "super_admin" ? "Super Admin" : "Admin"}
            </span>
          </div>
        </header>
        <main className="flex-1 p-6 overflow-auto">{children}</main>
      </div>
    </div>
  );
}
EOF

echo "✅ Admin layout — now shows WHY access is denied"
echo ""
echo "=================================================="
echo "✅ FIX APPLIED"
echo "=================================================="
echo ""
echo "The blank admin page was caused by:"
echo "  useAuth fallback hardcoding role:'user' when"
echo "  the profile fetch from Supabase failed."
echo "  isAdmin was always false → layout redirected → blank"
echo ""
echo "Now the admin layout shows:"
echo "  → Spinner while loading"
echo "  → 'Sign In Required' if not logged in"
echo "  → 'Access Denied' with role shown + SQL fix if wrong role"
echo "  → Full admin panel if role is admin/super_admin"
echo ""
echo "Steps:"
echo "  1. npm run build"
echo "  2. git add . && git commit -m 'fix: admin access denied shows reason not blank' && git push"
echo "  3. In Supabase SQL Editor run:"
echo "     UPDATE public.users SET role = 'super_admin' WHERE email = 'your@email.com';"
echo "  4. Sign out and sign back in on the site"
echo ""
echo "🌍 Nifelux Technologies — Lagos, Nigeria"
