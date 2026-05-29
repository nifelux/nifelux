"use client";
import { motion } from "framer-motion";
import { ArrowRight, Bot, Cpu, Globe, Shield, Zap, BrainCircuit, Network, Layers, ChevronRight, TrendingUp } from "lucide-react";
import Link from "next/link";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import SectionHeading from "@/components/common/SectionHeading";
import AnimatedSection, { StaggerContainer, StaggerItem } from "@/components/common/AnimatedSection";

const services = [
  { icon:BrainCircuit, title:"Artificial Intelligence", desc:"Intelligent systems that learn, adapt, and solve complex real-world problems at production scale.", color:"blue", href:"/services" },
  { icon:Bot, title:"Robotics Engineering", desc:"Advanced robotic systems for industrial, educational, and research applications across Africa.", color:"purple", href:"/robotics" },
  { icon:Cpu, title:"Automation Systems", desc:"Intelligent automation platforms that eliminate manual processes and scale with your business.", color:"green", href:"/services" },
  { icon:Shield, title:"Digital Infrastructure", desc:"Secure, scalable cloud architecture and digital identity systems for the next generation.", color:"blue", href:"/services" },
  { icon:Network, title:"Smart Platforms", desc:"SaaS and enterprise platforms built with enterprise-grade engineering from day one.", color:"purple", href:"/services" },
  { icon:Layers, title:"Software Engineering", desc:"Full-stack development using modern technologies with clean architecture and production-ready standards.", color:"green", href:"/services" },
];
const cmap: Record<string,"blue"|"purple"|"green"> = { blue:"blue", purple:"purple", green:"green" };
const gradMap: Record<string, string> = { blue:"from-brand-blue/10 to-transparent border-brand-blue/20 group-hover:border-brand-blue/40", purple:"from-brand-purple/10 to-transparent border-brand-purple/20 group-hover:border-brand-purple/40", green:"from-brand-green/10 to-transparent border-brand-green/20 group-hover:border-brand-green/40" };
const imap: Record<string, string> = { blue:"bg-brand-blue/10 text-brand-blue-light", purple:"bg-brand-purple/10 text-brand-purple-light", green:"bg-brand-green/10 text-brand-green" };

export default function HomePage() {
  return (
    <>
      <section className="relative min-h-[100svh] flex items-center justify-center overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark"><div className="absolute inset-0 bg-hero-gradient" /><div className="absolute inset-0 dot-pattern opacity-40" /></div>
        <div className="absolute top-1/4 left-1/4 w-96 h-96 orb orb-blue opacity-40 animate-float-slow" />
        <div className="absolute top-1/3 right-1/4 w-72 h-72 orb orb-purple opacity-30 animate-float" style={{ animationDelay:"2s" }} />
        <div className="container-custom relative z-10 py-24">
          <div className="flex flex-col items-center text-center max-w-5xl mx-auto">
            <motion.span initial={{ opacity:0, y:16 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.5 }} className="badge-brand mb-6">
              <span className="w-1.5 h-1.5 rounded-full bg-brand-green animate-pulse" />Africa&apos;s Future Technology Company
            </motion.span>
            <motion.h1 initial={{ opacity:0, y:24 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.6, delay:0.1 }}
              className="font-display text-[2.8rem] sm:text-[3.5rem] md:text-[4.5rem] lg:text-[5.5rem] leading-[1.05] tracking-tight text-white mb-6">
              Intelligent Systems<br /><span className="gradient-text">for Africa&apos;s</span><br />Future
            </motion.h1>
            <motion.p initial={{ opacity:0, y:24 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.6, delay:0.2 }} className="text-text-secondary text-base sm:text-lg md:text-xl leading-relaxed max-w-2xl mb-10">
              Nifelux Technologies builds world-class AI systems, robotics solutions, automation platforms, and digital infrastructure for Africa and the global future.
            </motion.p>
            <motion.div initial={{ opacity:0, y:24 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.6, delay:0.3 }} className="flex flex-col sm:flex-row items-center gap-3 mb-16">
              <GradientButton href="/services" variant="blue-purple" size="lg" icon={<ArrowRight className="w-5 h-5" />}>Explore Our Systems</GradientButton>
              <GradientButton href="/about" variant="outline" size="lg" icon={<ChevronRight className="w-5 h-5" />}>Our Vision</GradientButton>
            </motion.div>
            <motion.div initial={{ opacity:0, y:24 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.6, delay:0.4 }} className="grid grid-cols-2 sm:grid-cols-4 gap-4 w-full max-w-3xl">
              {[{ v:"∞", l:"Possibilities", i:TrendingUp }, { v:"100%", l:"Nigeria-Built", i:Globe }, { v:"AI+", l:"Powered Systems", i:BrainCircuit }, { v:"Next", l:"Generation Ready", i:Zap }].map(({ v, l, i:I }) => (
                <div key={l} className="glass-card p-4 flex flex-col items-center gap-2">
                  <I className="w-5 h-5 text-brand-blue-light" />
                  <span className="font-display text-2xl font-bold text-white">{v}</span>
                  <span className="text-text-muted text-xs text-center">{l}</span>
                </div>
              ))}
            </motion.div>
          </div>
        </div>
        <motion.div initial={{ opacity:0 }} animate={{ opacity:1 }} transition={{ delay:1 }} className="absolute bottom-8 left-1/2 -translate-x-1/2 flex flex-col items-center gap-2">
          <span className="text-text-muted text-xs tracking-widest uppercase">Scroll</span>
          <motion.div animate={{ y:[0,6,0] }} transition={{ duration:1.5, repeat:Infinity }} className="w-0.5 h-8 bg-gradient-to-b from-brand-blue to-transparent rounded-full" />
        </motion.div>
      </section>

      <section className="section-padding relative overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark-secondary" /><div className="absolute inset-0 grid-pattern opacity-30" />
        <div className="container-custom relative z-10">
          <SectionHeading badge="What We Build" title="Systems That Shape" titleHighlight="Tomorrow" description="From AI infrastructure to robotics platforms, every system we build is engineered for scale, security, and real-world impact." className="mb-16" />
          <StaggerContainer className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {services.map((s) => {
              const I = s.icon;
              return (
                <StaggerItem key={s.title}>
                  <Link href={s.href} className="block group">
                    <GlassCard hover className={`p-6 h-full bg-gradient-to-br ${gradMap[s.color]} border`}>
                      <div className={`w-11 h-11 rounded-xl flex items-center justify-center mb-4 transition-colors ${imap[s.color]}`}><I className="w-5 h-5" /></div>
                      <h3 className="font-display text-base font-bold text-white mb-2">{s.title}</h3>
                      <p className="text-text-secondary text-sm leading-relaxed mb-4">{s.desc}</p>
                      <div className="flex items-center gap-1.5 text-xs font-medium text-text-muted group-hover:text-brand-blue-light transition-colors">Learn more <ArrowRight className="w-3.5 h-3.5 group-hover:translate-x-1 transition-transform" /></div>
                    </GlassCard>
                  </Link>
                </StaggerItem>
              );
            })}
          </StaggerContainer>
        </div>
      </section>

      <section className="section-padding relative overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark" />
        <div className="container-custom relative z-10 text-center">
          <AnimatedSection>
            <GlassCard variant="gradient" className="max-w-4xl mx-auto p-10 md:p-16 border border-white/[0.06]">
              <div className="text-7xl font-display text-brand-blue/20 leading-none mb-4">&ldquo;</div>
              <blockquote className="font-display text-xl md:text-2xl text-white leading-relaxed mb-8">We are not building for today — we are building the systems that will power Africa&apos;s most ambitious future.</blockquote>
              <div className="flex flex-col items-center gap-2">
                <div className="w-12 h-px bg-gradient-to-r from-transparent via-white/30 to-transparent" />
                <div className="text-sm font-semibold text-white">Oluwanifemi Abdullahi Olude</div>
                <div className="text-xs text-text-muted">Founder &amp; CEO, Nifelux Technologies</div>
              </div>
            </GlassCard>
          </AnimatedSection>
        </div>
      </section>

      <section className="section-padding relative overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark-secondary" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[400px] orb orb-blue opacity-20" />
        <div className="container-custom relative z-10 text-center">
          <AnimatedSection>
            <span className="badge-brand mb-6 inline-flex"><span className="w-1.5 h-1.5 rounded-full bg-brand-blue-light animate-pulse" />Get In Touch</span>
            <h2 className="font-display text-4xl md:text-5xl text-white mb-6">Ready to Build the <span className="gradient-text">Future Together?</span></h2>
            <p className="text-text-secondary text-lg leading-relaxed mb-10 max-w-xl mx-auto">Whether you&apos;re a partner, investor, or someone who shares the vision — we want to hear from you.</p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
              <GradientButton href="/contact" variant="blue-purple" size="lg" icon={<ArrowRight className="w-5 h-5" />}>Contact Nifelux</GradientButton>
              <GradientButton href="/support" variant="green-blue" size="lg" icon={<Zap className="w-5 h-5" />} iconPosition="left">Support Our Mission</GradientButton>
            </div>
          </AnimatedSection>
        </div>
      </section>
    </>
  );
}
