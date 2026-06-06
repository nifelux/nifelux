"use client";
import { useState } from "react";
import { motion } from "framer-motion";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Mail, MapPin, Send, MessageSquare, Check } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import AnimatedSection from "@/components/common/AnimatedSection";
import GradientButton from "@/components/common/GradientButton";
import { toast } from "sonner";

const schema = z.object({
  name: z.string().min(2, "Min 2 characters"),
  email: z.string().email("Invalid email"),
  subject: z.string().min(5, "Min 5 characters"),
  message: z.string().min(20, "Min 20 characters"),
});
type Form = z.infer<typeof schema>;

const info = [
  { icon:Mail, label:"Email", value:"hello@nifelux.com", href:"mailto:hello@nifelux.com", color:"blue" },
  { icon:MapPin, label:"Location", value:"Lagos, Nigeria", href:null, color:"green" },
  { icon:MessageSquare, label:"Response Time", value:"Within 24 hours", href:null, color:"purple" },
];
const imap: Record<string,string> = { blue:"bg-brand-blue/10 text-brand-blue-light", purple:"bg-brand-purple/10 text-brand-purple-light", green:"bg-brand-green/10 text-brand-green" };

export default function ContactPage() {
  const [submitted, setSubmitted] = useState(false);
  const { register, handleSubmit, formState:{ errors, isSubmitting }, reset } = useForm<Form>({ resolver: zodResolver(schema) });

  const onSubmit: import("react-hook-form").SubmitHandler<Form> = async (data) => {
    await new Promise((r) => setTimeout(r, 1200));
    console.log("Contact:", data);
    setSubmitted(true); reset();
    toast.success("Message sent! We'll be in touch soon.");
  };

  return (
    <>
      <section className="relative min-h-[45vh] flex items-center overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark"><div className="absolute inset-0 bg-hero-gradient" /><div className="absolute inset-0 dot-pattern opacity-30" /></div>
        <div className="container-custom relative z-10 py-20 max-w-3xl">
          <motion.span initial={{opacity:0,y:12}} animate={{opacity:1,y:0}} className="badge-brand inline-flex mb-6"><span className="w-1.5 h-1.5 rounded-full bg-brand-blue-light animate-pulse" />Contact Us</motion.span>
          <motion.h1 initial={{opacity:0,y:24}} animate={{opacity:1,y:0}} transition={{delay:0.1}} className="font-display text-4xl md:text-6xl text-white mb-5">Let&apos;s Build<br /><span className="gradient-text">Something Together</span></motion.h1>
          <motion.p initial={{opacity:0,y:24}} animate={{opacity:1,y:0}} transition={{delay:0.2}} className="text-text-secondary text-lg">Whether you have a project, partnership, or just want to connect — we&apos;d love to hear from you.</motion.p>
        </div>
      </section>

      <section className="section-padding relative">
        <div className="absolute inset-0 bg-brand-dark-secondary" /><div className="absolute inset-0 grid-pattern opacity-20" />
        <div className="container-custom relative z-10">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <AnimatedSection direction="right" className="lg:col-span-1">
              <div className="space-y-4">
                <div className="mb-8"><h2 className="font-display text-xl font-bold text-white mb-3">Get in Touch</h2><p className="text-text-secondary text-sm leading-relaxed">Reach out for partnerships, project inquiries, investment discussions, or general questions.</p></div>
                {info.map(({ icon:I, label, value, href, color }) => (
                  <GlassCard key={label} className="p-5 border border-white/[0.05]">
                    <div className="flex items-center gap-4">
                      <div className={`w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 ${imap[color]}`}><I className="w-5 h-5" /></div>
                      <div><div className="text-xs text-text-muted font-semibold uppercase tracking-wider mb-0.5">{label}</div>
                        {href ? <a href={href} className="text-sm text-white hover:text-brand-blue-light transition-colors">{value}</a> : <div className="text-sm text-white">{value}</div>}
                      </div>
                    </div>
                  </GlassCard>
                ))}
              </div>
            </AnimatedSection>

            <AnimatedSection direction="left" delay={0.1} className="lg:col-span-2">
              <GlassCard variant="gradient" className="p-8 border border-white/[0.06]">
                {submitted ? (
                  <div className="flex flex-col items-center justify-center py-12 text-center">
                    <div className="w-16 h-16 rounded-full bg-brand-green/10 border border-brand-green/20 flex items-center justify-center mb-5"><Check className="w-8 h-8 text-brand-green" /></div>
                    <h3 className="font-display text-xl font-bold text-white mb-2">Message Sent!</h3>
                    <p className="text-text-secondary text-sm mb-6">Thanks for reaching out. We&apos;ll respond within 24 hours.</p>
                    <button onClick={() => setSubmitted(false)} className="text-sm text-brand-blue-light hover:text-white transition-colors">Send another message</button>
                  </div>
                ) : (
                  <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
                    <div><h3 className="font-display text-lg font-bold text-white mb-1">Send a Message</h3><p className="text-text-muted text-sm">All fields are required.</p></div>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
                      <div><label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Full Name</label><input {...register("name")} placeholder="Your name" className="input-brand" />{errors.name && <p className="mt-1.5 text-xs text-red-400">{errors.name.message}</p>}</div>
                      <div><label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Email</label><input {...register("email")} type="email" placeholder="your@email.com" className="input-brand" />{errors.email && <p className="mt-1.5 text-xs text-red-400">{errors.email.message}</p>}</div>
                    </div>
                    <div><label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Subject</label><input {...register("subject")} placeholder="What is this about?" className="input-brand" />{errors.subject && <p className="mt-1.5 text-xs text-red-400">{errors.subject.message}</p>}</div>
                    <div><label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Message</label><textarea {...register("message")} rows={5} placeholder="Tell us more..." className="input-brand resize-none" />{errors.message && <p className="mt-1.5 text-xs text-red-400">{errors.message.message}</p>}</div>
                    <GradientButton type="submit" variant="blue-purple" size="md" fullWidth loading={isSubmitting} icon={<Send className="w-4 h-4" />}>{isSubmitting ? "Sending..." : "Send Message"}</GradientButton>
                  </form>
                )}
              </GlassCard>
            </AnimatedSection>
          </div>
        </div>
      </section>
    </>
  );
}
