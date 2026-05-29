"use client";
import { useEffect, useState } from "react";
import { Award, Download, ExternalLink } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import { useUser } from "@/hooks/useUser";
import { certificationService } from "@/services/certification.service";
import type { Certification } from "@/types/user.types";
import { formatDate } from "@/utils/format";

export default function CertificationsPage() {
  const { user } = useUser();
  const [certs, setCerts] = useState<Certification[]>([]);
  useEffect(() => { if (!user) return; certificationService.getMyCertifications(user.id).then(setCerts); }, [user]);
  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <h2 className="font-display text-2xl font-bold text-white">My Certifications</h2>
      {certs.length===0 ? (
        <GlassCard className="p-12 border border-white/[0.05] text-center"><Award className="w-12 h-12 text-text-muted mx-auto mb-4" /><h3 className="font-display text-lg font-bold text-white mb-2">No certifications yet</h3><p className="text-text-muted text-sm">Your certifications will appear here once issued.</p></GlassCard>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {certs.map((cert) => (
            <GlassCard key={cert.id} className="p-6 border border-white/[0.05]">
              <div className="flex items-start justify-between mb-4">
                <div className="w-10 h-10 rounded-xl bg-brand-green/10 flex items-center justify-center"><Award className="w-5 h-5 text-brand-green" /></div>
                <span className={`text-xs px-2.5 py-1 rounded-full font-semibold ${cert.status==="active"?"bg-brand-green/10 text-brand-green":"bg-white/[0.05] text-text-muted"}`}>{cert.status}</span>
              </div>
              <h3 className="font-display text-base font-bold text-white mb-1">{cert.title}</h3>
              <p className="text-text-muted text-xs mb-3">Issued by {cert.issued_by} · {formatDate(cert.issued_at)}</p>
              <div className="text-xs text-text-muted font-mono bg-white/[0.03] px-3 py-2 rounded-lg mb-4">{cert.verification_code}</div>
              <div className="flex gap-3">
                {cert.certificate_url && <a href={cert.certificate_url} target="_blank" rel="noopener noreferrer" className="flex items-center gap-1.5 text-xs text-brand-blue-light hover:text-white transition-colors"><Download className="w-3.5 h-3.5" />Download</a>}
                <a href={`/verify/${cert.verification_code}`} target="_blank" rel="noopener noreferrer" className="flex items-center gap-1.5 text-xs text-text-muted hover:text-white transition-colors"><ExternalLink className="w-3.5 h-3.5" />Verify</a>
              </div>
            </GlassCard>
          ))}
        </div>
      )}
    </div>
  );
}
