"use client";
import { ButtonHTMLAttributes, forwardRef } from "react";
import Link from "next/link";
import { cn } from "@/utils/cn";
import { Loader2 } from "lucide-react";
interface GradientButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "blue-purple"|"green-blue"|"outline"|"ghost"; size?: "sm"|"md"|"lg";
  href?: string; external?: boolean; loading?: boolean; fullWidth?: boolean;
  icon?: React.ReactNode; iconPosition?: "left"|"right";
}
const GradientButton = forwardRef<HTMLButtonElement, GradientButtonProps>(
  ({ className, variant="blue-purple", size="md", href, external, loading, fullWidth, icon, iconPosition="right", children, disabled, ...props }, ref) => {
    const base = cn("relative inline-flex items-center justify-center gap-2 font-semibold rounded-xl border-0 transition-all duration-200 overflow-hidden whitespace-nowrap disabled:opacity-50 disabled:cursor-not-allowed focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-blue focus-visible:ring-offset-2 focus-visible:ring-offset-brand-dark",
      size==="sm"&&"text-sm px-4 py-2.5 h-9", size==="md"&&"text-sm px-5 py-3 h-11", size==="lg"&&"text-base px-7 py-3.5 h-12",
      variant==="blue-purple"&&"bg-gradient-to-r from-brand-blue to-brand-purple text-white hover:shadow-glow hover:-translate-y-0.5",
      variant==="green-blue"&&"bg-gradient-to-r from-brand-green to-brand-blue text-white hover:shadow-glow-green hover:-translate-y-0.5",
      variant==="outline"&&"bg-transparent text-white border border-white/10 hover:bg-white/[0.06] hover:border-white/20 hover:-translate-y-0.5",
      variant==="ghost"&&"bg-transparent text-text-secondary hover:text-white hover:bg-white/[0.05]",
      fullWidth&&"w-full", className);
    const content = loading ? <Loader2 className="w-4 h-4 animate-spin" /> : (
      <>{icon&&iconPosition==="left"&&<span className="flex-shrink-0">{icon}</span>}<span>{children}</span>{icon&&iconPosition==="right"&&<span className="flex-shrink-0">{icon}</span>}</>
    );
    if (href) return <Link href={href} target={external?"_blank":undefined} rel={external?"noopener noreferrer":undefined} className={base}>{content}</Link>;
    return <button ref={ref} className={base} disabled={disabled||loading} {...props}>{content}</button>;
  }
);
GradientButton.displayName = "GradientButton";
export default GradientButton;
