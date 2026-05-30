"use client";
import { useEffect, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { CheckCircle, XCircle, Loader2, ArrowRight } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";

type Status = "loading" | "success" | "failed";

export default function PaymentCallbackPage() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const reference = searchParams.get("reference");
  const [status, setStatus] = useState<Status>("loading");
  const [amount, setAmount] = useState<number | null>(null);

  useEffect(() => {
    if (!reference) { setStatus("failed"); return; }

    const checkPayment = async () => {
      try {
        const res = await fetch(`/api/payments?reference=${reference}`);
        const json = await res.json();
        if (json.success) {
          setAmount(json.data.amount);
          setStatus(json.data.status === "success" ? "success" : "failed");
        } else {
          setStatus("failed");
        }
      } catch {
        setStatus("failed");
      }
    };

    // Poll for 10 seconds to allow webhook to process
    const timer = setTimeout(checkPayment, 2000);
    return () => clearTimeout(timer);
  }, [reference]);

  return (
    <div className="min-h-screen bg-brand-dark flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-hero-gradient" />
      <div className="absolute inset-0 dot-pattern opacity-20" />
      <div className="relative z-10 w-full max-w-md">
        <GlassCard variant="gradient" className="p-10 border border-white/[0.06] text-center">
          {status === "loading" && (
            <>
              <Loader2 className="w-14 h-14 text-brand-blue-light mx-auto mb-5 animate-spin" />
              <h1 className="font-display text-xl font-bold text-white mb-2">Confirming Payment</h1>
              <p className="text-text-muted text-sm">Please wait while we verify your transaction...</p>
            </>
          )}

          {status === "success" && (
            <>
              <div className="w-16 h-16 rounded-2xl bg-brand-green/10 border border-brand-green/20 flex items-center justify-center mx-auto mb-5">
                <CheckCircle className="w-8 h-8 text-brand-green" />
              </div>
              <h1 className="font-display text-xl font-bold text-white mb-2">Payment Successful!</h1>
              {amount && (
                <p className="text-brand-green font-bold text-2xl mb-2">
                  ₦{amount.toLocaleString()}
                </p>
              )}
              <p className="text-text-muted text-sm mb-2">Reference: <span className="font-mono text-xs text-white">{reference}</span></p>
              <p className="text-text-muted text-sm mb-8">Thank you for supporting Nifelux Technologies. A receipt has been sent to your email.</p>
              <div className="flex flex-col gap-3">
                <GradientButton href="/dashboard" variant="blue-purple" size="md" icon={<ArrowRight className="w-4 h-4" />}>
                  Go to Dashboard
                </GradientButton>
                <GradientButton href="/" variant="outline" size="md">Back to Home</GradientButton>
              </div>
            </>
          )}

          {status === "failed" && (
            <>
              <div className="w-16 h-16 rounded-2xl bg-red-500/10 border border-red-500/20 flex items-center justify-center mx-auto mb-5">
                <XCircle className="w-8 h-8 text-red-400" />
              </div>
              <h1 className="font-display text-xl font-bold text-white mb-2">Payment Failed</h1>
              <p className="text-text-muted text-sm mb-8">
                Your payment could not be processed. No charges were made.
                Please try again or contact us if the issue persists.
              </p>
              <div className="flex flex-col gap-3">
                <GradientButton href="/support" variant="blue-purple" size="md">Try Again</GradientButton>
                <GradientButton href="/contact" variant="outline" size="md">Contact Support</GradientButton>
              </div>
            </>
          )}
        </GlassCard>
      </div>
    </div>
  );
}
