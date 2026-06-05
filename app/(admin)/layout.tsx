"use client";
import { useEffect } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { LayoutDashboard, Users, CreditCard, Award, BarChart2, Activity, Shield, LogOut, Zap, Bell } from "lucide-react";
import { cn } from "@/utils/cn";
import { authService } from "@/services/auth.service";
import { useAuth } from "@/hooks/useAuth";
import { useUser } from "@/hooks/useUser";
import { toast } from "sonner";
import LoadingSpinner from "@/components/common/LoadingSpinner";

const nav = [
  { icon: LayoutDashboard, label: "Overview", href: "/admin/dashboard" },
  { icon: Users, label: "Users", href: "/admin/users" },
  { icon: CreditCard, label: "ID Management", href: "/admin/id-management" },
  { icon: Award, label: "Certifications", href: "/admin/certifications" },
  { icon: BarChart2, label: "Payments", href: "/admin/payments" },
  { icon: BarChart2, label: "Analytics", href: "/admin/analytics" },
  { icon: Bell, label: "Notifications", href: "/admin/notifications" },
  { icon: Activity, label: "Activity Logs", href: "/admin/activity-logs" },
  { icon: Shield, label: "Roles", href: "/admin/roles" },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const { user, isLoading } = useAuth();
  const { isAdmin } = useUser();
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    if (!isLoading && (!user || !isAdmin)) router.replace("/login");
  }, [user, isLoading, isAdmin, router]);

  if (isLoading) return <div className="min-h-screen bg-brand-dark flex items-center justify-center"><LoadingSpinner size="lg" /></div>;
  if (!user || !isAdmin) return null;

  const handleSignOut = async () => {
    await authService.signOut();
    toast.success("Signed out");
    router.push("/");
  };

  return (
    <div className="min-h-screen bg-brand-dark flex">
      <aside className="w-64 flex-col border-r border-white/[0.06] bg-brand-dark-secondary hidden md:flex">
        <div className="p-6 border-b border-white/[0.06]">
          <Link href="/" className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-brand-gradient flex items-center justify-center"><Zap className="w-4 h-4 text-white" strokeWidth={2.5} /></div>
            <div>
              <div className="font-display text-sm font-bold text-white">Nifelux</div>
              <div className="text-[10px] text-red-400 font-semibold uppercase tracking-widest">Admin</div>
            </div>
          </Link>
        </div>
        <nav className="flex-1 p-4 space-y-0.5 overflow-y-auto">
          {nav.map(({ icon: I, label, href }) => (
            <Link key={href} href={href}
              className={cn("flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-medium transition-all",
                pathname.startsWith(href) ? "bg-brand-blue/10 text-white border border-brand-blue/20" : "text-text-secondary hover:text-white hover:bg-white/[0.04]")}>
              <I className="w-4 h-4" />{label}
            </Link>
          ))}
        </nav>
        <div className="p-4 border-t border-white/[0.06]">
          <div className="text-xs text-text-muted px-4 py-2 truncate">{user.email}</div>
          <button onClick={handleSignOut} className="flex items-center gap-3 px-4 py-2.5 w-full rounded-xl text-sm text-text-secondary hover:text-white hover:bg-white/[0.04] transition-all">
            <LogOut className="w-4 h-4" />Sign Out
          </button>
        </div>
      </aside>
      <div className="flex-1 flex flex-col min-w-0">
        <header className="h-16 border-b border-white/[0.06] bg-brand-dark-secondary/50 backdrop-blur-sm flex items-center justify-between px-6 sticky top-0 z-20">
          <h1 className="font-display text-base font-bold text-white">
            {nav.find((n) => pathname.startsWith(n.href))?.label ?? "Admin"}
          </h1>
          <span className="badge-brand text-xs">Admin Panel</span>
        </header>
        <main className="flex-1 p-6 overflow-auto">{children}</main>
      </div>
    </div>
  );
}
