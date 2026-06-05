"use client";
import { useState } from "react";
import { motion } from "framer-motion";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Heart, Zap, Globe, Cpu, Bot, BrainCircuit, ArrowRight } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import AnimatedSection from "@/components/common/AnimatedSection";
import { toast } from "sonner";

const schema = z.object({
  email: z.string().email("Enter a valid email"),
  name: z.string().optional(),
  message: z.string().max(200).optional(),
  anonymous: z.boolean().optional(),
});
type Form = z.infer<typeof schema>;

const presets = [500, 1000, 2500, 5000, 10000, 25000];
const impactItems = [
  { icon: BrainCircuit, label: "AI Research", desc: "Fund AI model training and research infrastructure." },
  { icon: Bot, label: "Robotics Hardware", desc: "Source components for robotic prototype development." },
  { icon: Globe, label: "Platform Growth", desc: "Scale the Nifelux platform to serve more of Africa." },
  { icon: Cpu, label: "Engineering Tools", desc: "Equip our engineers with the best tools available." },
];

export default function SupportPage() {
  const [selectedAmount, setSelectedAmount] = useState<number | null>(null);
  const [customAmount, setCustomAmount] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const { register, handleSubmit, formState: { errors } } = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: { anonymous: false },
  });

  const getAmount = () => selectedAmount ?? (customAmount ? Number(customAmount) : 0);

  const onSubmit = async (data: Form) => {
    const amount = getAmount();
    if (!amount || amount < 100) { toast.error("Minimum contribution is ₦100"); return; }
    setSubmitting(true);
    try {
      const res = await fetch("/api/payments", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ amount, email: data.email, purpose: "contribution", anonymous: data.anonymous, message: data.message ?? "" }),
      });
      const json = await res.json() as { success: boolean; data?: { payment_url: string }; error?: string };
      if (!json.success) throw new Error(json.error ?? "Payment failed");
      window.location.href = json.data!.payment_url;
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : "Payment failed. Please try again.");
      setSubmitting(false);
    }
  };

  return (
    <>
      <section className="relative min-h-[55vh] flex items-center overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark"><div className="absolute inset-0 bg-hero-gradient" /><div className="absolute inset-0 dot-pattern opacity-25" /></div>
        <div className="absolute top-1/3 left-1/4 w-72 h-72 orb orb-green opacity-20 animate-float" />
        <div className="container-custom relative z-10 py-24 max-w-3xl">
          <motion.span initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} className="badge-green inline-flex mb-6">
            <span className="w-1.5 h-1.5 rounded-full bg-brand-green animate-pulse" />Support Our Mission
          </motion.span>
          <motion.h1 initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }} className="font-display text-4xl md:text-6xl text-white mb-6">
            Help Build<br /><span className="gradient-text-green">Africa&apos;s Future</span>
          </motion.h1>
          <motion.p initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }} className="text-text-secondary text-lg leading-relaxed">
            Every contribution goes directly into building AI systems, robotics, and digital infrastructure for Africa.
          </motion.p>
        </div>
      </section>

      <section className="section-padding relative">
        <div className="absolute inset-0 bg-brand-dark-secondary" />
        <div className="container-custom relative z-10">
          <div className="grid grid-cols-1 lg:grid-cols-5 gap-10">
            <AnimatedSection direction="right" className="lg:col-span-2">
              <h2 className="font-display text-2xl font-bold text-white mb-4">Why Support Nifelux?</h2>
              <p className="text-text-secondary text-sm leading-relaxed mb-7">Your support directly fuels research, hardware, and the engineers building these systems.</p>
              <div className="space-y-4 mb-8">
                {impactItems.map(({ icon: I, label, desc }) => (
                  <div key={label} className="flex items-start gap-3">
                    <div className="w-9 h-9 rounded-lg bg-brand-green/10 flex items-center justify-center flex-shrink-0"><I className="w-4 h-4 text-brand-green" /></div>
                    <div><div className="text-sm font-semibold text-white mb-0.5">{label}</div><div className="text-xs text-text-muted leading-relaxed">{desc}</div></div>
                  </div>
                ))}
              </div>
            </AnimatedSection>

            <AnimatedSection direction="left" delay={0.1} className="lg:col-span-3">
              <GlassCard variant="gradient" className="p-8 border border-white/[0.06]">
                <div className="flex items-center gap-3 mb-6">
                  <div className="w-10 h-10 rounded-xl bg-brand-green/10 flex items-center justify-center"><Heart className="w-5 h-5 text-brand-green" /></div>
                  <div><h3 className="font-display text-lg font-bold text-white">Make a Contribution</h3><p className="text-xs text-text-muted">Secure payment via iPayNG</p></div>
                </div>

                <form onSubmit={handleSubmit(onSubmit)} className="space-y-5" noValidate>
                  <div>
                    <label className="block text-xs font-semibold text-text-secondary mb-3 uppercase tracking-wider">Choose Amount (₦)</label>
                    <div className="grid grid-cols-3 gap-2.5 mb-3">
                      {presets.map((p) => (
                        <button key={p} type="button" onClick={() => { setSelectedAmount(p); setCustomAmount(""); }}
                          className={`py-2.5 px-3 text-sm font-semibold rounded-xl border transition-all ${selectedAmount === p ? "border-brand-green/60 bg-brand-green/10 text-brand-green" : "border-white/10 text-text-secondary hover:border-brand-green/40 hover:text-white"}`}>
                          ₦{p.toLocaleString()}
                        </button>
                      ))}
                    </div>
                    <input type="number" placeholder="Or enter custom amount" value={customAmount}
                      onChange={(e) => { setCustomAmount(e.target.value); setSelectedAmount(null); }}
                      className="input-brand" min={100} />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Email Address *</label>
                    <input {...register("email")} type="email" placeholder="you@email.com" className="input-brand" />
                    {errors.email && <p className="mt-1.5 text-xs text-red-400">{errors.email.message}</p>}
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Your Name (Optional)</label>
                    <input {...register("name")} placeholder="Your name" className="input-brand" />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Message (Optional)</label>
                    <textarea {...register("message")} rows={2} placeholder="Leave a message of support..." className="input-brand resize-none" />
                  </div>

                  <label className="flex items-center gap-3 cursor-pointer">
                    <input {...register("anonymous")} type="checkbox" className="w-4 h-4 rounded accent-brand-green" />
                    <span className="text-sm text-text-secondary">Contribute anonymously</span>
                  </label>

                  <GradientButton type="submit" variant="green-blue" size="md" fullWidth loading={submitting}
                    icon={<Zap className="w-4 h-4" />} iconPosition="left">
                    {submitting ? "Redirecting..." : "Contribute via iPayNG"}
                  </GradientButton>
                  <p className="text-center text-xs text-text-muted">You will be redirected to a secure iPayNG payment page.</p>
                </form>
              </GlassCard>
            </AnimatedSection>
          </div>
        </div>
      </section>

      <section className="py-20 relative overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark" />
        <div className="container-custom relative z-10 text-center">
          <AnimatedSection>
            <Heart className="w-12 h-12 text-brand-green mx-auto mb-5 animate-float" />
            <h2 className="font-display text-4xl text-white mb-4">Every Naira Counts</h2>
            <p className="text-text-secondary max-w-xl mx-auto text-sm leading-relaxed mb-7">Whether it&apos;s ₦500 or ₦500,000 — you are directly funding Africa&apos;s technology future.</p>
            <GradientButton href="/about" variant="outline" size="md" icon={<ArrowRight className="w-4 h-4" />}>Learn More</GradientButton>
          </AnimatedSection>
        </div>
      </section>
    </>
  );
}
