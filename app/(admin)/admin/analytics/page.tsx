"use client";
import { useEffect, useState, useCallback } from "react";
import { Users, CreditCard, Award, DollarSign, TrendingUp, RefreshCw } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import { StaggerContainer, StaggerItem } from "@/components/common/AnimatedSection";

interface Stats {
  totalUsers: number;
  activeIds: number;
  totalCerts: number;
  totalRevenue: number;
  newUsersThisWeek: number;
  successfulPayments: number;
}

export default function AdminAnalyticsPage() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);

  const fetchStats = useCallback(async () => {
    setLoading(true);
    const s = createClient();

    const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();

    const [users, ids, certs, payments, newUsers, successPay] = await Promise.all([
      s.from("users").select("*", { count: "exact", head: true }),
      s.from("digital_ids").select("*", { count: "exact", head: true }).eq("status", "active"),
      s.from("certifications").select("*", { count: "exact", head: true }),
      s.from("payments").select("amount").eq("status", "success"),
      s.from("users").select("*", { count: "exact", head: true }).gte("created_at", weekAgo),
      s.from("payments").select("*", { count: "exact", head: true }).eq("status", "success"),
    ]);

    const totalRevenue = (payments.data ?? []).reduce((a, p) => a + Number(p.amount), 0);

    setStats({
      totalUsers: users.count ?? 0,
      activeIds: ids.count ?? 0,
      totalCerts: certs.count ?? 0,
      totalRevenue,
      newUsersThisWeek: newUsers.count ?? 0,
      successfulPayments: successPay.count ?? 0,
    });
    setLoading(false);
  }, []);

  useEffect(() => { fetchStats(); }, [fetchStats]);

  const kpis = stats ? [
    { label: "Total Users", value: stats.totalUsers.toLocaleString(), icon: Users, color: "blue", sub: `+${stats.newUsersThisWeek} this week` },
    { label: "Active Digital IDs", value: stats.activeIds.toLocaleString(), icon: CreditCard, color: "purple", sub: "Currently active" },
    { label: "Certificates Issued", value: stats.totalCerts.toLocaleString(), icon: Award, color: "green", sub: "All time" },
    { label: "Total Revenue", value: `₦${stats.totalRevenue.toLocaleString()}`, icon: DollarSign, color: "green", sub: `${stats.successfulPayments} transactions` },
  ] : [];

  return (
    <div className="max-w-6xl mx-auto space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-display text-2xl font-bold text-white mb-1">Analytics</h2>
          <p className="text-text-muted text-sm">Platform performance overview.</p>
        </div>
        <button onClick={fetchStats} className="w-9 h-9 glass rounded-lg flex items-center justify-center text-text-muted hover:text-white transition-colors">
          <RefreshCw className={`w-4 h-4 ${loading ? "animate-spin" : ""}`} />
        </button>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="glass-card p-5 h-32 animate-pulse" />
          ))}
        </div>
      ) : (
        <StaggerContainer className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {kpis.map(({ label, value, icon: I, color, sub }) => (
            <StaggerItem key={label}>
              <GlassCard className={`p-5 border ${color === "blue" ? "border-brand-blue/20" : color === "green" ? "border-brand-green/20" : "border-brand-purple/20"}`}>
                <div className="flex items-center justify-between mb-4">
                  <div className={`w-9 h-9 rounded-xl flex items-center justify-center ${color === "blue" ? "bg-brand-blue/10 text-brand-blue-light" : color === "green" ? "bg-brand-green/10 text-brand-green" : "bg-brand-purple/10 text-brand-purple-light"}`}>
                    <I className="w-4 h-4" />
                  </div>
                  <TrendingUp className="w-4 h-4 text-text-muted" />
                </div>
                <div className="font-display text-2xl font-bold text-white mb-1">{value}</div>
                <div className="text-xs text-text-muted">{label}</div>
                <div className="text-xs text-brand-green mt-1">{sub}</div>
              </GlassCard>
            </StaggerItem>
          ))}
        </StaggerContainer>
      )}

      {/* Breakdown */}
      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <GlassCard className="p-6 border border-white/[0.05]">
            <h3 className="font-display text-base font-bold text-white mb-5 flex items-center gap-2">
              <Users className="w-4 h-4 text-brand-blue-light" />Platform Summary
            </h3>
            <div className="space-y-4">
              {[
                { label: "Registered Users", value: stats.totalUsers, max: Math.max(stats.totalUsers, 1), color: "bg-brand-blue" },
                { label: "Active Digital IDs", value: stats.activeIds, max: Math.max(stats.totalUsers, 1), color: "bg-brand-purple" },
                { label: "Certificates Issued", value: stats.totalCerts, max: Math.max(stats.totalUsers, 1), color: "bg-brand-green" },
              ].map(({ label, value, max, color }) => (
                <div key={label}>
                  <div className="flex items-center justify-between mb-1.5">
                    <span className="text-xs text-text-secondary">{label}</span>
                    <span className="text-xs font-semibold text-white">{value}</span>
                  </div>
                  <div className="h-1.5 bg-white/[0.06] rounded-full overflow-hidden">
                    <div className={`h-full ${color} rounded-full transition-all duration-700`} style={{ width: `${Math.min((value / max) * 100, 100)}%` }} />
                  </div>
                </div>
              ))}
            </div>
          </GlassCard>

          <GlassCard className="p-6 border border-white/[0.05]">
            <h3 className="font-display text-base font-bold text-white mb-5 flex items-center gap-2">
              <DollarSign className="w-4 h-4 text-brand-green" />Revenue Summary
            </h3>
            <div className="space-y-4">
              {[
                { label: "Total Revenue", value: `₦${stats.totalRevenue.toLocaleString()}` },
                { label: "Successful Transactions", value: stats.successfulPayments.toString() },
                { label: "Average Transaction", value: stats.successfulPayments > 0 ? `₦${Math.round(stats.totalRevenue / stats.successfulPayments).toLocaleString()}` : "—" },
              ].map(({ label, value }) => (
                <div key={label} className="flex items-center justify-between py-3 border-b border-white/[0.04] last:border-0">
                  <span className="text-sm text-text-muted">{label}</span>
                  <span className="text-sm font-bold text-white">{value}</span>
                </div>
              ))}
            </div>
          </GlassCard>
        </div>
      )}
    </div>
  );
}
