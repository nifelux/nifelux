import { cn } from "@/utils/cn";
import { HTMLAttributes, forwardRef } from "react";
interface GlassCardProps extends HTMLAttributes<HTMLDivElement> { variant?: "default"|"bordered"|"gradient"|"elevated"; hover?: boolean; glow?: "blue"|"purple"|"green"|"none"; }
const GlassCard = forwardRef<HTMLDivElement, GlassCardProps>(({ className, variant="default", hover=false, glow="none", children, ...props }, ref) => (
  <div ref={ref} className={cn("relative rounded-2xl overflow-hidden transition-all duration-300",
    variant==="default"&&"glass-card", variant==="bordered"&&"gradient-border bg-brand-card",
    variant==="gradient"&&"bg-gradient-to-br from-white/[0.05] to-white/[0.02] border border-white/[0.06]",
    variant==="elevated"&&"bg-brand-card shadow-card border border-white/[0.05]",
    hover&&"hover:shadow-card-hover hover:-translate-y-1 cursor-pointer",
    glow==="blue"&&"hover:shadow-glow", glow==="purple"&&"hover:shadow-glow-purple", glow==="green"&&"hover:shadow-glow-green",
    className)} {...props}>{children}</div>
));
GlassCard.displayName = "GlassCard";
export default GlassCard;
