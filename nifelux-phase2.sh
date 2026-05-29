#!/bin/bash
#!/bin/bash

# ============================================
# NIFELUX TECHNOLOGIES — PHASE 2
# Auth completion, QR system, Admin management
# Run from project ROOT (no src/)
# ============================================

echo ""
echo "🔐 Nifelux Phase 2 — Connecting the Platform..."
echo "=================================================="

# ============================================
# STEP 1: QR CODE GENERATOR
# ============================================
echo "🔳 Writing QR generator..."

cat > lib/qr/generator.ts << 'EOF'
import QRCode from "qrcode";

export async function generateQRCodeDataURL(text: string): Promise<string> {
  return await QRCode.toDataURL(text, {
    errorCorrectionLevel: "H",
    type: "image/png",
    margin: 1,
    color: { dark: "#000000", light: "#FFFFFF" },
    width: 300,
  });
}

export async function generateQRCodeSVG(text: string): Promise<string> {
  return await QRCode.toString(text, {
    type: "svg",
    errorCorrectionLevel: "H",
    margin: 1,
  });
}

export function buildVerifyUrl(token: string): string {
  const base = process.env.NEXT_PUBLIC_APP_URL || "https://nifelux.com";
  return `${base}/verify/${token}`;
}
EOF

echo "✅ QR generator written"

# ============================================
# STEP 2: NOTIFICATION SERVICE
# ============================================
echo "🔔 Writing notification service..."

cat > services/notification.service.ts << 'EOF'
import { createClient } from "@/lib/supabase/client";
import type { Notification } from "@/types/user.types";

export const notificationService = {
  async getMyNotifications(userId: string): Promise<Notification[]> {
    const s = createClient();
    const { data } = await s
      .from("notifications")
      .select("*")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(20);
    return (data ?? []) as Notification[];
  },

  async markAsRead(notificationId: string): Promise<void> {
    const s = createClient();
    await s.from("notifications").update({ read: true }).eq("id", notificationId);
  },

  async markAllAsRead(userId: string): Promise<void> {
    const s = createClient();
    await s.from("notifications").update({ read: true }).eq("user_id", userId).eq("read", false);
  },

  async getUnreadCount(userId: string): Promise<number> {
    const s = createClient();
    const { count } = await s
      .from("notifications")
      .select("*", { count: "exact", head: true })
      .eq("user_id", userId)
      .eq("read", false);
    return count ?? 0;
  },
};
EOF

# ============================================
# STEP 3: NOTIFICATION HOOK (REALTIME)
# ============================================
cat > hooks/useNotifications.ts << 'EOF'
"use client";
import { useEffect, useState, useCallback } from "react";
import { createClient } from "@/lib/supabase/client";
import { notificationService } from "@/services/notification.service";
import { useUser } from "@/hooks/useUser";
import type { Notification } from "@/types/user.types";

export function useNotifications() {
  const { user } = useUser();
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);

  const fetchNotifications = useCallback(async () => {
    if (!user) return;
    const data = await notificationService.getMyNotifications(user.id);
    setNotifications(data);
    setUnreadCount(data.filter((n) => !n.read).length);
  }, [user]);

  useEffect(() => {
    fetchNotifications();
  }, [fetchNotifications]);

  useEffect(() => {
    if (!user) return;
    const supabase = createClient();
    const channel = supabase
      .channel(`notifications:${user.id}`)
      .on("postgres_changes", {
        event: "INSERT",
        schema: "public",
        table: "notifications",
        filter: `user_id=eq.${user.id}`,
      }, (payload) => {
        setNotifications((prev) => [payload.new as Notification, ...prev]);
        setUnreadCount((prev) => prev + 1);
      })
      .subscribe();
    return () => { supabase.removeChannel(channel); };
  }, [user]);

  const markAsRead = async (id: string) => {
    await notificationService.markAsRead(id);
    setNotifications((prev) => prev.map((n) => n.id === id ? { ...n, read: true } : n));
    setUnreadCount((prev) => Math.max(0, prev - 1));
  };

  const markAllAsRead = async () => {
    if (!user) return;
    await notificationService.markAllAsRead(user.id);
    setNotifications((prev) => prev.map((n) => ({ ...n, read: true })));
    setUnreadCount(0);
  };

  return { notifications, unreadCount, markAsRead, markAllAsRead, refetch: fetchNotifications };
}
EOF

echo "✅ Notification service + hook written"

# ============================================
# STEP 4: NOTIFICATIONS API ROUTE
# ============================================
mkdir -p app/api/notifications

cat > app/api/notifications/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import type { ApiResponse } from "@/types/api.types";

export async function POST(request: NextRequest) {
  try {
    const supabase = await createAdminClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });

    const { data: profile } = await supabase.from("users").select("role").eq("id", user.id).single();
    if (!profile || !["admin", "super_admin"].includes(profile.role)) {
      return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });
    }

    const { user_ids, title, body, type = "info" } = await request.json();
    if (!title || !body) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Missing title or body" }, { status: 400 });

    const rows = (user_ids as string[]).map((uid: string) => ({ user_id: uid, title, body, type }));
    const { error } = await supabase.from("notifications").insert(rows);
    if (error) throw error;

    return NextResponse.json<ApiResponse<{ sent: number }>>({ success: true, data: { sent: rows.length }, message: "Notifications sent" });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to send" }, { status: 500 });
  }
}
EOF

echo "✅ Notifications API written"

# ============================================
# STEP 5: NOTIFICATION BELL COMPONENT
# ============================================
cat > components/common/NotificationBell.tsx << 'EOF'
"use client";
import { useState, useRef, useEffect } from "react";
import { Bell, CheckCheck, X } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { useNotifications } from "@/hooks/useNotifications";
import { cn } from "@/utils/cn";

function timeAgo(date: string): string {
  const diff = Date.now() - new Date(date).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return "just now";
  if (mins < 60) return `${mins}m ago`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h ago`;
  return `${Math.floor(hrs / 24)}d ago`;
}

const typeColors: Record<string, string> = {
  info: "bg-brand-blue/10 text-brand-blue-light border-brand-blue/20",
  success: "bg-brand-green/10 text-brand-green border-brand-green/20",
  warning: "bg-yellow-500/10 text-yellow-400 border-yellow-500/20",
  alert: "bg-red-500/10 text-red-400 border-red-500/20",
};

export default function NotificationBell() {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const { notifications, unreadCount, markAsRead, markAllAsRead } = useNotifications();

  useEffect(() => {
    const handler = (e: MouseEvent) => { if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false); };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  return (
    <div className="relative" ref={ref}>
      <button
        onClick={() => setOpen(!open)}
        className="relative w-9 h-9 rounded-lg glass flex items-center justify-center text-text-muted hover:text-white transition-colors"
      >
        <Bell className="w-4 h-4" />
        {unreadCount > 0 && (
          <span className="absolute -top-0.5 -right-0.5 w-4 h-4 rounded-full bg-brand-blue text-white text-[10px] font-bold flex items-center justify-center">
            {unreadCount > 9 ? "9+" : unreadCount}
          </span>
        )}
      </button>

      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, y: 8, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 8, scale: 0.95 }}
            transition={{ duration: 0.15 }}
            className="absolute right-0 top-12 w-80 glass-card border border-white/[0.08] shadow-card-hover z-50 overflow-hidden"
          >
            {/* Header */}
            <div className="flex items-center justify-between px-4 py-3 border-b border-white/[0.06]">
              <span className="text-sm font-semibold text-white">Notifications</span>
              <div className="flex items-center gap-2">
                {unreadCount > 0 && (
                  <button onClick={markAllAsRead} className="text-xs text-brand-blue-light hover:text-white transition-colors flex items-center gap-1">
                    <CheckCheck className="w-3.5 h-3.5" /> Mark all read
                  </button>
                )}
                <button onClick={() => setOpen(false)} className="text-text-muted hover:text-white transition-colors">
                  <X className="w-4 h-4" />
                </button>
              </div>
            </div>

            {/* List */}
            <div className="max-h-80 overflow-y-auto">
              {notifications.length === 0 ? (
                <div className="py-10 text-center">
                  <Bell className="w-8 h-8 text-text-muted mx-auto mb-2" />
                  <p className="text-text-muted text-sm">No notifications yet</p>
                </div>
              ) : (
                notifications.map((n) => (
                  <button
                    key={n.id}
                    onClick={() => !n.read && markAsRead(n.id)}
                    className={cn(
                      "w-full text-left px-4 py-3 border-b border-white/[0.04] hover:bg-white/[0.03] transition-colors",
                      !n.read && "bg-brand-blue/[0.04]"
                    )}
                  >
                    <div className="flex items-start gap-3">
                      <span className={cn("mt-0.5 text-[10px] px-1.5 py-0.5 rounded border font-semibold uppercase", typeColors[n.type])}>{n.type}</span>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-medium text-white truncate">{n.title}</p>
                        <p className="text-xs text-text-muted mt-0.5 leading-relaxed">{n.body}</p>
                        <p className="text-[10px] text-text-accent mt-1">{timeAgo(n.created_at)}</p>
                      </div>
                      {!n.read && <span className="w-1.5 h-1.5 rounded-full bg-brand-blue flex-shrink-0 mt-1.5" />}
                    </div>
                  </button>
                ))
              )}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
EOF

echo "✅ NotificationBell component written"

# ============================================
# STEP 6: UPDATED DASHBOARD LAYOUT WITH BELL
# ============================================
cat > app/\(dashboard\)/layout.tsx << 'EOF'
"use client";
import { useEffect } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { LayoutDashboard, CreditCard, Award, LogOut, Zap, Settings, Menu } from "lucide-react";
import { cn } from "@/utils/cn";
import { authService } from "@/services/auth.service";
import { useAuth } from "@/hooks/useAuth";
import { toast } from "sonner";
import LoadingSpinner from "@/components/common/LoadingSpinner";
import NotificationBell from "@/components/common/NotificationBell";

const nav = [
  { icon: LayoutDashboard, label: "Dashboard", href: "/dashboard" },
  { icon: CreditCard, label: "My ID Card", href: "/id-card" },
  { icon: Award, label: "Certifications", href: "/dashboard/certifications" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { user, isLoading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    if (!isLoading && !user) router.replace("/login");
  }, [user, isLoading, router]);

  if (isLoading) return <div className="min-h-screen bg-brand-dark flex items-center justify-center"><LoadingSpinner size="lg" /></div>;
  if (!user) return null;

  const handleSignOut = async () => {
    await authService.signOut();
    toast.success("Signed out");
    router.push("/");
  };

  const initials = user.full_name?.split(" ").map((w) => w[0]).join("").toUpperCase().slice(0, 2) ?? "N";

  return (
    <div className="min-h-screen bg-brand-dark flex">
      {/* Sidebar */}
      <aside className="hidden md:flex w-64 flex-col border-r border-white/[0.06] bg-brand-dark-secondary">
        <div className="p-6 border-b border-white/[0.06]">
          <Link href="/" className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-brand-gradient flex items-center justify-center shadow-glow-sm">
              <Zap className="w-4 h-4 text-white" strokeWidth={2.5} />
            </div>
            <div className="flex flex-col leading-none">
              <span className="font-display text-base font-bold text-white">Nifelux</span>
              <span className="text-[10px] text-text-muted tracking-widest uppercase">Portal</span>
            </div>
          </Link>
        </div>

        <nav className="flex-1 p-4 space-y-1">
          {nav.map(({ icon: I, label, href }) => {
            const active = pathname === href;
            return (
              <Link key={href} href={href}
                className={cn("flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all",
                  active ? "bg-brand-blue/10 text-white border border-brand-blue/20" : "text-text-secondary hover:text-white hover:bg-white/[0.04]")}>
                <I className="w-4 h-4" />
                {label}
              </Link>
            );
          })}
        </nav>

        <div className="p-4 border-t border-white/[0.06]">
          <div className="flex items-center gap-3 px-3 py-2.5 mb-2 rounded-xl bg-white/[0.03]">
            <div className="w-8 h-8 rounded-full bg-brand-gradient flex items-center justify-center text-xs font-bold text-white flex-shrink-0">{initials}</div>
            <div className="flex-1 min-w-0">
              <div className="text-sm font-medium text-white truncate">{user.full_name}</div>
              <div className="text-xs text-text-muted capitalize">{user.role}</div>
            </div>
          </div>
          <button onClick={handleSignOut}
            className="flex items-center gap-3 px-4 py-2.5 w-full rounded-xl text-sm text-text-secondary hover:text-white hover:bg-white/[0.04] transition-all">
            <LogOut className="w-4 h-4" /> Sign Out
          </button>
        </div>
      </aside>

      {/* Main */}
      <div className="flex-1 flex flex-col min-w-0">
        <header className="h-16 border-b border-white/[0.06] bg-brand-dark-secondary/50 backdrop-blur-sm flex items-center justify-between px-6 sticky top-0 z-20">
          <h1 className="font-display text-base font-bold text-white">
            {nav.find((n) => n.href === pathname)?.label ?? "Dashboard"}
          </h1>
          <div className="flex items-center gap-3">
            <NotificationBell />
            <div className="w-8 h-8 rounded-full bg-brand-gradient flex items-center justify-center text-xs font-bold text-white">{initials}</div>
          </div>
        </header>

        <main className="flex-1 p-6 overflow-auto">{children}</main>
      </div>
    </div>
  );
}
EOF

echo "✅ Dashboard layout updated with NotificationBell"

# ============================================
# STEP 7: USER SETTINGS PAGE
# ============================================
echo "⚙️  Writing user settings page..."

mkdir -p app/\(dashboard\)/dashboard/settings

cat > app/\(dashboard\)/dashboard/settings/page.tsx << 'EOF'
"use client";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { User, Mail, Phone, Save, Shield, Eye, EyeOff } from "lucide-react";
import { toast } from "sonner";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import { useUser } from "@/hooks/useUser";
import { userService } from "@/services/user.service";
import { createClient } from "@/lib/supabase/client";

const profileSchema = z.object({
  full_name: z.string().min(2, "Min 2 characters"),
  phone: z.string().optional(),
});

const passwordSchema = z.object({
  current_password: z.string().min(6),
  new_password: z.string().min(8, "Min 8 characters").regex(/[A-Z]/, "Need uppercase").regex(/[0-9]/, "Need number"),
  confirm_password: z.string(),
}).refine((d) => d.new_password === d.confirm_password, { message: "Passwords do not match", path: ["confirm_password"] });

type ProfileForm = z.infer<typeof profileSchema>;
type PasswordForm = z.infer<typeof passwordSchema>;

export default function SettingsPage() {
  const { user } = useUser();
  const [showPw, setShowPw] = useState(false);
  const [showNew, setShowNew] = useState(false);

  const profileForm = useForm<ProfileForm>({
    resolver: zodResolver(profileSchema),
    defaultValues: { full_name: user?.full_name ?? "", phone: user?.phone ?? "" },
  });

  const passwordForm = useForm<PasswordForm>({ resolver: zodResolver(passwordSchema) });

  const onProfileSubmit = async (data: ProfileForm) => {
    if (!user) return;
    try {
      await userService.updateProfile(user.id, data);
      toast.success("Profile updated");
    } catch {
      toast.error("Failed to update profile");
    }
  };

  const onPasswordSubmit = async (data: PasswordForm) => {
    try {
      const supabase = createClient();
      const { error } = await supabase.auth.updateUser({ password: data.new_password });
      if (error) throw error;
      toast.success("Password updated");
      passwordForm.reset();
    } catch {
      toast.error("Failed to update password");
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-8">
      <div>
        <h2 className="font-display text-2xl font-bold text-white mb-1">Settings</h2>
        <p className="text-text-muted text-sm">Manage your account preferences.</p>
      </div>

      {/* Profile */}
      <GlassCard className="p-6 border border-white/[0.05]">
        <div className="flex items-center gap-3 mb-6">
          <div className="w-9 h-9 rounded-xl bg-brand-blue/10 flex items-center justify-center"><User className="w-4.5 h-4.5 text-brand-blue-light" /></div>
          <div>
            <h3 className="font-display text-base font-bold text-white">Profile</h3>
            <p className="text-text-muted text-xs">Update your name and phone number.</p>
          </div>
        </div>

        <form onSubmit={profileForm.handleSubmit(onProfileSubmit)} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Full Name</label>
            <input {...profileForm.register("full_name")} className="input-brand" placeholder="Your full name" />
            {profileForm.formState.errors.full_name && <p className="mt-1.5 text-xs text-red-400">{profileForm.formState.errors.full_name.message}</p>}
          </div>
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Email Address</label>
            <div className="relative">
              <input value={user?.email ?? ""} readOnly className="input-brand opacity-50 cursor-not-allowed pr-10" />
              <Mail className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            </div>
            <p className="mt-1 text-xs text-text-muted">Email cannot be changed.</p>
          </div>
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Phone Number</label>
            <div className="relative">
              <input {...profileForm.register("phone")} className="input-brand pr-10" placeholder="+234 800 000 0000" />
              <Phone className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            </div>
          </div>
          <GradientButton type="submit" variant="blue-purple" size="md" loading={profileForm.formState.isSubmitting}
            icon={<Save className="w-4 h-4" />}>
            Save Profile
          </GradientButton>
        </form>
      </GlassCard>

      {/* Password */}
      <GlassCard className="p-6 border border-white/[0.05]">
        <div className="flex items-center gap-3 mb-6">
          <div className="w-9 h-9 rounded-xl bg-brand-purple/10 flex items-center justify-center"><Shield className="w-4.5 h-4.5 text-brand-purple-light" /></div>
          <div>
            <h3 className="font-display text-base font-bold text-white">Password</h3>
            <p className="text-text-muted text-xs">Change your account password.</p>
          </div>
        </div>

        <form onSubmit={passwordForm.handleSubmit(onPasswordSubmit)} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Current Password</label>
            <div className="relative">
              <input {...passwordForm.register("current_password")} type={showPw ? "text" : "password"} className="input-brand pr-10" placeholder="••••••••" />
              <button type="button" onClick={() => setShowPw(!showPw)} className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted hover:text-white transition-colors">
                {showPw ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
          </div>
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">New Password</label>
            <div className="relative">
              <input {...passwordForm.register("new_password")} type={showNew ? "text" : "password"} className="input-brand pr-10" placeholder="Min 8 chars, 1 uppercase, 1 number" />
              <button type="button" onClick={() => setShowNew(!showNew)} className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted hover:text-white transition-colors">
                {showNew ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
            {passwordForm.formState.errors.new_password && <p className="mt-1.5 text-xs text-red-400">{passwordForm.formState.errors.new_password.message}</p>}
          </div>
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Confirm New Password</label>
            <input {...passwordForm.register("confirm_password")} type="password" className="input-brand" placeholder="••••••••" />
            {passwordForm.formState.errors.confirm_password && <p className="mt-1.5 text-xs text-red-400">{passwordForm.formState.errors.confirm_password.message}</p>}
          </div>
          <GradientButton type="submit" variant="blue-purple" size="md" loading={passwordForm.formState.isSubmitting}
            icon={<Shield className="w-4 h-4" />}>
            Update Password
          </GradientButton>
        </form>
      </GlassCard>

      {/* Account Info */}
      <GlassCard className="p-6 border border-white/[0.05]">
        <h3 className="font-display text-base font-bold text-white mb-4">Account Information</h3>
        <div className="space-y-3">
          {[
            { label: "User ID", value: user?.id?.slice(0, 8) + "..." },
            { label: "Role", value: user?.role, capitalize: true },
            { label: "Status", value: user?.status, capitalize: true },
            { label: "Member Since", value: user?.created_at ? new Date(user.created_at).toLocaleDateString("en-NG", { year: "numeric", month: "long", day: "numeric" }) : "—" },
          ].map(({ label, value, capitalize }) => (
            <div key={label} className="flex items-center justify-between py-2.5 border-b border-white/[0.04] last:border-0">
              <span className="text-sm text-text-muted">{label}</span>
              <span className={`text-sm text-white font-medium ${capitalize ? "capitalize" : ""}`}>{value}</span>
            </div>
          ))}
        </div>
      </GlassCard>
    </div>
  );
}
EOF

echo "✅ Settings page written"

# ============================================
# STEP 8: FORGOT / RESET PASSWORD
# ============================================
echo "🔑 Writing password reset pages..."

mkdir -p app/\(auth\)/forgot-password
mkdir -p app/\(auth\)/reset-password

cat > app/\(auth\)/forgot-password/page.tsx << 'EOF'
"use client";
import { useState } from "react";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Zap, Send, ArrowLeft } from "lucide-react";
import { toast } from "sonner";
import { authService } from "@/services/auth.service";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";

const schema = z.object({ email: z.string().email("Invalid email address") });
type Form = z.infer<typeof schema>;

export default function ForgotPasswordPage() {
  const [sent, setSent] = useState(false);
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<Form>({ resolver: zodResolver(schema) });

  const onSubmit = async (data: Form) => {
    try {
      await authService.resetPassword(data.email);
      setSent(true);
    } catch {
      toast.error("Failed to send reset email. Please try again.");
    }
  };

  return (
    <GlassCard variant="gradient" className="p-8 border border-white/[0.06]">
      <div className="flex items-center gap-3 mb-8">
        <div className="w-10 h-10 rounded-xl bg-brand-gradient flex items-center justify-center shadow-glow-sm"><Zap className="w-5 h-5 text-white" strokeWidth={2.5} /></div>
        <div><div className="font-display text-lg font-bold text-white">Reset Password</div><div className="text-xs text-text-muted">We&apos;ll send you a reset link</div></div>
      </div>

      {sent ? (
        <div className="text-center py-4">
          <div className="w-14 h-14 rounded-2xl bg-brand-green/10 border border-brand-green/20 flex items-center justify-center mx-auto mb-4">
            <Send className="w-7 h-7 text-brand-green" />
          </div>
          <h3 className="font-display text-lg font-bold text-white mb-2">Check your inbox</h3>
          <p className="text-text-muted text-sm mb-6">A password reset link has been sent to your email address.</p>
          <Link href="/login" className="text-sm text-brand-blue-light hover:text-white transition-colors">Back to sign in</Link>
        </div>
      ) : (
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Email Address</label>
            <input {...register("email")} type="email" placeholder="you@email.com" className="input-brand" />
            {errors.email && <p className="mt-1.5 text-xs text-red-400">{errors.email.message}</p>}
          </div>
          <GradientButton type="submit" variant="blue-purple" size="md" fullWidth loading={isSubmitting} icon={<Send className="w-4 h-4" />}>
            {isSubmitting ? "Sending..." : "Send Reset Link"}
          </GradientButton>
        </form>
      )}

      <div className="mt-6 text-center">
        <Link href="/login" className="text-sm text-text-muted hover:text-white transition-colors flex items-center justify-center gap-1.5">
          <ArrowLeft className="w-3.5 h-3.5" /> Back to sign in
        </Link>
      </div>
    </GlassCard>
  );
}
EOF

cat > app/\(auth\)/reset-password/page.tsx << 'EOF'
"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Zap, Eye, EyeOff, Check } from "lucide-react";
import { toast } from "sonner";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";

const schema = z.object({
  password: z.string().min(8, "Min 8 characters").regex(/[A-Z]/, "Need uppercase").regex(/[0-9]/, "Need number"),
  confirm: z.string(),
}).refine((d) => d.password === d.confirm, { message: "Passwords do not match", path: ["confirm"] });

type Form = z.infer<typeof schema>;

export default function ResetPasswordPage() {
  const [show, setShow] = useState(false);
  const [done, setDone] = useState(false);
  const router = useRouter();
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<Form>({ resolver: zodResolver(schema) });

  const onSubmit = async (data: Form) => {
    try {
      const supabase = createClient();
      const { error } = await supabase.auth.updateUser({ password: data.password });
      if (error) throw error;
      setDone(true);
      setTimeout(() => router.push("/login"), 2000);
    } catch {
      toast.error("Failed to reset password. The link may have expired.");
    }
  };

  return (
    <GlassCard variant="gradient" className="p-8 border border-white/[0.06]">
      <div className="flex items-center gap-3 mb-8">
        <div className="w-10 h-10 rounded-xl bg-brand-gradient flex items-center justify-center shadow-glow-sm"><Zap className="w-5 h-5 text-white" strokeWidth={2.5} /></div>
        <div><div className="font-display text-lg font-bold text-white">New Password</div><div className="text-xs text-text-muted">Set a strong new password</div></div>
      </div>

      {done ? (
        <div className="text-center py-4">
          <div className="w-14 h-14 rounded-2xl bg-brand-green/10 border border-brand-green/20 flex items-center justify-center mx-auto mb-4"><Check className="w-7 h-7 text-brand-green" /></div>
          <h3 className="font-display text-lg font-bold text-white mb-2">Password Updated!</h3>
          <p className="text-text-muted text-sm">Redirecting you to sign in...</p>
        </div>
      ) : (
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">New Password</label>
            <div className="relative">
              <input {...register("password")} type={show ? "text" : "password"} placeholder="Min 8 chars, 1 uppercase, 1 number" className="input-brand pr-10" />
              <button type="button" onClick={() => setShow(!show)} className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted hover:text-white transition-colors">
                {show ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
            {errors.password && <p className="mt-1.5 text-xs text-red-400">{errors.password.message}</p>}
          </div>
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Confirm Password</label>
            <input {...register("confirm")} type="password" placeholder="••••••••" className="input-brand" />
            {errors.confirm && <p className="mt-1.5 text-xs text-red-400">{errors.confirm.message}</p>}
          </div>
          <GradientButton type="submit" variant="blue-purple" size="md" fullWidth loading={isSubmitting}>
            {isSubmitting ? "Updating..." : "Update Password"}
          </GradientButton>
        </form>
      )}
    </GlassCard>
  );
}
EOF

echo "✅ Password reset pages written"

# ============================================
# STEP 9: ADMIN USERS PAGE (FULL)
# ============================================
echo "👥 Writing admin users page..."

cat > app/\(admin\)/admin/users/page.tsx << 'EOF'
"use client";
import { useEffect, useState, useCallback } from "react";
import { Search, UserCog, Ban, CheckCircle, ChevronDown } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import { toast } from "sonner";
import type { User, UserRole } from "@/types/user.types";
import { formatDate } from "@/utils/format";

const ROLES: UserRole[] = ["user", "staff", "admin", "super_admin"];
const roleBadge: Record<string, string> = {
  user: "bg-white/[0.05] text-text-muted",
  staff: "bg-brand-blue/10 text-brand-blue-light",
  admin: "bg-brand-purple/10 text-brand-purple-light",
  super_admin: "bg-brand-green/10 text-brand-green",
};

export default function AdminUsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [editingRole, setEditingRole] = useState<string | null>(null);

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    const s = createClient();
    const { data } = await s.from("users").select("*").order("created_at", { ascending: false });
    setUsers((data ?? []) as User[]);
    setLoading(false);
  }, []);

  useEffect(() => { fetchUsers(); }, [fetchUsers]);

  const updateRole = async (userId: string, role: UserRole) => {
    const s = createClient();
    const { error } = await s.from("users").update({ role }).eq("id", userId);
    if (error) { toast.error("Failed to update role"); return; }
    setUsers((prev) => prev.map((u) => u.id === userId ? { ...u, role } : u));
    setEditingRole(null);
    toast.success("Role updated");
  };

  const toggleStatus = async (user: User) => {
    const newStatus = user.status === "active" ? "suspended" : "active";
    const s = createClient();
    const { error } = await s.from("users").update({ status: newStatus }).eq("id", user.id);
    if (error) { toast.error("Failed to update status"); return; }
    setUsers((prev) => prev.map((u) => u.id === user.id ? { ...u, status: newStatus } : u));
    toast.success(`User ${newStatus}`);
  };

  const filtered = users.filter((u) =>
    u.full_name.toLowerCase().includes(search.toLowerCase()) ||
    u.email.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="font-display text-2xl font-bold text-white mb-1">Users</h2>
          <p className="text-text-muted text-sm">{users.length} total users</p>
        </div>
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search users..."
            className="input-brand pl-9 w-64"
          />
        </div>
      </div>

      <GlassCard className="border border-white/[0.05] overflow-hidden">
        {loading ? (
          <div className="p-12 text-center text-text-muted text-sm">Loading users...</div>
        ) : filtered.length === 0 ? (
          <div className="p-12 text-center text-text-muted text-sm">No users found</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/[0.06]">
                  {["User", "Role", "Status", "Joined", "Actions"].map((h) => (
                    <th key={h} className="text-left px-5 py-3.5 text-xs font-semibold text-text-muted uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((user) => (
                  <tr key={user.id} className="border-b border-white/[0.04] hover:bg-white/[0.02] transition-colors">
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-brand-gradient flex items-center justify-center text-xs font-bold text-white flex-shrink-0">
                          {user.full_name?.[0]?.toUpperCase() ?? "N"}
                        </div>
                        <div>
                          <div className="text-sm font-medium text-white">{user.full_name}</div>
                          <div className="text-xs text-text-muted">{user.email}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-5 py-4">
                      <div className="relative">
                        <button
                          onClick={() => setEditingRole(editingRole === user.id ? null : user.id)}
                          className={`flex items-center gap-1.5 text-xs font-semibold px-2.5 py-1 rounded-full capitalize ${roleBadge[user.role]}`}
                        >
                          {user.role.replace("_", " ")}
                          <ChevronDown className="w-3 h-3" />
                        </button>
                        {editingRole === user.id && (
                          <div className="absolute top-8 left-0 z-10 w-36 glass-card border border-white/[0.08] shadow-card-hover overflow-hidden">
                            {ROLES.map((r) => (
                              <button
                                key={r}
                                onClick={() => updateRole(user.id, r)}
                                className={`w-full text-left px-3 py-2.5 text-xs font-medium capitalize hover:bg-white/[0.06] transition-colors ${user.role === r ? "text-brand-blue-light" : "text-text-secondary"}`}
                              >
                                {r.replace("_", " ")}
                              </button>
                            ))}
                          </div>
                        )}
                      </div>
                    </td>
                    <td className="px-5 py-4">
                      <span className={`text-xs px-2.5 py-1 rounded-full font-semibold capitalize ${user.status === "active" ? "bg-brand-green/10 text-brand-green" : "bg-red-500/10 text-red-400"}`}>
                        {user.status}
                      </span>
                    </td>
                    <td className="px-5 py-4">
                      <span className="text-xs text-text-muted">{formatDate(user.created_at)}</span>
                    </td>
                    <td className="px-5 py-4">
                      <button
                        onClick={() => toggleStatus(user)}
                        className="flex items-center gap-1.5 text-xs text-text-muted hover:text-white transition-colors"
                      >
                        {user.status === "active" ? <><Ban className="w-3.5 h-3.5 text-red-400" /> Suspend</> : <><CheckCircle className="w-3.5 h-3.5 text-brand-green" /> Activate</>}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </GlassCard>
    </div>
  );
}
EOF

echo "✅ Admin users page written"

# ============================================
# STEP 10: ADMIN ID MANAGEMENT (FULL)
# ============================================
echo "🪪 Writing admin ID management page..."

cat > app/\(admin\)/admin/id-management/page.tsx << 'EOF'
"use client";
import { useEffect, useState, useCallback } from "react";
import { CreditCard, Plus, Search, Ban, RefreshCw, QrCode } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import { toast } from "sonner";
import { formatDate } from "@/utils/format";

interface IdRecord {
  id: string;
  id_number: string;
  status: "active" | "expired" | "revoked";
  issued_at: string;
  expires_at: string;
  user_id: string;
  users: { full_name: string; email: string };
}

export default function IdManagementPage() {
  const [ids, setIds] = useState<IdRecord[]>([]);
  const [users, setUsers] = useState<{ id: string; full_name: string; email: string }[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [issuing, setIssuing] = useState(false);
  const [selectedUser, setSelectedUser] = useState("");

  const fetchIds = useCallback(async () => {
    setLoading(true);
    const s = createClient();
    const { data } = await s.from("digital_ids").select("*, users(full_name, email)").order("issued_at", { ascending: false });
    setIds((data ?? []) as IdRecord[]);
    setLoading(false);
  }, []);

  const fetchUsers = useCallback(async () => {
    const s = createClient();
    const { data } = await s.from("users").select("id, full_name, email").order("full_name");
    setUsers(data ?? []);
  }, []);

  useEffect(() => { fetchIds(); fetchUsers(); }, [fetchIds, fetchUsers]);

  const issueId = async () => {
    if (!selectedUser) { toast.error("Select a user first"); return; }
    setIssuing(true);
    try {
      const res = await fetch("/api/id", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ target_user_id: selectedUser }) });
      const json = await res.json();
      if (!json.success) throw new Error(json.error);
      toast.success("Digital ID issued successfully");
      setSelectedUser("");
      fetchIds();
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : "Failed to issue ID");
    } finally {
      setIssuing(false);
    }
  };

  const revokeId = async (id: string) => {
    const s = createClient();
    const { error } = await s.from("digital_ids").update({ status: "revoked" }).eq("id", id);
    if (error) { toast.error("Failed to revoke"); return; }
    setIds((prev) => prev.map((i) => i.id === id ? { ...i, status: "revoked" } : i));
    toast.success("ID revoked");
  };

  const filtered = ids.filter((i) =>
    i.users?.full_name?.toLowerCase().includes(search.toLowerCase()) ||
    i.id_number.toLowerCase().includes(search.toLowerCase())
  );

  const statusBadge: Record<string, string> = {
    active: "bg-brand-green/10 text-brand-green",
    expired: "bg-yellow-500/10 text-yellow-400",
    revoked: "bg-red-500/10 text-red-400",
  };

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div>
        <h2 className="font-display text-2xl font-bold text-white mb-1">ID Management</h2>
        <p className="text-text-muted text-sm">{ids.length} digital IDs issued</p>
      </div>

      {/* Issue New ID */}
      <GlassCard className="p-6 border border-brand-blue/20 bg-brand-blue/5">
        <h3 className="font-display text-base font-bold text-white mb-4 flex items-center gap-2">
          <Plus className="w-4 h-4 text-brand-blue-light" /> Issue New Digital ID
        </h3>
        <div className="flex flex-col sm:flex-row gap-3">
          <select
            value={selectedUser}
            onChange={(e) => setSelectedUser(e.target.value)}
            className="input-brand flex-1"
          >
            <option value="">Select a user...</option>
            {users.map((u) => (
              <option key={u.id} value={u.id}>{u.full_name} — {u.email}</option>
            ))}
          </select>
          <GradientButton variant="blue-purple" size="md" onClick={issueId} loading={issuing} icon={<CreditCard className="w-4 h-4" />} iconPosition="left">
            Issue ID
          </GradientButton>
        </div>
      </GlassCard>

      {/* ID Table */}
      <GlassCard className="border border-white/[0.05] overflow-hidden">
        <div className="p-4 border-b border-white/[0.06] flex items-center justify-between gap-4">
          <div className="relative flex-1 max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search by name or ID..." className="input-brand pl-9" />
          </div>
          <button onClick={fetchIds} className="w-9 h-9 glass rounded-lg flex items-center justify-center text-text-muted hover:text-white transition-colors">
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>

        {loading ? (
          <div className="p-12 text-center text-text-muted text-sm">Loading IDs...</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/[0.06]">
                  {["User", "ID Number", "Status", "Issued", "Expires", "Actions"].map((h) => (
                    <th key={h} className="text-left px-5 py-3.5 text-xs font-semibold text-text-muted uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((item) => (
                  <tr key={item.id} className="border-b border-white/[0.04] hover:bg-white/[0.02] transition-colors">
                    <td className="px-5 py-4">
                      <div className="text-sm font-medium text-white">{item.users?.full_name}</div>
                      <div className="text-xs text-text-muted">{item.users?.email}</div>
                    </td>
                    <td className="px-5 py-4"><span className="font-mono text-xs text-white">{item.id_number}</span></td>
                    <td className="px-5 py-4"><span className={`text-xs px-2.5 py-1 rounded-full font-semibold capitalize ${statusBadge[item.status]}`}>{item.status}</span></td>
                    <td className="px-5 py-4"><span className="text-xs text-text-muted">{formatDate(item.issued_at)}</span></td>
                    <td className="px-5 py-4"><span className="text-xs text-text-muted">{formatDate(item.expires_at)}</span></td>
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-3">
                        <a href={`/verify/${item.id_number}`} target="_blank" rel="noopener noreferrer" className="text-xs text-text-muted hover:text-white transition-colors flex items-center gap-1">
                          <QrCode className="w-3.5 h-3.5" /> Verify
                        </a>
                        {item.status === "active" && (
                          <button onClick={() => revokeId(item.id)} className="text-xs text-red-400 hover:text-red-300 transition-colors flex items-center gap-1">
                            <Ban className="w-3.5 h-3.5" /> Revoke
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </GlassCard>
    </div>
  );
}
EOF

echo "✅ Admin ID management written"

# ============================================
# STEP 11: ADMIN CERTIFICATIONS (FULL)
# ============================================
echo "🏆 Writing admin certifications page..."

cat > app/\(admin\)/admin/certifications/page.tsx << 'EOF'
"use client";
import { useEffect, useState, useCallback } from "react";
import { Award, Plus, Search, RefreshCw, Ban, ExternalLink } from "lucide-react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import { toast } from "sonner";
import { formatDate } from "@/utils/format";

const issueSchema = z.object({
  target_user_id: z.string().min(1, "Select a user"),
  title: z.string().min(3, "Min 3 characters"),
  issued_by: z.string().min(2, "Min 2 characters"),
  description: z.string().optional(),
  expires_at: z.string().optional(),
});
type IssueForm = z.infer<typeof issueSchema>;

interface CertRecord {
  id: string;
  title: string;
  issued_by: string;
  verification_code: string;
  status: string;
  issued_at: string;
  expires_at?: string;
  users: { full_name: string; email: string };
}

export default function AdminCertificationsPage() {
  const [certs, setCerts] = useState<CertRecord[]>([]);
  const [users, setUsers] = useState<{ id: string; full_name: string; email: string }[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [showForm, setShowForm] = useState(false);

  const { register, handleSubmit, reset, formState: { errors, isSubmitting } } = useForm<IssueForm>({
    resolver: zodResolver(issueSchema),
    defaultValues: { issued_by: "Nifelux Technologies" },
  });

  const fetchCerts = useCallback(async () => {
    setLoading(true);
    const s = createClient();
    const { data } = await s.from("certifications").select("*, users(full_name, email)").order("issued_at", { ascending: false });
    setCerts((data ?? []) as CertRecord[]);
    setLoading(false);
  }, []);

  const fetchUsers = useCallback(async () => {
    const s = createClient();
    const { data } = await s.from("users").select("id, full_name, email").order("full_name");
    setUsers(data ?? []);
  }, []);

  useEffect(() => { fetchCerts(); fetchUsers(); }, [fetchCerts, fetchUsers]);

  const onSubmit = async (data: IssueForm) => {
    try {
      const res = await fetch("/api/certifications", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(data) });
      const json = await res.json();
      if (!json.success) throw new Error(json.error);
      toast.success("Certificate issued successfully");
      reset();
      setShowForm(false);
      fetchCerts();
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : "Failed to issue certificate");
    }
  };

  const revoke = async (id: string) => {
    const s = createClient();
    const { error } = await s.from("certifications").update({ status: "revoked" }).eq("id", id);
    if (error) { toast.error("Failed to revoke"); return; }
    setCerts((prev) => prev.map((c) => c.id === id ? { ...c, status: "revoked" } : c));
    toast.success("Certificate revoked");
  };

  const filtered = certs.filter((c) =>
    c.users?.full_name?.toLowerCase().includes(search.toLowerCase()) ||
    c.title.toLowerCase().includes(search.toLowerCase()) ||
    c.verification_code.toLowerCase().includes(search.toLowerCase())
  );

  const statusBadge: Record<string, string> = {
    active: "bg-brand-green/10 text-brand-green",
    expired: "bg-yellow-500/10 text-yellow-400",
    revoked: "bg-red-500/10 text-red-400",
  };

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-display text-2xl font-bold text-white mb-1">Certifications</h2>
          <p className="text-text-muted text-sm">{certs.length} certificates issued</p>
        </div>
        <GradientButton variant="blue-purple" size="sm" onClick={() => setShowForm(!showForm)} icon={<Plus className="w-4 h-4" />} iconPosition="left">
          Issue Certificate
        </GradientButton>
      </div>

      {/* Issue Form */}
      {showForm && (
        <GlassCard className="p-6 border border-brand-green/20 bg-brand-green/5">
          <h3 className="font-display text-base font-bold text-white mb-5 flex items-center gap-2">
            <Award className="w-4 h-4 text-brand-green" /> Issue New Certificate
          </h3>
          <form onSubmit={handleSubmit(onSubmit)} className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Recipient</label>
              <select {...register("target_user_id")} className="input-brand">
                <option value="">Select user...</option>
                {users.map((u) => <option key={u.id} value={u.id}>{u.full_name} — {u.email}</option>)}
              </select>
              {errors.target_user_id && <p className="mt-1.5 text-xs text-red-400">{errors.target_user_id.message}</p>}
            </div>
            <div>
              <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Certificate Title</label>
              <input {...register("title")} className="input-brand" placeholder="e.g. AI Fundamentals Certificate" />
              {errors.title && <p className="mt-1.5 text-xs text-red-400">{errors.title.message}</p>}
            </div>
            <div>
              <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Issued By</label>
              <input {...register("issued_by")} className="input-brand" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Expiry Date (Optional)</label>
              <input {...register("expires_at")} type="date" className="input-brand" />
            </div>
            <div className="sm:col-span-2">
              <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Description (Optional)</label>
              <textarea {...register("description")} rows={2} className="input-brand resize-none" placeholder="Brief description of the certification..." />
            </div>
            <div className="sm:col-span-2 flex gap-3">
              <GradientButton type="submit" variant="green-blue" size="md" loading={isSubmitting} icon={<Award className="w-4 h-4" />} iconPosition="left">
                {isSubmitting ? "Issuing..." : "Issue Certificate"}
              </GradientButton>
              <GradientButton type="button" variant="outline" size="md" onClick={() => setShowForm(false)}>Cancel</GradientButton>
            </div>
          </form>
        </GlassCard>
      )}

      {/* Table */}
      <GlassCard className="border border-white/[0.05] overflow-hidden">
        <div className="p-4 border-b border-white/[0.06] flex items-center justify-between gap-4">
          <div className="relative flex-1 max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search certificates..." className="input-brand pl-9" />
          </div>
          <button onClick={fetchCerts} className="w-9 h-9 glass rounded-lg flex items-center justify-center text-text-muted hover:text-white transition-colors">
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>

        {loading ? (
          <div className="p-12 text-center text-text-muted text-sm">Loading certificates...</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/[0.06]">
                  {["Recipient", "Title", "Code", "Status", "Issued", "Actions"].map((h) => (
                    <th key={h} className="text-left px-5 py-3.5 text-xs font-semibold text-text-muted uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((cert) => (
                  <tr key={cert.id} className="border-b border-white/[0.04] hover:bg-white/[0.02] transition-colors">
                    <td className="px-5 py-4">
                      <div className="text-sm font-medium text-white">{cert.users?.full_name}</div>
                      <div className="text-xs text-text-muted">{cert.users?.email}</div>
                    </td>
                    <td className="px-5 py-4"><div className="text-sm text-white max-w-[180px] truncate">{cert.title}</div></td>
                    <td className="px-5 py-4"><span className="font-mono text-xs text-text-muted">{cert.verification_code}</span></td>
                    <td className="px-5 py-4"><span className={`text-xs px-2.5 py-1 rounded-full font-semibold capitalize ${statusBadge[cert.status]}`}>{cert.status}</span></td>
                    <td className="px-5 py-4"><span className="text-xs text-text-muted">{formatDate(cert.issued_at)}</span></td>
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-3">
                        <a href={`/verify/${cert.verification_code}`} target="_blank" rel="noopener noreferrer" className="text-xs text-text-muted hover:text-white transition-colors flex items-center gap-1">
                          <ExternalLink className="w-3.5 h-3.5" /> Verify
                        </a>
                        {cert.status === "active" && (
                          <button onClick={() => revoke(cert.id)} className="text-xs text-red-400 hover:text-red-300 transition-colors flex items-center gap-1">
                            <Ban className="w-3.5 h-3.5" /> Revoke
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </GlassCard>
    </div>
  );
}
EOF

echo "✅ Admin certifications page written"

# ============================================
# STEP 12: ADMIN ACTIVITY LOGS (FULL)
# ============================================
echo "📋 Writing admin activity logs..."

cat > app/\(admin\)/admin/activity-logs/page.tsx << 'EOF'
"use client";
import { useEffect, useState, useCallback } from "react";
import { Activity, RefreshCw, Search } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import { formatDate } from "@/utils/format";

interface Log {
  id: string;
  actor_id: string;
  action: string;
  target_type: string;
  ip_address: string;
  created_at: string;
  users?: { full_name: string; email: string };
}

export default function ActivityLogsPage() {
  const [logs, setLogs] = useState<Log[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  const fetchLogs = useCallback(async () => {
    setLoading(true);
    const s = createClient();
    const { data } = await s
      .from("activity_logs")
      .select("*, users(full_name, email)")
      .order("created_at", { ascending: false })
      .limit(100);
    setLogs((data ?? []) as Log[]);
    setLoading(false);
  }, []);

  useEffect(() => { fetchLogs(); }, [fetchLogs]);

  const filtered = logs.filter((l) =>
    l.action?.toLowerCase().includes(search.toLowerCase()) ||
    l.users?.full_name?.toLowerCase().includes(search.toLowerCase()) ||
    l.target_type?.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div>
        <h2 className="font-display text-2xl font-bold text-white mb-1">Activity Logs</h2>
        <p className="text-text-muted text-sm">Full audit trail of platform activity.</p>
      </div>

      <GlassCard className="border border-white/[0.05] overflow-hidden">
        <div className="p-4 border-b border-white/[0.06] flex items-center justify-between gap-4">
          <div className="relative flex-1 max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search logs..." className="input-brand pl-9" />
          </div>
          <button onClick={fetchLogs} className="w-9 h-9 glass rounded-lg flex items-center justify-center text-text-muted hover:text-white transition-colors">
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>

        {loading ? (
          <div className="p-12 text-center text-text-muted text-sm">Loading logs...</div>
        ) : filtered.length === 0 ? (
          <div className="p-12 text-center">
            <Activity className="w-10 h-10 text-text-muted mx-auto mb-3" />
            <p className="text-text-muted text-sm">No activity logs yet.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/[0.06]">
                  {["Actor", "Action", "Target", "IP", "Time"].map((h) => (
                    <th key={h} className="text-left px-5 py-3.5 text-xs font-semibold text-text-muted uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((log) => (
                  <tr key={log.id} className="border-b border-white/[0.04] hover:bg-white/[0.02] transition-colors">
                    <td className="px-5 py-3.5">
                      <div className="text-sm font-medium text-white">{log.users?.full_name ?? "System"}</div>
                      <div className="text-xs text-text-muted">{log.users?.email ?? "—"}</div>
                    </td>
                    <td className="px-5 py-3.5"><span className="text-sm text-white font-mono text-xs">{log.action}</span></td>
                    <td className="px-5 py-3.5"><span className="text-xs text-text-muted capitalize">{log.target_type ?? "—"}</span></td>
                    <td className="px-5 py-3.5"><span className="text-xs text-text-muted font-mono">{log.ip_address ?? "—"}</span></td>
                    <td className="px-5 py-3.5"><span className="text-xs text-text-muted">{formatDate(log.created_at)}</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </GlassCard>
    </div>
  );
}
EOF

echo "✅ Activity logs page written"

# ============================================
# STEP 13: QR CODE GENERATION API
# ============================================
echo "🔳 Writing QR generation API..."

mkdir -p app/api/qr

cat > app/api/qr/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import { generateQRCodeDataURL, buildVerifyUrl } from "@/lib/qr/generator";
import type { ApiResponse } from "@/types/api.types";

export async function POST(request: NextRequest) {
  try {
    const supabase = await createAdminClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });

    const { data: profile } = await supabase.from("users").select("role").eq("id", user.id).single();
    if (!profile || !["admin", "super_admin"].includes(profile.role)) {
      return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });
    }

    const { type, token } = await request.json();
    if (!token) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Token required" }, { status: 400 });

    const url = buildVerifyUrl(token);
    const qrDataUrl = await generateQRCodeDataURL(url);

    // Store QR code URL back to the record
    if (type === "id") {
      await supabase.from("digital_ids").update({ qr_code_url: qrDataUrl }).eq("id_number", token);
    }

    return NextResponse.json<ApiResponse<{ qr_url: string; verify_url: string }>>({
      success: true,
      data: { qr_url: qrDataUrl, verify_url: url },
    });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "QR generation failed" }, { status: 500 });
  }
}
EOF

echo "✅ QR API written"

# ============================================
# STEP 14: AUTH SERVICE - ADD RESET PASSWORD
# ============================================
cat > services/auth.service.ts << 'EOF'
import { createClient } from "@/lib/supabase/client";

export const authService = {
  async signIn(email: string, password: string) {
    const s = createClient();
    const { data, error } = await s.auth.signInWithPassword({ email, password });
    if (error) throw error;
    return data;
  },
  async signUp(email: string, password: string, metadata: { full_name: string; phone?: string }) {
    const s = createClient();
    const { data, error } = await s.auth.signUp({ email, password, options: { data: metadata } });
    if (error) throw error;
    return data;
  },
  async signOut() {
    const s = createClient();
    const { error } = await s.auth.signOut();
    if (error) throw error;
  },
  async getUser() {
    const s = createClient();
    const { data: { user } } = await s.auth.getUser();
    return user;
  },
  async resetPassword(email: string) {
    const s = createClient();
    const { error } = await s.auth.resetPasswordForEmail(email, {
      redirectTo: `${process.env.NEXT_PUBLIC_APP_URL}/reset-password`,
    });
    if (error) throw error;
  },
  async updatePassword(newPassword: string) {
    const s = createClient();
    const { error } = await s.auth.updateUser({ password: newPassword });
    if (error) throw error;
  },
};
EOF

echo "✅ Auth service updated"

# ============================================
# DONE
# ============================================
echo ""
echo "=================================================="
echo "✅ NIFELUX PHASE 2 — COMPLETE"
echo "=================================================="
echo ""
echo "📋 What was added in Phase 2:"
echo "   ✓ lib/qr/generator.ts — QR code generation"
echo "   ✓ services/notification.service.ts — Notifications"
echo "   ✓ hooks/useNotifications.ts — Realtime via Supabase"
echo "   ✓ components/common/NotificationBell.tsx — Bell UI"
echo "   ✓ app/(dashboard)/layout.tsx — Updated with bell"
echo "   ✓ app/(dashboard)/dashboard/settings/page.tsx — Profile + password"
echo "   ✓ app/(auth)/forgot-password/page.tsx"
echo "   ✓ app/(auth)/reset-password/page.tsx"
echo "   ✓ app/(admin)/admin/users/page.tsx — Full user table + role management"
echo "   ✓ app/(admin)/admin/id-management/page.tsx — Issue + revoke IDs"
echo "   ✓ app/(admin)/admin/certifications/page.tsx — Issue + revoke certs"
echo "   ✓ app/(admin)/admin/activity-logs/page.tsx — Full audit log"
echo "   ✓ app/api/qr/route.ts — QR generation endpoint"
echo "   ✓ app/api/notifications/route.ts — Send notifications"
echo "   ✓ services/auth.service.ts — Reset password added"
echo ""
echo "📋 Next Steps:"
echo "   1. Add your Supabase keys to .env.local"
echo "   2. Run: npx supabase db push"
echo "   3. Enable Realtime on the 'notifications' table"
echo "      in your Supabase dashboard → Database → Replication"
echo "   4. Run: npm run dev"
echo ""
echo "   Phase 3 → Payments (iPayNG), Support contributions,"
echo "   email system (Resend), and analytics dashboard."
echo ""
echo "🌍 Built for Nifelux Technologies — Lagos, Nigeria"
