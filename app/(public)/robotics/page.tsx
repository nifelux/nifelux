"use client";
import { motion } from "framer-motion";
import { Bot, CircuitBoard, Radio, Gauge, Eye, Layers, Wrench, ArrowRight } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import SectionHeading from "@/components/common/SectionHeading";
import AnimatedSection, { StaggerContainer, StaggerItem } from "@/components/common/AnimatedSection";
import GradientButton from "@/components/common/GradientButton";

const areas = [
  { icon:CircuitBoard, title:"Embedded Systems", desc:"Low-level programming of microcontrollers for robotic control systems.", color:"blue" },
  { icon:Radio, title:"Sensor Integration", desc:"Integrating LiDAR, cameras, IMUs, and environmental sensors.", color:"purple" },
  { icon:Gauge, title:"Control Systems", desc:"PID controllers, state machines, and real-time motion planning.", color:"green" },
  { icon:Eye, title:"Computer Vision", desc:"Visual perception enabling robots to understand environments.", color:"blue" },
  { icon:Layers, title:"ROS Development", desc:"Building on Robot Operating System for distributed architectures.", color:"purple" },
  { icon:Wrench, title:"Prototyping", desc:"From concept to physical prototype with software intelligence.", color:"green" },
];
const milestones = [
  { phase:"01", title:"Foundation", status:"active", desc:"Establishing core robotics team, sourcing components, building first prototype frameworks." },
  { phase:"02", title:"First Prototype", status:"upcoming", desc:"Completing the first functional robotic prototype with sensor integration." },
  { phase:"03", title:"AI Integration", status:"upcoming", desc:"Embedding Nifelux AI systems into robotic platforms for intelligent behaviour." },
  { phase:"04", title:"Industrial Application", status:"upcoming", desc:"Deploying robotic systems into real industrial and educational environments." },
];
const imap: Record<string,string> = { blue:"bg-brand-blue/10 text-brand-blue-light", purple:"bg-brand-purple/10 text-brand-purple-light", green:"bg-brand-green/10 text-brand-green" };

export default function RoboticsPage() {
  return (
    <>
      <section className="relative min-h-[60vh] flex items-center overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark"><div className="absolute inset-0 bg-hero-gradient" /><div className="absolute inset-0 grid-pattern opacity-30" /></div>
        <div className="absolute top-1/3 right-1/5 w-80 h-80 orb orb-purple opacity-25 animate-float" />
        <div className="container-custom relative z-10 py-24 max-w-4xl">
          <motion.span initial={{opacity:0,y:12}} animate={{opacity:1,y:0}} className="badge-purple inline-flex mb-6"><span className="w-1.5 h-1.5 rounded-full bg-brand-purple-light animate-pulse" />Robotics Division</motion.span>
          <div className="flex items-start gap-5 mb-6">
            <div className="w-16 h-16 rounded-2xl bg-brand-purple/20 border border-brand-purple/30 flex items-center justify-center flex-shrink-0 mt-1"><Bot className="w-8 h-8 text-brand-purple-light" /></div>
            <motion.h1 initial={{opacity:0,y:24}} animate={{opacity:1,y:0}} transition={{delay:0.1}} className="font-display text-4xl md:text-6xl text-white">Machines That<br /><span className="gradient-text">Think and Act</span></motion.h1>
          </div>
          <motion.p initial={{opacity:0,y:24}} animate={{opacity:1,y:0}} transition={{delay:0.2}} className="text-text-secondary text-lg leading-relaxed max-w-2xl mb-8">Nifelux&apos;s robotics division builds the next generation of intelligent machines — combining hardware engineering with AI for Africa&apos;s industrial and educational landscape.</motion.p>
          <motion.div initial={{opacity:0,y:24}} animate={{opacity:1,y:0}} transition={{delay:0.3}} className="flex gap-3 flex-wrap">
            <GradientButton href="/contact" variant="blue-purple" size="md" icon={<ArrowRight className="w-4 h-4" />}>Collaborate With Us</GradientButton>
          </motion.div>
        </div>
      </section>

      <section className="section-padding relative">
        <div className="absolute inset-0 bg-brand-dark" />
        <div className="container-custom relative z-10">
          <SectionHeading badge="Engineering Domains" title="Robotics" titleHighlight="Capabilities" description="Deep technical expertise across the full robotics engineering stack." className="mb-14" />
          <StaggerContainer className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {areas.map((a) => { const I=a.icon; return (
              <StaggerItem key={a.title}>
                <GlassCard hover className="p-6 border border-white/[0.05] h-full">
                  <div className={`w-11 h-11 rounded-xl flex items-center justify-center mb-4 ${imap[a.color]}`}><I className="w-5 h-5" /></div>
                  <h3 className="font-display text-base font-bold text-white mb-2">{a.title}</h3>
                  <p className="text-text-muted text-sm leading-relaxed">{a.desc}</p>
                </GlassCard>
              </StaggerItem>
            ); })}
          </StaggerContainer>
        </div>
      </section>

      <section className="section-padding relative overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark-secondary" /><div className="absolute inset-0 dot-pattern opacity-20" />
        <div className="container-custom relative z-10">
          <SectionHeading badge="Development Roadmap" title="Building Toward" titleHighlight="The Future" className="mb-14" />
          <div className="max-w-3xl mx-auto relative">
            <div className="absolute left-6 top-0 bottom-0 w-px bg-gradient-to-b from-brand-blue via-brand-purple to-transparent" />
            <div className="space-y-6">
              {milestones.map((m, i) => (
                <AnimatedSection key={m.phase} delay={i*0.1}>
                  <div className="flex gap-6">
                    <div className="relative flex-shrink-0">
                      <div className={`w-12 h-12 rounded-full flex items-center justify-center font-display text-sm font-bold z-10 relative ${m.status==="active" ? "bg-brand-gradient text-white shadow-glow" : "bg-brand-card border border-white/10 text-text-muted"}`}>{m.phase}</div>
                      {m.status==="active" && <div className="absolute inset-0 rounded-full bg-brand-blue/30 animate-ping" />}
                    </div>
                    <GlassCard className={`flex-1 p-5 border ${m.status==="active" ? "border-brand-blue/30 bg-brand-blue/5" : "border-white/[0.05]"}`}>
                      <div className="flex items-center justify-between mb-2">
                        <h3 className="font-display text-base font-bold text-white">{m.title}</h3>
                        <span className={`text-xs px-2.5 py-1 rounded-full font-semibold ${m.status==="active" ? "bg-brand-green/10 text-brand-green" : "bg-white/[0.05] text-text-muted"}`}>{m.status==="active" ? "In Progress" : "Upcoming"}</span>
                      </div>
                      <p className="text-text-muted text-sm leading-relaxed">{m.desc}</p>
                    </GlassCard>
                  </div>
                </AnimatedSection>
              ))}
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
