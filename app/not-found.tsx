import Link from "next/link";
import { ArrowLeft, Search } from "lucide-react";
import GradientButton from "@/components/common/GradientButton";

export default function NotFound() {
  return (
    <div className="min-h-screen bg-brand-dark flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-hero-gradient" />
      <div className="absolute inset-0 dot-pattern opacity-20" />
      <div className="relative z-10 text-center max-w-lg">
        <div className="font-display text-[120px] font-bold leading-none text-white/5 select-none mb-4">404</div>
        <div className="w-14 h-14 rounded-2xl bg-brand-blue/10 border border-brand-blue/20 flex items-center justify-center mx-auto mb-5 -mt-8">
          <Search className="w-7 h-7 text-brand-blue-light" />
        </div>
        <h1 className="font-display text-2xl font-bold text-white mb-3">Page Not Found</h1>
        <p className="text-text-muted text-sm leading-relaxed mb-8 max-w-sm mx-auto">
          The page you&apos;re looking for doesn&apos;t exist or has been moved.
        </p>
        <div className="flex flex-col sm:flex-row gap-3 justify-center">
          <GradientButton href="/" variant="blue-purple" size="md" icon={<ArrowLeft className="w-4 h-4" />} iconPosition="left">
            Back to Home
          </GradientButton>
          <GradientButton href="/contact" variant="outline" size="md">Contact Us</GradientButton>
        </div>
      </div>
    </div>
  );
}
