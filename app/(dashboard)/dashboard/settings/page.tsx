"use client";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { User, Mail, Phone, Save, Shield, Eye, EyeOff } from "lucide-react";
import { toast } from "sonner";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import { useUser } from "@/hooks/useUser";
import { userService } from "@/services/user.service";
import { createClient } from "@/lib/supabase/client";

const profileSchema = z.object({
  full_name: z.string().min(2, "Min 2 characters"),
  phone: z.string().optional(),
});

const passwordSchema = z.object({
  current_password: z.string().min(6),
  new_password: z.string().min(8, "Min 8 characters").regex(/[A-Z]/, "Need uppercase").regex(/[0-9]/, "Need number"),
  confirm_password: z.string(),
}).refine((d) => d.new_password === d.confirm_password, { message: "Passwords do not match", path: ["confirm_password"] });

type ProfileForm = z.infer<typeof profileSchema>;
type PasswordForm = z.infer<typeof passwordSchema>;

export default function SettingsPage() {
  const { user } = useUser();
  const [showPw, setShowPw] = useState(false);
  const [showNew, setShowNew] = useState(false);

  const profileForm = useForm<ProfileForm>({
    resolver: zodResolver(profileSchema),
    defaultValues: { full_name: user?.full_name ?? "", phone: user?.phone ?? "" },
  });

  const passwordForm = useForm<PasswordForm>({ resolver: zodResolver(passwordSchema) });

  const onProfileSubmit = async (data: ProfileForm) => {
    if (!user) return;
    try {
      await userService.updateProfile(user.id, data);
      toast.success("Profile updated");
    } catch {
      toast.error("Failed to update profile");
    }
  };

  const onPasswordSubmit = async (data: PasswordForm) => {
    try {
      const supabase = createClient();
      const { error } = await supabase.auth.updateUser({ password: data.new_password });
      if (error) throw error;
      toast.success("Password updated");
      passwordForm.reset();
    } catch {
      toast.error("Failed to update password");
    }
  };

  return (
    <div className="max-w-2xl mx-auto space-y-8">
      <div>
        <h2 className="font-display text-2xl font-bold text-white mb-1">Settings</h2>
        <p className="text-text-muted text-sm">Manage your account preferences.</p>
      </div>

      {/* Profile */}
      <GlassCard className="p-6 border border-white/[0.05]">
        <div className="flex items-center gap-3 mb-6">
          <div className="w-9 h-9 rounded-xl bg-brand-blue/10 flex items-center justify-center"><User className="w-4.5 h-4.5 text-brand-blue-light" /></div>
          <div>
            <h3 className="font-display text-base font-bold text-white">Profile</h3>
            <p className="text-text-muted text-xs">Update your name and phone number.</p>
          </div>
        </div>

        <form onSubmit={profileForm.handleSubmit(onProfileSubmit)} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Full Name</label>
            <input {...profileForm.register("full_name")} className="input-brand" placeholder="Your full name" />
            {profileForm.formState.errors.full_name && <p className="mt-1.5 text-xs text-red-400">{profileForm.formState.errors.full_name.message}</p>}
          </div>
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Email Address</label>
            <div className="relative">
              <input value={user?.email ?? ""} readOnly className="input-brand opacity-50 cursor-not-allowed pr-10" />
              <Mail className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            </div>
            <p className="mt-1 text-xs text-text-muted">Email cannot be changed.</p>
          </div>
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Phone Number</label>
            <div className="relative">
              <input {...profileForm.register("phone")} className="input-brand pr-10" placeholder="+234 800 000 0000" />
              <Phone className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            </div>
          </div>
          <GradientButton type="submit" variant="blue-purple" size="md" loading={profileForm.formState.isSubmitting}
            icon={<Save className="w-4 h-4" />}>
            Save Profile
          </GradientButton>
        </form>
      </GlassCard>

      {/* Password */}
      <GlassCard className="p-6 border border-white/[0.05]">
        <div className="flex items-center gap-3 mb-6">
          <div className="w-9 h-9 rounded-xl bg-brand-purple/10 flex items-center justify-center"><Shield className="w-4.5 h-4.5 text-brand-purple-light" /></div>
          <div>
            <h3 className="font-display text-base font-bold text-white">Password</h3>
            <p className="text-text-muted text-xs">Change your account password.</p>
          </div>
        </div>

        <form onSubmit={passwordForm.handleSubmit(onPasswordSubmit)} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Current Password</label>
            <div className="relative">
              <input {...passwordForm.register("current_password")} type={showPw ? "text" : "password"} className="input-brand pr-10" placeholder="••••••••" />
              <button type="button" onClick={() => setShowPw(!showPw)} className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted hover:text-white transition-colors">
                {showPw ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
          </div>
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">New Password</label>
            <div className="relative">
              <input {...passwordForm.register("new_password")} type={showNew ? "text" : "password"} className="input-brand pr-10" placeholder="Min 8 chars, 1 uppercase, 1 number" />
              <button type="button" onClick={() => setShowNew(!showNew)} className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted hover:text-white transition-colors">
                {showNew ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
            {passwordForm.formState.errors.new_password && <p className="mt-1.5 text-xs text-red-400">{passwordForm.formState.errors.new_password.message}</p>}
          </div>
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Confirm New Password</label>
            <input {...passwordForm.register("confirm_password")} type="password" className="input-brand" placeholder="••••••••" />
            {passwordForm.formState.errors.confirm_password && <p className="mt-1.5 text-xs text-red-400">{passwordForm.formState.errors.confirm_password.message}</p>}
          </div>
          <GradientButton type="submit" variant="blue-purple" size="md" loading={passwordForm.formState.isSubmitting}
            icon={<Shield className="w-4 h-4" />}>
            Update Password
          </GradientButton>
        </form>
      </GlassCard>

      {/* Account Info */}
      <GlassCard className="p-6 border border-white/[0.05]">
        <h3 className="font-display text-base font-bold text-white mb-4">Account Information</h3>
        <div className="space-y-3">
          {[
            { label: "User ID", value: user?.id?.slice(0, 8) + "..." },
            { label: "Role", value: user?.role, capitalize: true },
            { label: "Status", value: user?.status, capitalize: true },
            { label: "Member Since", value: user?.created_at ? new Date(user.created_at).toLocaleDateString("en-NG", { year: "numeric", month: "long", day: "numeric" }) : "—" },
          ].map(({ label, value, capitalize }) => (
            <div key={label} className="flex items-center justify-between py-2.5 border-b border-white/[0.04] last:border-0">
              <span className="text-sm text-text-muted">{label}</span>
              <span className={`text-sm text-white font-medium ${capitalize ? "capitalize" : ""}`}>{value}</span>
            </div>
          ))}
        </div>
      </GlassCard>
    </div>
  );
}
