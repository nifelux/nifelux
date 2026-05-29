"use client";
import { useEffect } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { LayoutDashboard, CreditCard, Award, LogOut, Zap, Bell } from "lucide-react";
import { cn } from "@/utils/cn";
import { authService } from "@/services/auth.service";
import { useAuth } from "@/hooks/useAuth";
import { toast } from "sonner";
import LoadingSpinner from "@/components/common/LoadingSpinner";

const nav = [
  { icon:LayoutDashboard, label:"Dashboard", href:"/dashboard" },
  { icon:CreditCard, label:"My ID Card", href:"/id-card" },
  { icon:Award, label:"Certifications", href:"/dashboard/certifications" },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { user, isLoading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  useEffect(() => { if (!isLoading && !user) router.replace("/login"); }, [user, isLoading, router]);
  if (isLoading) return <div className="min-h-screen bg-brand-dark flex items-center justify-center"><LoadingSpinner size="lg" /></div>;
  if (!user) return null;
  const handleSignOut = async () => { await authService.signOut(); toast.success("Signed out"); router.push("/"); };
  return (
    <div className="min-h-screen bg-brand-dark flex">
      <aside className="hidden md:flex w-64 flex-col border-r border-white/[0.06] bg-brand-dark-secondary">
        <div className="p-6 border-b border-white/[0.06]">
          <Link href="/" className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-brand-gradient flex items-center justify-center"><Zap className="w-4 h-4 text-white" strokeWidth={2.5} /></div>
            <span className="font-display text-base font-bold text-white">Nifelux</span>
          </Link>
        </div>
        <nav className="flex-1 p-4 space-y-1">
          {nav.map(({ icon:I, label, href }) => (
            <Link key={href} href={href} className={cn("flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all", pathname===href?"bg-brand-blue/10 text-white border border-brand-blue/20":"text-text-secondary hover:text-white hover:bg-white/[0.04]")}>
              <I className="w-4 h-4" />{label}
            </Link>
          ))}
        </nav>
        <div className="p-4 border-t border-white/[0.06]">
          <div className="flex items-center gap-3 px-4 py-3 mb-2">
            <div className="w-8 h-8 rounded-full bg-brand-gradient flex items-center justify-center text-xs font-bold text-white">{user.full_name?.[0]?.toUpperCase()??"N"}</div>
            <div className="flex-1 min-w-0"><div className="text-sm font-medium text-white truncate">{user.full_name}</div><div className="text-xs text-text-muted capitalize">{user.role}</div></div>
          </div>
          <button onClick={handleSignOut} className="flex items-center gap-3 px-4 py-2.5 w-full rounded-xl text-sm text-text-secondary hover:text-white hover:bg-white/[0.04] transition-all"><LogOut className="w-4 h-4" />Sign Out</button>
        </div>
      </aside>
      <div className="flex-1 flex flex-col min-w-0">
        <header className="h-16 border-b border-white/[0.06] bg-brand-dark-secondary/50 backdrop-blur-sm flex items-center justify-between px-6">
          <h1 className="font-display text-base font-bold text-white">{nav.find((n) => n.href===pathname)?.label??"Dashboard"}</h1>
          <div className="flex items-center gap-3">
            <button className="w-9 h-9 rounded-lg glass flex items-center justify-center text-text-muted hover:text-white transition-colors"><Bell className="w-4 h-4" /></button>
            <div className="w-8 h-8 rounded-full bg-brand-gradient flex items-center justify-center text-xs font-bold text-white">{user.full_name?.[0]?.toUpperCase()??"N"}</div>
          </div>
        </header>
        <main className="flex-1 p-6 overflow-auto">{children}</main>
      </div>
    </div>
  );
}
