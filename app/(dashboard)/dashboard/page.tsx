"use client";
import { useEffect, useState } from "react";
import { CreditCard, Award, Zap, ArrowRight } from "lucide-react";
import Link from "next/link";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import { useUser } from "@/hooks/useUser";
import { idService } from "@/services/id.service";
import { certificationService } from "@/services/certification.service";
import type { DigitalId, Certification } from "@/types/user.types";

export default function DashboardPage() {
  const { user } = useUser();
  const [digitalId, setDigitalId] = useState<DigitalId | null>(null);
  const [certs, setCerts] = useState<Certification[]>([]);
  useEffect(() => { if (!user) return; idService.getMyId(user.id).then(setDigitalId); certificationService.getMyCertifications(user.id).then(setCerts); }, [user]);
  return (
    <div className="max-w-5xl mx-auto space-y-8">
      <div><h2 className="font-display text-2xl font-bold text-white mb-1">Welcome back, {user?.full_name?.split(" ")[0]} 👋</h2><p className="text-text-muted text-sm">Your Nifelux dashboard overview.</p></div>
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        {[
          { label:"Digital ID", value:digitalId?digitalId.id_number:"Not issued", icon:CreditCard, color:"blue", href:"/id-card" },
          { label:"Certifications", value:certs.length.toString(), icon:Award, color:"green", href:"/dashboard/certifications" },
          { label:"Account Status", value:user?.status??"Active", icon:Zap, color:"purple", href:"/dashboard" },
        ].map(({ label, value, icon:I, color, href }) => (
          <Link key={label} href={href}>
            <GlassCard hover className={`p-5 border ${color==="blue"?"border-brand-blue/20":color==="green"?"border-brand-green/20":"border-brand-purple/20"}`}>
              <div className={`w-9 h-9 rounded-xl flex items-center justify-center mb-3 ${color==="blue"?"bg-brand-blue/10 text-brand-blue-light":color==="green"?"bg-brand-green/10 text-brand-green":"bg-brand-purple/10 text-brand-purple-light"}`}><I className="w-4 h-4" /></div>
              <div className="text-xs text-text-muted mb-1">{label}</div>
              <div className="font-display text-base font-bold text-white">{value}</div>
            </GlassCard>
          </Link>
        ))}
      </div>
      <GlassCard className="p-6 border border-white/[0.05]">
        <h3 className="font-display text-base font-bold text-white mb-4 flex items-center gap-2"><CreditCard className="w-4 h-4 text-brand-blue-light" />Digital ID</h3>
        {digitalId ? (
          <div className="space-y-2">
            <div className="flex justify-between text-sm"><span className="text-text-muted">ID Number</span><span className="text-white font-mono text-xs">{digitalId.id_number}</span></div>
            <div className="flex justify-between text-sm"><span className="text-text-muted">Status</span><span className="text-brand-green capitalize">{digitalId.status}</span></div>
            <div className="mt-4"><GradientButton href="/id-card" variant="outline" size="sm" icon={<ArrowRight className="w-3.5 h-3.5" />}>View ID Card</GradientButton></div>
          </div>
        ) : (
          <div className="text-center py-4"><p className="text-text-muted text-sm mb-4">No digital ID has been issued yet.</p><GradientButton href="/contact" variant="outline" size="sm">Request ID</GradientButton></div>
        )}
      </GlassCard>
    </div>
  );
}
