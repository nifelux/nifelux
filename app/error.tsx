"use client";
import { useEffect } from "react";
import { AlertTriangle, RefreshCw } from "lucide-react";
import GradientButton from "@/components/common/GradientButton";

export default function Error({ error, reset }: { error: Error & { digest?: string }; reset: () => void }) {
  useEffect(() => { console.error(error); }, [error]);
  return (
    <div className="min-h-screen bg-brand-dark flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-hero-gradient" />
      <div className="relative z-10 text-center max-w-md">
        <div className="w-16 h-16 rounded-2xl bg-red-500/10 border border-red-500/20 flex items-center justify-center mx-auto mb-6">
          <AlertTriangle className="w-8 h-8 text-red-400" />
        </div>
        <h1 className="font-display text-2xl font-bold text-white mb-3">Something went wrong</h1>
        <p className="text-text-muted text-sm leading-relaxed mb-8">
          An unexpected error occurred. Please try again or contact us if the problem persists.
        </p>
        <div className="flex flex-col sm:flex-row gap-3 justify-center">
          <GradientButton variant="blue-purple" size="md" onClick={reset} icon={<RefreshCw className="w-4 h-4" />} iconPosition="left">
            Try Again
          </GradientButton>
          <GradientButton href="/" variant="outline" size="md">Go Home</GradientButton>
        </div>
        {error.digest && <p className="text-text-accent text-xs mt-6 font-mono">Error: {error.digest}</p>}
      </div>
    </div>
  );
}
