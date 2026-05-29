"use client";
import { Users, CreditCard, Award, DollarSign, TrendingUp, Activity } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import { StaggerContainer, StaggerItem } from "@/components/common/AnimatedSection";
const stats = [
  { label:"Total Users", value:"—", icon:Users, color:"blue" },
  { label:"IDs Issued", value:"—", icon:CreditCard, color:"purple" },
  { label:"Certifications", value:"—", icon:Award, color:"green" },
  { label:"Contributions", value:"₦—", icon:DollarSign, color:"blue" },
];
export default function AdminDashboard() {
  return (
    <div className="max-w-6xl mx-auto space-y-8">
      <div><h2 className="font-display text-2xl font-bold text-white mb-1">Admin Overview</h2><p className="text-text-muted text-sm">Platform analytics and management hub.</p></div>
      <StaggerContainer className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map(({ label, value, icon:I, color }) => (
          <StaggerItem key={label}>
            <GlassCard className={`p-5 border ${color==="blue"?"border-brand-blue/20":color==="green"?"border-brand-green/20":"border-brand-purple/20"}`}>
              <div className={`w-9 h-9 rounded-xl flex items-center justify-center mb-4 ${color==="blue"?"bg-brand-blue/10 text-brand-blue-light":color==="green"?"bg-brand-green/10 text-brand-green":"bg-brand-purple/10 text-brand-purple-light"}`}><I className="w-4 h-4" /></div>
              <div className="font-display text-2xl font-bold text-white mb-1">{value}</div>
              <div className="text-xs text-text-muted">{label}</div>
            </GlassCard>
          </StaggerItem>
        ))}
      </StaggerContainer>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <GlassCard className="p-6 border border-white/[0.05]"><h3 className="font-display text-base font-bold text-white mb-4 flex items-center gap-2"><Activity className="w-4 h-4 text-brand-blue-light" />Recent Activity</h3><div className="text-center py-8 text-text-muted text-sm">Connect Supabase to load activity.</div></GlassCard>
        <GlassCard className="p-6 border border-white/[0.05]"><h3 className="font-display text-base font-bold text-white mb-4 flex items-center gap-2"><Users className="w-4 h-4 text-brand-purple-light" />Recent Users</h3><div className="text-center py-8 text-text-muted text-sm">Connect Supabase to load users.</div></GlassCard>
      </div>
    </div>
  );
}
