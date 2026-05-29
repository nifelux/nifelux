"use client";
import { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X, ChevronRight, Zap } from "lucide-react";
import { cn } from "@/utils/cn";

const navLinks = [
  { label:"Home", href:"/" }, { label:"About", href:"/about" }, { label:"Services", href:"/services" },
  { label:"Robotics", href:"/robotics" }, { label:"Projects", href:"/projects" },
  { label:"Certifications", href:"/certifications" }, { label:"Contact", href:"/contact" },
];

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);
  const pathname = usePathname();
  useEffect(() => { const fn = () => setScrolled(window.scrollY > 20); window.addEventListener("scroll", fn, { passive:true }); return () => window.removeEventListener("scroll", fn); }, []);
  useEffect(() => { setOpen(false); }, [pathname]);
  useEffect(() => { document.body.style.overflow = open ? "hidden" : ""; return () => { document.body.style.overflow = ""; }; }, [open]);
  return (
    <>
      <motion.header initial={{ y:-20, opacity:0 }} animate={{ y:0, opacity:1 }} transition={{ duration:0.5 }}
        className={cn("fixed top-0 left-0 right-0 z-50 transition-all duration-300", scrolled?"bg-brand-dark/80 backdrop-blur-xl border-b border-white/[0.06]":"bg-transparent")}>
        <div className="container-custom">
          <div className="flex items-center justify-between h-16">
            <Link href="/" className="flex items-center gap-2.5 group">
              <div className="w-8 h-8 rounded-lg bg-brand-gradient flex items-center justify-center shadow-glow-sm"><Zap className="w-4 h-4 text-white" strokeWidth={2.5} /></div>
              <div className="flex flex-col leading-none">
                <span className="font-display text-base font-bold text-white tracking-tight">Nifelux</span>
                <span className="text-[10px] font-medium text-text-muted tracking-widest uppercase">Technologies</span>
              </div>
            </Link>
            <nav className="hidden md:flex items-center gap-1">
              {navLinks.map((link) => {
                const active = pathname === link.href;
                return (
                  <Link key={link.href} href={link.href} className={cn("relative px-4 py-2 text-sm font-medium rounded-lg transition-all", active?"text-white":"text-text-secondary hover:text-white")}>
                    {active && <motion.span layoutId="nav-active" className="absolute inset-0 bg-white/[0.06] rounded-lg" transition={{ type:"spring", stiffness:400, damping:30 }} />}
                    <span className="relative z-10">{link.label}</span>
                  </Link>
                );
              })}
            </nav>
            <div className="hidden md:flex items-center gap-3">
              <Link href="/support" className="text-sm font-medium text-text-secondary hover:text-white transition-colors">Support</Link>
              <Link href="/dashboard" className="btn-primary text-sm py-2 px-4">Portal <ChevronRight className="w-4 h-4 inline" /></Link>
            </div>
            <button onClick={() => setOpen(!open)} className="md:hidden w-10 h-10 rounded-lg glass flex items-center justify-center text-white">
              {open ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
            </button>
          </div>
        </div>
      </motion.header>
      <AnimatePresence>
        {open && (
          <>
            <motion.div initial={{ opacity:0 }} animate={{ opacity:1 }} exit={{ opacity:0 }} onClick={() => setOpen(false)} className="fixed inset-0 z-40 bg-brand-dark/60 backdrop-blur-sm md:hidden" />
            <motion.div initial={{ x:"100%" }} animate={{ x:0 }} exit={{ x:"100%" }} transition={{ type:"spring", stiffness:300, damping:30 }}
              className="fixed top-0 right-0 bottom-0 z-50 w-72 bg-brand-dark-secondary border-l border-white/[0.06] flex flex-col md:hidden">
              <div className="flex items-center justify-between p-5 border-b border-white/[0.06]">
                <span className="font-display font-bold text-white">Nifelux</span>
                <button onClick={() => setOpen(false)} className="w-8 h-8 glass rounded-lg flex items-center justify-center text-text-muted"><X className="w-4 h-4" /></button>
              </div>
              <nav className="flex-1 p-4 space-y-1">
                {navLinks.map((link) => (
                  <Link key={link.href} href={link.href} className={cn("flex items-center px-4 py-3 rounded-xl text-sm font-medium transition-all", pathname===link.href?"bg-white/[0.08] text-white":"text-text-secondary hover:text-white hover:bg-white/[0.04]")}>{link.label}</Link>
                ))}
              </nav>
              <div className="p-4 border-t border-white/[0.06] space-y-3">
                <Link href="/support" className="btn-secondary w-full text-sm justify-center flex">Support Us</Link>
                <Link href="/dashboard" className="btn-primary w-full text-sm justify-center">Portal</Link>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
}
