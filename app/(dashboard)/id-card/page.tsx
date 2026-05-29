"use client";
import { useEffect, useState } from "react";
import { QrCode, Shield, Calendar } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import { useUser } from "@/hooks/useUser";
import { idService } from "@/services/id.service";
import type { DigitalId } from "@/types/user.types";
import { formatDate } from "@/utils/format";

export default function IdCardPage() {
  const { user } = useUser();
  const [id, setId] = useState<DigitalId | null>(null);
  useEffect(() => { if (!user) return; idService.getMyId(user.id).then(setId); }, [user]);
  if (!id) return (
    <div className="max-w-2xl mx-auto text-center py-20">
      <QrCode className="w-12 h-12 text-text-muted mx-auto mb-4" />
      <h2 className="font-display text-xl font-bold text-white mb-2">No Digital ID Yet</h2>
      <p className="text-text-muted text-sm">Your digital ID will appear here once issued by an admin.</p>
    </div>
  );
  return (
    <div className="max-w-md mx-auto space-y-6">
      <h2 className="font-display text-2xl font-bold text-white">My Digital ID</h2>
      <GlassCard className="overflow-hidden">
        <div className="bg-brand-gradient p-6">
          <div className="flex items-center justify-between mb-6">
            <div><div className="text-white/70 text-xs uppercase tracking-widest">Nifelux Technologies</div><div className="text-white font-display text-sm font-bold">Digital Identity Card</div></div>
            <Shield className="w-6 h-6 text-white/70" />
          </div>
          <div className="text-white"><div className="text-2xl font-display font-bold mb-1">{user?.full_name}</div><div className="text-white/70 text-sm capitalize">{user?.role}</div></div>
        </div>
        <div className="p-6 bg-brand-card space-y-4">
          <div className="flex items-center justify-between">
            <div><div className="text-xs text-text-muted mb-1">ID Number</div><div className="font-mono text-sm text-white font-bold">{id.id_number}</div></div>
            <div className="text-right"><div className="text-xs text-text-muted mb-1">Status</div><span className="text-xs px-2.5 py-1 rounded-full bg-brand-green/10 text-brand-green font-semibold capitalize">{id.status}</span></div>
          </div>
          <div className="flex items-center justify-between">
            <div><div className="text-xs text-text-muted mb-1 flex items-center gap-1"><Calendar className="w-3 h-3" />Issued</div><div className="text-xs text-white">{formatDate(id.issued_at)}</div></div>
            <div className="text-right"><div className="text-xs text-text-muted mb-1">Expires</div><div className="text-xs text-white">{formatDate(id.expires_at)}</div></div>
          </div>
          {id.qr_code_url && <div className="flex justify-center pt-2"><img src={id.qr_code_url} alt="QR Code" className="w-24 h-24 rounded-lg" /></div>}
          <div className="text-center text-xs text-text-muted pt-2 border-t border-white/[0.06]">Verify at nifelux.com/verify</div>
        </div>
      </GlassCard>
    </div>
  );
}
