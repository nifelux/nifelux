"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Zap, Eye, EyeOff, Check } from "lucide-react";
import { toast } from "sonner";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";

const schema = z.object({
  password: z.string().min(8, "Min 8 characters").regex(/[A-Z]/, "Need uppercase").regex(/[0-9]/, "Need number"),
  confirm: z.string(),
}).refine((d) => d.password === d.confirm, { message: "Passwords do not match", path: ["confirm"] });

type Form = z.infer<typeof schema>;

export default function ResetPasswordPage() {
  const [show, setShow] = useState(false);
  const [done, setDone] = useState(false);
  const router = useRouter();
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<Form>({ resolver: zodResolver(schema) });

  const onSubmit = async (data: Form) => {
    try {
      const supabase = createClient();
      const { error } = await supabase.auth.updateUser({ password: data.password });
      if (error) throw error;
      setDone(true);
      setTimeout(() => router.push("/login"), 2000);
    } catch {
      toast.error("Failed to reset password. The link may have expired.");
    }
  };

  return (
    <GlassCard variant="gradient" className="p-8 border border-white/[0.06]">
      <div className="flex items-center gap-3 mb-8">
        <div className="w-10 h-10 rounded-xl bg-brand-gradient flex items-center justify-center shadow-glow-sm"><Zap className="w-5 h-5 text-white" strokeWidth={2.5} /></div>
        <div><div className="font-display text-lg font-bold text-white">New Password</div><div className="text-xs text-text-muted">Set a strong new password</div></div>
      </div>

      {done ? (
        <div className="text-center py-4">
          <div className="w-14 h-14 rounded-2xl bg-brand-green/10 border border-brand-green/20 flex items-center justify-center mx-auto mb-4"><Check className="w-7 h-7 text-brand-green" /></div>
          <h3 className="font-display text-lg font-bold text-white mb-2">Password Updated!</h3>
          <p className="text-text-muted text-sm">Redirecting you to sign in...</p>
        </div>
      ) : (
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">New Password</label>
            <div className="relative">
              <input {...register("password")} type={show ? "text" : "password"} placeholder="Min 8 chars, 1 uppercase, 1 number" className="input-brand pr-10" />
              <button type="button" onClick={() => setShow(!show)} className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted hover:text-white transition-colors">
                {show ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
            {errors.password && <p className="mt-1.5 text-xs text-red-400">{errors.password.message}</p>}
          </div>
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Confirm Password</label>
            <input {...register("confirm")} type="password" placeholder="••••••••" className="input-brand" />
            {errors.confirm && <p className="mt-1.5 text-xs text-red-400">{errors.confirm.message}</p>}
          </div>
          <GradientButton type="submit" variant="blue-purple" size="md" fullWidth loading={isSubmitting}>
            {isSubmitting ? "Updating..." : "Update Password"}
          </GradientButton>
        </form>
      )}
    </GlassCard>
  );
}
