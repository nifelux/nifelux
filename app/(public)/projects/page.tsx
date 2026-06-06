"use client";
import { motion } from "framer-motion";
import { BrainCircuit, Bot, Layers, Cpu, Globe, Clock } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import AnimatedSection, { StaggerContainer, StaggerItem } from "@/components/common/AnimatedSection";

const projects = [
  { icon:BrainCircuit, title:"Nifelux AI Platform", cat:"Artificial Intelligence", status:"In Development", statusColor:"blue", desc:"A scalable AI inference platform for enterprise use — running, managing, and monitoring multiple AI models through a unified API interface.", tags:["Next.js","Python","Supabase","ML"], color:"blue" },
  { icon:Bot, title:"NifeBot v1", cat:"Robotics", status:"Prototyping", statusColor:"purple", desc:"The first Nifelux robotic prototype — an intelligent mobile robot for research, education, and automation in Nigerian institutions.", tags:["ROS","Python","Embedded C","Computer Vision"], color:"purple" },
  { icon:Layers, title:"Nifelux Platform", cat:"Smart Platform", status:"Active", statusColor:"green", desc:"The core Nifelux Technologies platform — digital identity management, certifications, admin dashboard, and QR verification infrastructure.", tags:["Next.js 15","TypeScript","Supabase","PostgreSQL"], color:"green" },
  { icon:Cpu, title:"AutoFlow", cat:"Automation", status:"Planning", statusColor:"blue", desc:"An intelligent business process automation platform for Nigerian businesses to eliminate manual workflows through event-driven automation.", tags:["Node.js","TypeScript","Workflow Engine"], color:"blue" },
  { icon:Globe, title:"NifeluxID", cat:"Digital Identity", status:"In Development", statusColor:"purple", desc:"A secure digital identity and verification system enabling tamper-proof QR-verified digital IDs for institutions and individuals.", tags:["Next.js","QR Technology","PostgreSQL"], color:"purple" },
  { icon:BrainCircuit, title:"EduAI Nigeria", cat:"EdTech / AI", status:"Research", statusColor:"green", desc:"An AI-powered educational platform for African learners — featuring adaptive learning paths and curriculum built for local context.", tags:["AI","EdTech","NLP","React"], color:"green" },
];

const statusBadge: Record<string,string> = { green:"bg-brand-green/10 text-brand-green border-brand-green/20", blue:"bg-brand-blue/10 text-brand-blue-light border-brand-blue/20", purple:"bg-brand-purple/10 text-brand-purple-light border-brand-purple/20" };
const imap: Record<string,string> = { blue:"bg-brand-blue/10 text-brand-blue-light", purple:"bg-brand-purple/10 text-brand-purple-light", green:"bg-brand-green/10 text-brand-green" };
const gradMap: Record<string,string> = { blue:"border-brand-blue/15 from-brand-blue/8", purple:"border-brand-purple/15 from-brand-purple/8", green:"border-brand-green/15 from-brand-green/8" };

export default function ProjectsPage() {
  return (
    <>
      <section className="relative min-h-[50vh] flex items-center overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark"><div className="absolute inset-0 bg-hero-gradient" /><div className="absolute inset-0 dot-pattern opacity-25" /></div>
        <div className="container-custom relative z-10 py-24 max-w-3xl">
          <motion.span initial={{opacity:0,y:12}} animate={{opacity:1,y:0}} className="badge-brand inline-flex mb-6"><span className="w-1.5 h-1.5 rounded-full bg-brand-blue-light animate-pulse" />Projects</motion.span>
          <motion.h1 initial={{opacity:0,y:24}} animate={{opacity:1,y:0}} transition={{delay:0.1}} className="font-display text-4xl md:text-6xl text-white mb-6">What We&apos;re<br /><span className="gradient-text">Building</span></motion.h1>
          <motion.p initial={{opacity:0,y:24}} animate={{opacity:1,y:0}} transition={{delay:0.2}} className="text-text-secondary text-lg">A growing portfolio of intelligent systems, AI platforms, and digital infrastructure — all built in Nigeria for the world.</motion.p>
        </div>
      </section>

      <section className="section-padding relative">
        <div className="absolute inset-0 bg-brand-dark-secondary" />
        <div className="container-custom relative z-10">
          <StaggerContainer className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            {projects.map((p) => { const I=p.icon; return (
              <StaggerItem key={p.title}>
                <GlassCard hover className={`p-6 h-full border bg-gradient-to-br ${gradMap[p.color]} to-transparent flex flex-col`}>
                  <div className="flex items-start justify-between mb-5">
                    <div className={`w-11 h-11 rounded-xl flex items-center justify-center ${imap[p.color]}`}><I className="w-5 h-5" /></div>
                    <span className={`text-xs font-semibold px-2.5 py-1 rounded-full border ${statusBadge[p.statusColor]}`}>{p.status}</span>
                  </div>
                  <div className="text-xs font-semibold text-text-muted uppercase tracking-wider mb-2">{p.cat}</div>
                  <h3 className="font-display text-base font-bold text-white mb-3">{p.title}</h3>
                  <p className="text-text-secondary text-sm leading-relaxed flex-1 mb-4">{p.desc}</p>
                  <div className="flex flex-wrap gap-2">
                    {p.tags.map((t) => <span key={t} className="text-xs px-2.5 py-1 bg-white/[0.04] border border-white/[0.07] rounded-lg text-text-muted">{t}</span>)}
                  </div>
                </GlassCard>
              </StaggerItem>
            ); })}
          </StaggerContainer>

          <AnimatedSection className="mt-10">
            <GlassCard className="p-6 border border-white/[0.05] flex flex-col sm:flex-row items-center gap-4 justify-between">
              <div className="flex items-center gap-3">
                <Clock className="w-5 h-5 text-text-muted flex-shrink-0" />
                <p className="text-text-secondary text-sm">More projects in research and planning. <span className="text-white font-semibold">New systems ship regularly.</span></p>
              </div>
              <GradientButton href="/contact" variant="outline" size="sm">Collaborate</GradientButton>
            </GradientButton>
          </AnimatedSection>
        </div>
      </section>
    </>
  );
}
