"use client";
import Link from "next/link";
import { Zap, Twitter, Linkedin, Github, Mail, MapPin, ArrowUpRight } from "lucide-react";
const footerLinks = {
  Company: [{ label:"About", href:"/about" }, { label:"Services", href:"/services" }, { label:"Projects", href:"/projects" }, { label:"Robotics", href:"/robotics" }, { label:"Contact", href:"/contact" }],
  Resources: [{ label:"Certifications", href:"/certifications" }, { label:"Support Us", href:"/support" }, { label:"Dashboard", href:"/dashboard" }],
  Legal: [{ label:"Privacy Policy", href:"/privacy" }, { label:"Terms of Service", href:"/terms" }],
};
const socials = [
  { icon:Twitter, href:"https://twitter.com/nifelux", label:"Twitter" },
  { icon:Linkedin, href:"https://linkedin.com/company/nifelux", label:"LinkedIn" },
  { icon:Github, href:"https://github.com/nifelux", label:"GitHub" },
  { icon:Mail, href:"mailto:hello@nifelux.com", label:"Email" },
];
export default function Footer() {
  return (
    <footer className="relative border-t border-white/[0.06] bg-brand-dark-secondary overflow-hidden">
      <div className="absolute bottom-0 left-1/4 w-96 h-64 orb orb-blue opacity-20 pointer-events-none" />
      <div className="container-custom py-16 relative z-10">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-12 mb-12">
          <div className="lg:col-span-2">
            <Link href="/" className="flex items-center gap-2.5 w-fit mb-5">
              <div className="w-9 h-9 rounded-xl bg-brand-gradient flex items-center justify-center shadow-glow-sm"><Zap className="w-4 h-4 text-white" strokeWidth={2.5} /></div>
              <div className="flex flex-col leading-none"><span className="font-display text-lg font-bold text-white">Nifelux</span><span className="text-[10px] text-text-muted tracking-widest uppercase">Technologies</span></div>
            </Link>
            <p className="text-text-secondary text-sm leading-relaxed max-w-xs mb-5">Building intelligent digital systems, AI, robotics, and automation for Africa and the global future.</p>
            <div className="flex items-center gap-1.5 text-text-muted text-xs mb-5"><MapPin className="w-3.5 h-3.5 text-brand-green" /><span>Lagos, Nigeria</span></div>
            <div className="flex items-center gap-2">
              {socials.map(({ icon:I, href, label }) => (
                <a key={label} href={href} target={href.startsWith("http")?"_blank":undefined} rel={href.startsWith("http")?"noopener noreferrer":undefined} className="w-9 h-9 rounded-lg glass flex items-center justify-center text-text-muted hover:text-white hover:bg-white/10 transition-all">
                  <I className="w-4 h-4" />
                </a>
              ))}
            </div>
          </div>
          {Object.entries(footerLinks).map(([cat, links]) => (
            <div key={cat}>
              <h4 className="text-xs font-semibold text-text-muted uppercase tracking-widest mb-4">{cat}</h4>
              <ul className="space-y-3">
                {links.map((link) => (
                  <li key={link.href}>
                    <Link href={link.href} className="text-sm text-text-secondary hover:text-white transition-colors flex items-center gap-1 group">
                      {link.label}<ArrowUpRight className="w-3 h-3 opacity-0 group-hover:opacity-100 transition-opacity" />
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
        <div className="section-divider mb-8" />
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="text-text-muted text-xs">© {new Date().getFullYear()} Nifelux Technologies. All rights reserved.</p>
          <p className="text-text-muted text-xs">Built in <span className="text-brand-green font-medium">Nigeria</span> for the world 🌍</p>
        </div>
      </div>
    </footer>
  );
}
