"use client";
import { motion } from "framer-motion";
import { cn } from "@/utils/cn";
interface SectionHeadingProps { badge?: string; title: string; titleHighlight?: string; description?: string; align?: "left"|"center"|"right"; className?: string; gradient?: "blue-purple"|"green-blue"; }
export default function SectionHeading({ badge, title, titleHighlight, description, align="center", className, gradient="blue-purple" }: SectionHeadingProps) {
  const alignClass = { left:"items-start text-left", center:"items-center text-center", right:"items-end text-right" }[align];
  return (
    <motion.div initial={{ opacity:0, y:20 }} whileInView={{ opacity:1, y:0 }} viewport={{ once:true, margin:"-80px" }} transition={{ duration:0.5 }} className={cn("flex flex-col gap-4", alignClass, className)}>
      {badge && <span className="badge-brand"><span className="w-1.5 h-1.5 rounded-full bg-brand-blue-light animate-pulse-slow" />{badge}</span>}
      <h2 className="font-display text-3xl md:text-4xl lg:text-5xl text-white">
        {title} {titleHighlight && <span className={gradient==="blue-purple"?"gradient-text":"gradient-text-green"}>{titleHighlight}</span>}
      </h2>
      {description && <p className={cn("text-text-secondary text-base md:text-lg leading-relaxed", align==="center"&&"max-w-2xl")}>{description}</p>}
    </motion.div>
  );
}
