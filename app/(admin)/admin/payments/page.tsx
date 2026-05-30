"use client";
import { useEffect, useState, useCallback } from "react";
import { DollarSign, RefreshCw, Search, TrendingUp } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import { formatDate } from "@/utils/format";

interface PaymentRecord {
  id: string;
  reference: string;
  amount: number;
  currency: string;
  status: string;
  purpose: string;
  paid_at: string | null;
  created_at: string;
  metadata: { email?: string; anonymous?: boolean } | null;
  users?: { full_name: string } | null;
}

const statusBadge: Record<string, string> = {
  success: "bg-brand-green/10 text-brand-green",
  pending: "bg-yellow-500/10 text-yellow-400",
  failed: "bg-red-500/10 text-red-400",
  refunded: "bg-brand-blue/10 text-brand-blue-light",
};

export default function AdminPaymentsPage() {
  const [payments, setPayments] = useState<PaymentRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  const fetchPayments = useCallback(async () => {
    setLoading(true);
    const s = createClient();
    const { data } = await s
      .from("payments")
      .select("*, users(full_name)")
      .order("created_at", { ascending: false });
    setPayments((data ?? []) as PaymentRecord[]);
    setLoading(false);
  }, []);

  useEffect(() => { fetchPayments(); }, [fetchPayments]);

  const totalSuccess = payments.filter((p) => p.status === "success").reduce((a, p) => a + Number(p.amount), 0);
  const totalCount = payments.filter((p) => p.status === "success").length;
  const pending = payments.filter((p) => p.status === "pending").length;

  const filtered = payments.filter((p) =>
    p.reference.toLowerCase().includes(search.toLowerCase()) ||
    p.purpose.toLowerCase().includes(search.toLowerCase()) ||
    p.users?.full_name?.toLowerCase().includes(search.toLowerCase()) ||
    (p.metadata?.email ?? "").toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div>
        <h2 className="font-display text-2xl font-bold text-white mb-1">Payments</h2>
        <p className="text-text-muted text-sm">All transactions across the platform.</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        {[
          { label: "Total Revenue", value: `₦${totalSuccess.toLocaleString()}`, icon: DollarSign, color: "green" },
          { label: "Successful Payments", value: totalCount.toString(), icon: TrendingUp, color: "blue" },
          { label: "Pending", value: pending.toString(), icon: RefreshCw, color: "purple" },
        ].map(({ label, value, icon: I, color }) => (
          <GlassCard key={label} className={`p-5 border ${color === "green" ? "border-brand-green/20" : color === "blue" ? "border-brand-blue/20" : "border-brand-purple/20"}`}>
            <div className={`w-9 h-9 rounded-xl flex items-center justify-center mb-3 ${color === "green" ? "bg-brand-green/10 text-brand-green" : color === "blue" ? "bg-brand-blue/10 text-brand-blue-light" : "bg-brand-purple/10 text-brand-purple-light"}`}>
              <I className="w-4 h-4" />
            </div>
            <div className="font-display text-xl font-bold text-white mb-1">{value}</div>
            <div className="text-xs text-text-muted">{label}</div>
          </GlassCard>
        ))}
      </div>

      {/* Table */}
      <GlassCard className="border border-white/[0.05] overflow-hidden">
        <div className="p-4 border-b border-white/[0.06] flex items-center justify-between gap-4">
          <div className="relative flex-1 max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search payments..." className="input-brand pl-9" />
          </div>
          <button onClick={fetchPayments} className="w-9 h-9 glass rounded-lg flex items-center justify-center text-text-muted hover:text-white transition-colors">
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>

        {loading ? (
          <div className="p-12 text-center text-text-muted text-sm">Loading payments...</div>
        ) : filtered.length === 0 ? (
          <div className="p-12 text-center text-text-muted text-sm">No payments found.</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/[0.06]">
                  {["Reference", "User / Email", "Amount", "Purpose", "Status", "Date"].map((h) => (
                    <th key={h} className="text-left px-5 py-3.5 text-xs font-semibold text-text-muted uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((p) => (
                  <tr key={p.id} className="border-b border-white/[0.04] hover:bg-white/[0.02] transition-colors">
                    <td className="px-5 py-4"><span className="font-mono text-xs text-white">{p.reference}</span></td>
                    <td className="px-5 py-4">
                      <div className="text-sm font-medium text-white">{p.users?.full_name ?? (p.metadata?.anonymous ? "Anonymous" : "Guest")}</div>
                      <div className="text-xs text-text-muted">{p.metadata?.email ?? "—"}</div>
                    </td>
                    <td className="px-5 py-4"><span className={`text-sm font-bold ${p.status === "success" ? "text-brand-green" : "text-white"}`}>₦{Number(p.amount).toLocaleString()}</span></td>
                    <td className="px-5 py-4"><span className="text-xs text-text-secondary capitalize">{p.purpose}</span></td>
                    <td className="px-5 py-4"><span className={`text-xs px-2.5 py-1 rounded-full font-semibold capitalize ${statusBadge[p.status] ?? "bg-white/[0.05] text-text-muted"}`}>{p.status}</span></td>
                    <td className="px-5 py-4"><span className="text-xs text-text-muted">{formatDate(p.paid_at ?? p.created_at)}</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </GlassCard>
    </div>
  );
}
