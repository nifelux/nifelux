"use client";
import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Eye, EyeOff, Zap } from "lucide-react";
import { toast } from "sonner";
import { registerSchema, type RegisterForm } from "@/lib/validations/auth.schema";
import { authService } from "@/services/auth.service";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";

export default function RegisterPage() {
  const [show, setShow] = useState(false);
  const router = useRouter();
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<RegisterForm>({ resolver: zodResolver(registerSchema) });
  const onSubmit = async (data: RegisterForm) => {
    try { await authService.signUp(data.email, data.password, { full_name: data.full_name, phone: data.phone }); toast.success("Account created! Check your email."); router.push("/login"); }
    catch (err: unknown) { toast.error(err instanceof Error ? err.message : "Registration failed"); }
  };
  return (
    <GlassCard variant="gradient" className="p-8 border border-white/[0.06]">
      <div className="flex items-center gap-3 mb-8">
        <div className="w-10 h-10 rounded-xl bg-brand-gradient flex items-center justify-center shadow-glow-sm"><Zap className="w-5 h-5 text-white" strokeWidth={2.5} /></div>
        <div><div className="font-display text-lg font-bold text-white">Join Nifelux</div><div className="text-xs text-text-muted">Create your account</div></div>
      </div>
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        <div>
          <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Full Name</label>
          <input {...register("full_name")} placeholder="Your full name" className="input-brand" />
          {errors.full_name && <p className="mt-1.5 text-xs text-red-400">{errors.full_name.message}</p>}
        </div>
        <div>
          <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Email</label>
          <input {...register("email")} type="email" placeholder="you@email.com" className="input-brand" />
          {errors.email && <p className="mt-1.5 text-xs text-red-400">{errors.email.message}</p>}
        </div>
        <div>
          <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Phone (Optional)</label>
          <input {...register("phone")} type="tel" placeholder="+234 800 000 0000" className="input-brand" />
        </div>
        <div>
          <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Password</label>
          <div className="relative">
            <input {...register("password")} type={show?"text":"password"} placeholder="Min 8 chars, 1 uppercase, 1 number" className="input-brand pr-12" />
            <button type="button" onClick={() => setShow(!show)} className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted hover:text-white">{show?<EyeOff className="w-4 h-4" />:<Eye className="w-4 h-4" />}</button>
          </div>
          {errors.password && <p className="mt-1.5 text-xs text-red-400">{errors.password.message}</p>}
        </div>
        <GradientButton type="submit" variant="blue-purple" size="md" fullWidth loading={isSubmitting}>{isSubmitting?"Creating...":"Create Account"}</GradientButton>
      </form>
      <p className="text-center text-sm text-text-muted mt-6">Already have an account? <Link href="/login" className="text-brand-blue-light hover:text-white transition-colors font-medium">Sign in</Link></p>
    </GlassCard>
  );
}
