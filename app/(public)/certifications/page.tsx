"use client";
import { useState } from "react";
import { motion } from "framer-motion";
import { Award, Shield, QrCode, Search, ArrowRight, Lock } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import SectionHeading from "@/components/common/SectionHeading";
import AnimatedSection, { StaggerContainer, StaggerItem } from "@/components/common/AnimatedSection";
import GradientButton from "@/components/common/GradientButton";
import { toast } from "sonner";

const features = [
  { icon:Shield, title:"Tamper-Proof", desc:"Every certificate is cryptographically signed and immutably recorded.", color:"blue" },
  { icon:QrCode, title:"QR Verification", desc:"Instant verification via QR code — scan to confirm authenticity in seconds.", color:"purple" },
  { icon:Search, title:"Public Lookup", desc:"Anyone can verify a certificate by its unique verification code.", color:"green" },
  { icon:Lock, title:"Secure Issuance", desc:"Only authorized Nifelux admins can issue and manage certifications.", color:"blue" },
];
const imap: Record<string,string> = { blue:"bg-brand-blue/10 text-brand-blue-light", purple:"bg-brand-purple/10 text-brand-purple-light", green:"bg-brand-green/10 text-brand-green" };

export default function CertificationsPage() {
  const [code, setCode] = useState("");
  const [loading, setLoading] = useState(false);

  const verify = async () => {
    if (!code.trim()) { toast.error("Enter a verification code"); return; }
    setLoading(true);
    try {
      const res = await fetch(`/api/certifications?code=${code.trim()}`);
      const json = await res.json() as { success: boolean; data?: { title: string; status: string } };
      if (json.success && json.data) {
        toast.success(`Certificate found: ${json.data.title} — ${json.data.status}`);
        window.location.href = `/verify/${code.trim()}`;
      } else {
        toast.error("Certificate not found. Check your code and try again.");
      }
    } catch { toast.error("Verification failed. Please try again."); }
    finally { setLoading(false); }
  };

  return (
    <>
      <section className="relative min-h-[55vh] flex items-center overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark"><div className="absolute inset-0 bg-hero-gradient" /><div className="absolute inset-0 dot-pattern opacity-25" /></div>
        <div className="absolute top-1/3 right-1/4 w-72 h-72 orb orb-green opacity-20 animate-float" />
        <div className="container-custom relative z-10 py-24 max-w-3xl">
          <motion.span initial={{opacity:0,y:12}} animate={{opacity:1,y:0}} className="badge-green inline-flex mb-6"><span className="w-1.5 h-1.5 rounded-full bg-brand-green animate-pulse" />Certifications</motion.span>
          <motion.h1 initial={{opacity:0,y:24}} animate={{opacity:1,y:0}} transition={{delay:0.1}} className="font-display text-4xl md:text-6xl text-white mb-6">Verifiable Digital<br /><span className="gradient-text-green">Certificates</span></motion.h1>
          <motion.p initial={{opacity:0,y:24}} animate={{opacity:1,y:0}} transition={{delay:0.2}} className="text-text-secondary text-lg leading-relaxed max-w-2xl mb-8">Nifelux Technologies issues cryptographically secure, QR-verifiable digital certifications for programs, achievements, and partnerships.</motion.p>
          <motion.div initial={{opacity:0,y:24}} animate={{opacity:1,y:0}} transition={{delay:0.3}} className="flex flex-col sm:flex-row gap-3">
            <GradientButton href="/dashboard" variant="outline" size="md" icon={<ArrowRight className="w-4 h-4" />}>My Certifications</GradientButton>
          </motion.div>
        </div>
      </section>

      <section className="py-12 relative">
        <div className="absolute inset-0 bg-brand-dark-secondary" />
        <div className="container-custom relative z-10">
          <AnimatedSection>
            <GlassCard className="p-8 border border-brand-green/20 bg-brand-green/5">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 items-center">
                <div><h3 className="font-display text-xl font-bold text-white mb-2">Verify a Certificate</h3><p className="text-text-secondary text-sm">Enter a Nifelux certificate verification code to confirm its authenticity.</p></div>
                <div className="flex gap-3">
                  <input value={code} onChange={(e) => setCode(e.target.value)} onKeyDown={(e) => e.key === "Enter" && verify()} type="text" placeholder="NF-CERT-XXXXXX" className="input-brand flex-1" />
                  <GradientButton variant="green-blue" size="md" onClick={verify} loading={loading} icon={<Search className="w-4 h-4" />} iconPosition="left">Verify</GradientButton>
                </div>
              </div>
            </GlassCard>
          </AnimatedSection>
        </div>
      </section>

      <section className="section-padding relative">
        <div className="absolute inset-0 bg-brand-dark" />
        <div className="container-custom relative z-10">
          <SectionHeading badge="How It Works" title="Trusted" titleHighlight="Certification System" description="Built on cryptographic security, QR verification, and permanent public records." className="mb-14" />
          <StaggerContainer className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            {features.map(({ icon:I, title, desc, color }) => (
              <StaggerItem key={title}>
                <GlassCard hover className="p-6 border border-white/[0.05] text-center h-full">
                  <div className={`w-12 h-12 rounded-2xl mx-auto flex items-center justify-center mb-4 ${imap[color]}`}><I className="w-6 h-6" /></div>
                  <h3 className="font-display text-sm font-bold text-white mb-2">{title}</h3>
                  <p className="text-text-muted text-sm leading-relaxed">{desc}</p>
                </GlassCard>
              </StaggerItem>
            ))}
          </StaggerContainer>
        </div>
      </section>

      <section className="py-20 relative overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark-secondary" />
        <div className="container-custom relative z-10 text-center">
          <AnimatedSection>
            <Award className="w-12 h-12 text-brand-green mx-auto mb-5 animate-float" />
            <h2 className="font-display text-4xl text-white mb-4">Have a Certificate to Verify?</h2>
            <p className="text-text-secondary mb-7 max-w-lg mx-auto text-sm">All Nifelux certificates are permanently verifiable. Use the form above or contact us for inquiries.</p>
            <GradientButton href="/contact" variant="outline" size="md">Contact Us</GradientButton>
          </AnimatedSection>
        </div>
      </section>
    </>
  );
}
