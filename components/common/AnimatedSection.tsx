"use client";
import { motion, Variants } from "framer-motion";
import { cn } from "@/utils/cn";
const V: Record<string, Variants> = {
  up: { hidden:{ opacity:0, y:32 }, visible:{ opacity:1, y:0 } },
  down: { hidden:{ opacity:0, y:-24 }, visible:{ opacity:1, y:0 } },
  left: { hidden:{ opacity:0, x:32 }, visible:{ opacity:1, x:0 } },
  right: { hidden:{ opacity:0, x:-32 }, visible:{ opacity:1, x:0 } },
  none: { hidden:{ opacity:0 }, visible:{ opacity:1 } },
};
interface Props { children: React.ReactNode; className?: string; delay?: number; direction?: "up"|"down"|"left"|"right"|"none"; duration?: number; }
export default function AnimatedSection({ children, className, delay=0, direction="up", duration=0.55 }: Props) {
  return (
    <motion.div initial="hidden" whileInView="visible" viewport={{ once:true, margin:"-60px" }} variants={V[direction]} transition={{ duration, delay, ease:[0.21,0.47,0.32,0.98] }} className={cn(className)}>
      {children}
    </motion.div>
  );
}
export function StaggerContainer({ children, className, stagger=0.08, delay=0 }: { children:React.ReactNode; className?:string; stagger?:number; delay?:number }) {
  return (
    <motion.div initial="hidden" whileInView="visible" viewport={{ once:true, margin:"-60px" }}
      variants={{ hidden:{}, visible:{ transition:{ staggerChildren:stagger, delayChildren:delay } } }} className={cn(className)}>
      {children}
    </motion.div>
  );
}
export function StaggerItem({ children, className, direction="up" }: { children:React.ReactNode; className?:string; direction?:keyof typeof V }) {
  return <motion.div variants={V[direction]} transition={{ duration:0.5, ease:[0.21,0.47,0.32,0.98] }} className={cn(className)}>{children}</motion.div>;
}
