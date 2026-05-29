import { createAdminClient } from "@/lib/supabase/server";
import { Shield, CheckCircle, XCircle, AlertTriangle } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import { formatDate } from "@/utils/format";
interface Props { params: Promise<{ token: string }>; }
export default async function VerifyPage({ params }: Props) {
  const { token } = await params;
  const supabase = await createAdminClient();
  const { data: id } = await supabase.from("digital_ids").select("*, users(full_name, email)").eq("id_number", token).single();
  const { data: cert } = !id ? await supabase.from("certifications").select("*, users(full_name)").eq("verification_code", token).single() : { data: null };
  const isValid = id?.status==="active" || cert?.status==="active";
  const isExpired = id?.status==="expired" || cert?.status==="expired";
  return (
    <div className="min-h-screen bg-brand-dark flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-hero-gradient" /><div className="absolute inset-0 dot-pattern opacity-20" />
      <div className="relative z-10 w-full max-w-lg">
        <GlassCard variant="gradient" className="p-8 border border-white/[0.06]">
          <div className="text-center mb-8">
            <div className={`w-16 h-16 rounded-2xl mx-auto flex items-center justify-center mb-4 ${isValid?"bg-brand-green/10":"bg-red-500/10"}`}>
              {isValid?<CheckCircle className="w-8 h-8 text-brand-green" />:isExpired?<AlertTriangle className="w-8 h-8 text-yellow-400" />:<XCircle className="w-8 h-8 text-red-400" />}
            </div>
            <h1 className="font-display text-2xl font-bold text-white mb-2">{isValid?"Verified ✓":isExpired?"Expired":"Not Found"}</h1>
            <p className="text-text-muted text-sm">{isValid?"This credential is authentic and valid.":"This credential could not be verified."}</p>
          </div>
          {(id||cert) && (
            <div className="space-y-3 mb-6">
              {id && <>
                <div className="flex justify-between text-sm"><span className="text-text-muted">Name</span><span className="text-white font-medium">{(id.users as { full_name:string })?.full_name}</span></div>
                <div className="flex justify-between text-sm"><span className="text-text-muted">ID Number</span><span className="text-white font-mono text-xs">{id.id_number}</span></div>
                <div className="flex justify-between text-sm"><span className="text-text-muted">Expires</span><span className="text-white text-xs">{formatDate(id.expires_at)}</span></div>
              </>}
              {cert && <>
                <div className="flex justify-between text-sm"><span className="text-text-muted">Recipient</span><span className="text-white font-medium">{(cert.users as { full_name:string })?.full_name}</span></div>
                <div className="flex justify-between text-sm"><span className="text-text-muted">Certificate</span><span className="text-white text-xs">{cert.title}</span></div>
                <div className="flex justify-between text-sm"><span className="text-text-muted">Issued</span><span className="text-white text-xs">{formatDate(cert.issued_at)}</span></div>
              </>}
              <div className="flex justify-between text-sm"><span className="text-text-muted">Issuer</span><span className="text-white font-medium">Nifelux Technologies</span></div>
            </div>
          )}
          <div className="flex items-center justify-center gap-2 text-xs text-text-muted pt-4 border-t border-white/[0.06] mb-4"><Shield className="w-3.5 h-3.5 text-brand-blue-light" />Verified by Nifelux Technologies</div>
          <div className="text-center"><GradientButton href="/" variant="outline" size="sm">Back to Nifelux</GradientButton></div>
        </GlassCard>
      </div>
    </div>
  );
}
