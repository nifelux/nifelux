import { cn } from "@/utils/cn";
export default function LoadingSpinner({ size="md", className }: { size?:"sm"|"md"|"lg"; className?:string }) {
  const s = { sm:"w-4 h-4 border-2", md:"w-8 h-8 border-2", lg:"w-12 h-12 border-2" }[size];
  return <div className={cn("rounded-full border-white/20 border-t-brand-blue animate-spin", s, className)} />;
}
