"use client";
import { useState } from "react";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Zap, Send, ArrowLeft } from "lucide-react";
import { toast } from "sonner";
import { authService } from "@/services/auth.service";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";

const schema = z.object({ email: z.string().email("Invalid email address") });
type Form = z.infer<typeof schema>;

export default function ForgotPasswordPage() {
  const [sent, setSent] = useState(false);
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<Form>({ resolver: zodResolver(schema) });

  const onSubmit = async (data: Form) => {
    try {
      await authService.resetPassword(data.email);
      setSent(true);
    } catch {
      toast.error("Failed to send reset email. Please try again.");
    }
  };

  return (
    <GlassCard variant="gradient" className="p-8 border border-white/[0.06]">
      <div className="flex items-center gap-3 mb-8">
        <div className="w-10 h-10 rounded-xl bg-brand-gradient flex items-center justify-center shadow-glow-sm"><Zap className="w-5 h-5 text-white" strokeWidth={2.5} /></div>
        <div><div className="font-display text-lg font-bold text-white">Reset Password</div><div className="text-xs text-text-muted">We&apos;ll send you a reset link</div></div>
      </div>

      {sent ? (
        <div className="text-center py-4">
          <div className="w-14 h-14 rounded-2xl bg-brand-green/10 border border-brand-green/20 flex items-center justify-center mx-auto mb-4">
            <Send className="w-7 h-7 text-brand-green" />
          </div>
          <h3 className="font-display text-lg font-bold text-white mb-2">Check your inbox</h3>
          <p className="text-text-muted text-sm mb-6">A password reset link has been sent to your email address.</p>
          <Link href="/login" className="text-sm text-brand-blue-light hover:text-white transition-colors">Back to sign in</Link>
        </div>
      ) : (
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Email Address</label>
            <input {...register("email")} type="email" placeholder="you@email.com" className="input-brand" />
            {errors.email && <p className="mt-1.5 text-xs text-red-400">{errors.email.message}</p>}
          </div>
          <GradientButton type="submit" variant="blue-purple" size="md" fullWidth loading={isSubmitting} icon={<Send className="w-4 h-4" />}>
            {isSubmitting ? "Sending..." : "Send Reset Link"}
          </GradientButton>
        </form>
      )}

      <div className="mt-6 text-center">
        <Link href="/login" className="text-sm text-text-muted hover:text-white transition-colors flex items-center justify-center gap-1.5">
          <ArrowLeft className="w-3.5 h-3.5" /> Back to sign in
        </Link>
      </div>
    </GlassCard>
  );
}
