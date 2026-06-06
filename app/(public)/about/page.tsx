"use client";
import { motion } from "framer-motion";
import { Globe, Zap, BrainCircuit, Shield, TrendingUp, Target, Heart, Layers } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import SectionHeading from "@/components/common/SectionHeading";
import AnimatedSection, { StaggerContainer, StaggerItem } from "@/components/common/AnimatedSection";
import GradientButton from "@/components/common/GradientButton";

const values = [
  { icon:Zap, label:"Innovation", desc:"Constantly pushing the frontier of what is possible." },
  { icon:BrainCircuit, label:"Intelligence", desc:"AI and smart systems at the core of everything we build." },
  { icon:TrendingUp, label:"Impact", desc:"Technology that creates measurable, lasting real-world change." },
  { icon:Shield, label:"Security", desc:"Enterprise-grade security baked into every layer." },
  { icon:Layers, label:"Scalability", desc:"Built to grow from MVP to continent-scale infrastructure." },
  { icon:Globe, label:"Excellence", desc:"Global-standard engineering from Nigeria to the world." },
];

export default function AboutPage() {
  return (
    <>
      <section className="relative min-h-[60vh] flex items-center overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark"><div className="absolute inset-0 bg-hero-gradient" /><div className="absolute inset-0 dot-pattern opacity-30" /></div>
        <div className="absolute top-1/2 left-1/4 w-80 h-80 orb orb-blue opacity-30 animate-float-slow" />
        <div className="container-custom relative z-10 py-24 max-w-4xl">
          <motion.span initial={{opacity:0,y:12}} animate={{opacity:1,y:0}} className="badge-brand inline-flex mb-6"><span className="w-1.5 h-1.5 rounded-full bg-brand-blue-light animate-pulse" />About Nifelux</motion.span>
          <motion.h1 initial={{opacity:0,y:24}} animate={{opacity:1,y:0}} transition={{delay:0.1}} className="font-display text-4xl md:text-6xl text-white mb-6">Building Africa&apos;s<br /><span className="gradient-text">Technology Future</span></motion.h1>
          <motion.p initial={{opacity:0,y:24}} animate={{opacity:1,y:0}} transition={{delay:0.2}} className="text-text-secondary text-lg leading-relaxed max-w-2xl">A futuristic Nigerian technology company building intelligent digital systems, AI solutions, robotics, and automation infrastructure for Africa and the world.</motion.p>
        </div>
      </section>

      <section className="section-padding relative">
        <div className="absolute inset-0 bg-brand-dark-secondary" />
        <div className="container-custom relative z-10">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-16">
            <AnimatedSection direction="right">
              <GlassCard variant="gradient" className="p-8 h-full border border-white/[0.06]">
                <div className="w-10 h-10 rounded-xl bg-brand-blue/10 flex items-center justify-center mb-5"><Target className="w-5 h-5 text-brand-blue-light" /></div>
                <h3 className="font-display text-xl font-bold text-white mb-3">Our Mission</h3>
                <p className="text-text-secondary leading-relaxed">To empower individuals and organizations through innovative technology, AI, robotics, and scalable digital infrastructure — transforming how Africa interacts with the digital world.</p>
              </GlassCard>
            </AnimatedSection>
            <AnimatedSection direction="left" delay={0.1}>
              <GlassCard variant="gradient" className="p-8 h-full border border-white/[0.06]">
                <div className="w-10 h-10 rounded-xl bg-brand-purple/10 flex items-center justify-center mb-5"><Globe className="w-5 h-5 text-brand-purple-light" /></div>
                <h3 className="font-display text-xl font-bold text-white mb-3">Our Vision</h3>
                <p className="text-text-secondary leading-relaxed">To become one of Africa&apos;s leading future technology companies by building intelligent systems that transform lives, businesses, education, and industries across the continent and globally.</p>
              </GlassCard>
            </AnimatedSection>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-14 items-center">
            <AnimatedSection direction="right">
              <GlassCard variant="gradient" className="p-10 border border-white/[0.06] relative overflow-hidden">
                <div className="absolute top-0 right-0 w-40 h-40 bg-brand-gradient opacity-10 blur-2xl rounded-full" />
                <div className="relative z-10">
                  <div className="w-14 h-14 rounded-2xl bg-brand-gradient flex items-center justify-center mb-6 shadow-glow"><Heart className="w-7 h-7 text-white" /></div>
                  <span className="badge-brand mb-4 inline-flex">Founder &amp; CEO</span>
                  <h3 className="font-display text-2xl md:text-3xl font-bold text-white mb-2">Oluwanifemi<br />Abdullahi Olude</h3>
                  <div className="w-12 h-0.5 bg-brand-gradient rounded-full my-5" />
                  <p className="text-text-secondary leading-relaxed text-sm">A Nigerian technology entrepreneur building future-ready intelligent systems, AI infrastructure, robotics, and scalable digital platforms that prove Nigeria belongs at the global frontier of technology.</p>
                </div>
              </GlassCard>
            </AnimatedSection>
            <AnimatedSection direction="left" delay={0.15}>
              <span className="badge-green inline-flex mb-6"><span className="w-1.5 h-1.5 rounded-full bg-brand-green animate-pulse" />The Company Story</span>
              <h2 className="font-display text-4xl md:text-5xl text-white mb-6">From Nigeria<br /><span className="gradient-text">To the World</span></h2>
              <div className="space-y-4 text-text-secondary leading-relaxed text-sm">
                <p>Nifelux Technologies was founded with one audacious belief: that Africa does not just have to consume the future — it can build it.</p>
                <p>Starting from Lagos, Nifelux is creating the AI systems and digital infrastructure that will power the next era of African innovation.</p>
                <p>Every system we build is a testament to what is possible when engineering excellence meets a continent-sized vision.</p>
              </div>
              <div className="mt-8"><GradientButton href="/contact" variant="blue-purple" size="md">Work With Us</GradientButton></div>
            </AnimatedSection>
          </div>
        </div>
      </section>

      <section className="section-padding relative">
        <div className="absolute inset-0 bg-brand-dark" />
        <div className="container-custom relative z-10">
          <SectionHeading badge="Core Values" title="The Principles That" titleHighlight="Drive Us" className="mb-14" />
          <StaggerContainer className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {values.map(({ icon:I, label, desc }) => (
              <StaggerItem key={label}>
                <GlassCard hover className="p-6 border border-white/[0.05]">
                  <div className="w-10 h-10 rounded-xl bg-brand-blue/10 flex items-center justify-center mb-4"><I className="w-5 h-5 text-brand-blue-light" /></div>
                  <h4 className="font-display text-base font-bold text-white mb-2">{label}</h4>
                  <p className="text-text-muted text-sm leading-relaxed">{desc}</p>
                </GlassCard>
              </StaggerItem>
            ))}
          </StaggerContainer>
        </div>
      </section>
    </>
  );
}
