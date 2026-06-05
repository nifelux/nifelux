"use client";
import { useState, useCallback } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Bell, Send, Users, User } from "lucide-react";
import { useForm as useFormLib } from "react-hook-form";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import { toast } from "sonner";

const schema = z.object({
  title: z.string().min(3, "Min 3 characters"),
  body: z.string().min(5, "Min 5 characters"),
  type: z.enum(["info", "success", "warning", "alert"]),
  target: z.enum(["all", "specific"]),
  target_email: z.string().email().optional().or(z.literal("")),
});
type Form = z.infer<typeof schema>;

export default function AdminNotificationsPage() {
  const [sent, setSent] = useState(false);

  const { register, handleSubmit, watch, reset, formState: { errors, isSubmitting } } = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: { type: "info", target: "all" },
  });

  const target = watch("target");

  const onSubmit = async (data: Form) => {
    try {
      const s = createClient();
      let user_ids: string[] = [];

      if (data.target === "all") {
        const { data: users } = await s.from("users").select("id");
        user_ids = (users ?? []).map((u: { id: string }) => u.id);
      } else {
        const { data: users } = await s.from("users").select("id").eq("email", data.target_email!);
        user_ids = (users ?? []).map((u: { id: string }) => u.id);
        if (user_ids.length === 0) { toast.error("No user found with that email"); return; }
      }

      const res = await fetch("/api/notifications", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user_ids, title: data.title, body: data.body, type: data.type }),
      });

      const json = await res.json();
      if (!json.success) throw new Error(json.error);

      toast.success(`Notification sent to ${json.data.sent} user(s)`);
      setSent(true);
      reset();
      setTimeout(() => setSent(false), 3000);
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : "Failed to send notification");
    }
  };

  const typeColors: Record<string, string> = {
    info: "border-brand-blue/30 bg-brand-blue/5",
    success: "border-brand-green/30 bg-brand-green/5",
    warning: "border-yellow-500/30 bg-yellow-500/5",
    alert: "border-red-500/30 bg-red-500/5",
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div>
        <h2 className="font-display text-2xl font-bold text-white mb-1">Send Notifications</h2>
        <p className="text-text-muted text-sm">Broadcast messages to users in real-time.</p>
      </div>

      <GlassCard className="p-8 border border-white/[0.05]">
        <div className="flex items-center gap-3 mb-6">
          <div className="w-10 h-10 rounded-xl bg-brand-blue/10 flex items-center justify-center">
            <Bell className="w-5 h-5 text-brand-blue-light" />
          </div>
          <div>
            <h3 className="font-display text-base font-bold text-white">Compose Notification</h3>
            <p className="text-text-muted text-xs">Delivered instantly via Supabase Realtime</p>
          </div>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
          {/* Target */}
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-3 uppercase tracking-wider">Send To</label>
            <div className="grid grid-cols-2 gap-3">
              {[
                { value: "all", label: "All Users", icon: Users },
                { value: "specific", label: "Specific User", icon: User },
              ].map(({ value, label, icon: I }) => (
                <label key={value} className="cursor-pointer">
                  <input {...register("target")} type="radio" value={value} className="sr-only" />
                  <div className={`flex items-center gap-2.5 p-3.5 rounded-xl border transition-all ${watch("target") === value ? "border-brand-blue/50 bg-brand-blue/10 text-white" : "border-white/10 text-text-muted hover:border-white/20"}`}>
                    <I className="w-4 h-4" />
                    <span className="text-sm font-medium">{label}</span>
                  </div>
                </label>
              ))}
            </div>
          </div>

          {target === "specific" && (
            <div>
              <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">User Email</label>
              <input {...register("target_email")} type="email" placeholder="user@email.com" className="input-brand" />
              {errors.target_email && <p className="mt-1.5 text-xs text-red-400">{errors.target_email.message}</p>}
            </div>
          )}

          {/* Type */}
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-3 uppercase tracking-wider">Type</label>
            <div className="grid grid-cols-4 gap-2">
              {(["info", "success", "warning", "alert"] as const).map((t) => (
                <label key={t} className="cursor-pointer">
                  <input {...register("type")} type="radio" value={t} className="sr-only" />
                  <div className={`text-center py-2 rounded-lg border text-xs font-semibold capitalize transition-all ${watch("type") === t ? typeColors[t] : "border-white/10 text-text-muted hover:border-white/20"}`}>{t}</div>
                </label>
              ))}
            </div>
          </div>

          {/* Title */}
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Title</label>
            <input {...register("title")} placeholder="Notification title" className="input-brand" />
            {errors.title && <p className="mt-1.5 text-xs text-red-400">{errors.title.message}</p>}
          </div>

          {/* Body */}
          <div>
            <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Message</label>
            <textarea {...register("body")} rows={3} placeholder="Write your notification message..." className="input-brand resize-none" />
            {errors.body && <p className="mt-1.5 text-xs text-red-400">{errors.body.message}</p>}
          </div>

          <GradientButton type="submit" variant="blue-purple" size="md" fullWidth
            loading={isSubmitting} icon={<Send className="w-4 h-4" />} iconPosition="left">
            {isSubmitting ? "Sending..." : sent ? "Sent! ✓" : "Send Notification"}
          </GradientButton>
        </form>
      </GlassCard>
    </div>
  );
}
