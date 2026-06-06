"use client";
import { motion } from "framer-motion";
import { BrainCircuit, Bot, Cpu, Shield, Network, Layers, Check, ArrowRight } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import AnimatedSection from "@/components/common/AnimatedSection";
import GradientButton from "@/components/common/GradientButton";

const services = [
  { id:"ai", icon:BrainCircuit, title:"Artificial Intelligence", tagline:"Systems that think, learn, and adapt.", description:"We design and build intelligent AI systems — from machine learning models to large-scale inference pipelines built for production scale.", caps:["Machine Learning Systems","Natural Language Processing","Computer Vision","AI API Development","Intelligent Automation","Data Pipelines & MLOps"], color:"blue" },
  { id:"robotics", icon:Bot, title:"Robotics Engineering", tagline:"Building machines that move Africa forward.", description:"Our robotics division designs intelligent robotic systems for industrial, educational, and research environments across Africa.", caps:["Robotic System Design","Embedded Systems","Sensor Integration","Control Systems","Robot Operating System (ROS)","Prototype Development"], color:"purple" },
  { id:"automation", icon:Cpu, title:"Automation Systems", tagline:"Eliminating manual bottlenecks at scale.", description:"We build intelligent automation platforms that eliminate repetitive processes and reduce human error across businesses.", caps:["Business Process Automation","Workflow Intelligence","RPA Solutions","Integration Systems","Event-Driven Architecture","Automated Testing"], color:"green" },
  { id:"infrastructure", icon:Shield, title:"Digital Infrastructure", tagline:"The secure backbone of your digital future.", description:"From cloud architecture to digital identity systems, we build the infrastructure that powers secure and scalable digital operations.", caps:["Cloud Architecture","Digital Identity Systems","API Infrastructure","Authentication Systems","Security Architecture","Database Optimization"], color:"blue" },
  { id:"platforms", icon:Network, title:"Smart Platforms", tagline:"SaaS and enterprise systems built to scale.", description:"We design and develop enterprise SaaS platforms and admin dashboards with scalable, maintainable architecture from day one.", caps:["SaaS Platform Development","Admin Dashboard Systems","Multi-Tenant Architecture","Analytics & Reporting","Role-Based Access Control","API-First Design"], color:"purple" },
  { id:"software", icon:Layers, title:"Software Engineering", tagline:"Production-grade code. Every time.", description:"Full-stack software engineering using modern technologies — clean, typed, tested, and maintainable code that scales.", caps:["Next.js / React Applications","TypeScript Development","REST & GraphQL APIs","Mobile-First Development","Performance Optimization","Code Architecture & Review"], color:"green" },
];
const imap: Record<string,string> = { blue:"bg-brand-blue/10 text-brand-blue-light", purple:"bg-brand-purple/10 text-brand-purple-light", green:"bg-brand-green/10 text-brand-green" };
const bmap: Record<string,string> = { blue:"border-brand-blue/20 from-brand-blue/8 to-transparent", purple:"border-brand-purple/20 from-brand-purple/8 to-transparent", green:"border-brand-green/20 from-brand-green/8 to-transparent" };
const cmap: Record<string,string> = { blue:"text-brand-blue-light", purple:"text-brand-purple-light", green:"text-brand-green" };

export default function ServicesPage() {
  return (
    <>
      <section className="relative min-h-[50vh] flex items-center overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark"><div className="absolute inset-0 bg-hero-gradient" /><div className="absolute inset-0 dot-pattern opacity-30" /></div>
        <div className="container-custom relative z-10 py-24 max-w-3xl">
          <motion.span initial={{opacity:0,y:12}} animate={{opacity:1,y:0}} className="badge-brand inline-flex mb-6"><span className="w-1.5 h-1.5 rounded-full bg-brand-blue-light animate-pulse" />Our Services</motion.span>
          <motion.h1 initial={{opacity:0,y:24}} animate={{opacity:1,y:0}} transition={{delay:0.1}} className="font-display text-4xl md:text-6xl text-white mb-6">Systems Built for<br /><span className="gradient-text">The Real World</span></motion.h1>
          <motion.p initial={{opacity:0,y:24}} animate={{opacity:1,y:0}} transition={{delay:0.2}} className="text-text-secondary text-lg">Six core technology domains. Enterprise engineering. Built in Nigeria for the world.</motion.p>
        </div>
      </section>
      <section className="section-padding relative">
        <div className="absolute inset-0 bg-brand-dark-secondary" />
        <div className="container-custom relative z-10 space-y-5">
          {services.map((s,i) => { const I=s.icon; return (
            <AnimatedSection key={s.id} delay={i*0.04}>
              <GlassCard id={s.id} className={`p-8 border bg-gradient-to-br ${bmap[s.color]} scroll-mt-24`}>
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 items-start">
                  <div className="lg:col-span-2">
                    <div className="flex items-start gap-4 mb-5">
                      <div className={`w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0 ${imap[s.color]}`}><I className="w-6 h-6" /></div>
                      <div><h2 className="font-display text-xl font-bold text-white">{s.title}</h2><p className="text-sm text-text-muted mt-0.5">{s.tagline}</p></div>
                    </div>
                    <p className="text-text-secondary leading-relaxed">{s.description}</p>
                  </div>
                  <div>
                    <div className="text-xs font-semibold text-text-muted uppercase tracking-widest mb-3">Capabilities</div>
                    <ul className="space-y-2">
                      {s.caps.map((c) => <li key={c} className="flex items-center gap-2.5 text-sm text-text-secondary"><Check className={`w-3.5 h-3.5 flex-shrink-0 ${cmap[s.color]}`} />{c}</li>)}
                    </ul>
                  </div>
                </div>
              </GlassCard>
            </AnimatedSection>
          ); })}
        </div>
      </section>
      <section className="py-20 relative overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark" />
        <div className="container-custom relative z-10 text-center">
          <AnimatedSection>
            <h2 className="font-display text-4xl text-white mb-4">Have a Project in Mind?</h2>
            <p className="text-text-secondary text-lg mb-8 max-w-xl mx-auto">Tell us what you&apos;re building and let&apos;s explore how Nifelux can make it real.</p>
            <GradientButton href="/contact" variant="blue-purple" size="lg" icon={<ArrowRight className="w-5 h-5" />}>Start a Conversation</GradientButton>
          </AnimatedSection>
        </div>
      </section>
    </>
  );
}
