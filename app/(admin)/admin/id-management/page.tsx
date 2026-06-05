"use client";
import { useEffect, useState, useCallback } from "react";
import { CreditCard, Plus, Search, Ban, RefreshCw, QrCode } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import { toast } from "sonner";
import { formatDate } from "@/utils/format";

interface IdRecord {
  id: string;
  id_number: string;
  status: "active" | "expired" | "revoked";
  issued_at: string;
  expires_at: string;
  user_id: string;
  users: { full_name: string; email: string };
}

export default function IdManagementPage() {
  const [ids, setIds] = useState<IdRecord[]>([]);
  const [users, setUsers] = useState<{ id: string; full_name: string; email: string }[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [issuing, setIssuing] = useState(false);
  const [selectedUser, setSelectedUser] = useState("");

  const fetchIds = useCallback(async () => {
    setLoading(true);
    const s = createClient();
    const { data } = await s.from("digital_ids").select("*, users(full_name, email)").order("issued_at", { ascending: false });
    setIds((data ?? []) as IdRecord[]);
    setLoading(false);
  }, []);

  const fetchUsers = useCallback(async () => {
    const s = createClient();
    const { data } = await s.from("users").select("id, full_name, email").order("full_name");
    setUsers(data ?? []);
  }, []);

  useEffect(() => { fetchIds(); fetchUsers(); }, [fetchIds, fetchUsers]);

  const issueId = async () => {
    if (!selectedUser) { toast.error("Select a user first"); return; }
    setIssuing(true);
    try {
      const res = await fetch("/api/id", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ target_user_id: selectedUser }) });
      const json = await res.json();
      if (!json.success) throw new Error(json.error);
      toast.success("Digital ID issued successfully");
      setSelectedUser("");
      fetchIds();
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : "Failed to issue ID");
    } finally {
      setIssuing(false);
    }
  };

  const revokeId = async (id: string) => {
    const s = createClient();
    const { error } = await s.from("digital_ids").update({ status: "revoked" as "active" | "expired" | "revoked" }).eq("id", id);
    if (error) { toast.error("Failed to revoke"); return; }
    setIds((prev) => prev.map((i) => i.id === id ? { ...i, status: "revoked" } : i));
    toast.success("ID revoked");
  };

  const filtered = ids.filter((i) =>
    i.users?.full_name?.toLowerCase().includes(search.toLowerCase()) ||
    i.id_number.toLowerCase().includes(search.toLowerCase())
  );

  const statusBadge: Record<string, string> = {
    active: "bg-brand-green/10 text-brand-green",
    expired: "bg-yellow-500/10 text-yellow-400",
    revoked: "bg-red-500/10 text-red-400",
  };

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div>
        <h2 className="font-display text-2xl font-bold text-white mb-1">ID Management</h2>
        <p className="text-text-muted text-sm">{ids.length} digital IDs issued</p>
      </div>

      {/* Issue New ID */}
      <GlassCard className="p-6 border border-brand-blue/20 bg-brand-blue/5">
        <h3 className="font-display text-base font-bold text-white mb-4 flex items-center gap-2">
          <Plus className="w-4 h-4 text-brand-blue-light" /> Issue New Digital ID
        </h3>
        <div className="flex flex-col sm:flex-row gap-3">
          <select
            value={selectedUser}
            onChange={(e) => setSelectedUser(e.target.value)}
            className="input-brand flex-1"
          >
            <option value="">Select a user...</option>
            {users.map((u) => (
              <option key={u.id} value={u.id}>{u.full_name} — {u.email}</option>
            ))}
          </select>
          <GradientButton variant="blue-purple" size="md" onClick={issueId} loading={issuing} icon={<CreditCard className="w-4 h-4" />} iconPosition="left">
            Issue ID
          </GradientButton>
        </div>
      </GlassCard>

      {/* ID Table */}
      <GlassCard className="border border-white/[0.05] overflow-hidden">
        <div className="p-4 border-b border-white/[0.06] flex items-center justify-between gap-4">
          <div className="relative flex-1 max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search by name or ID..." className="input-brand pl-9" />
          </div>
          <button onClick={fetchIds} className="w-9 h-9 glass rounded-lg flex items-center justify-center text-text-muted hover:text-white transition-colors">
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>

        {loading ? (
          <div className="p-12 text-center text-text-muted text-sm">Loading IDs...</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/[0.06]">
                  {["User", "ID Number", "Status", "Issued", "Expires", "Actions"].map((h) => (
                    <th key={h} className="text-left px-5 py-3.5 text-xs font-semibold text-text-muted uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((item) => (
                  <tr key={item.id} className="border-b border-white/[0.04] hover:bg-white/[0.02] transition-colors">
                    <td className="px-5 py-4">
                      <div className="text-sm font-medium text-white">{item.users?.full_name}</div>
                      <div className="text-xs text-text-muted">{item.users?.email}</div>
                    </td>
                    <td className="px-5 py-4"><span className="font-mono text-xs text-white">{item.id_number}</span></td>
                    <td className="px-5 py-4"><span className={`text-xs px-2.5 py-1 rounded-full font-semibold capitalize ${statusBadge[item.status]}`}>{item.status}</span></td>
                    <td className="px-5 py-4"><span className="text-xs text-text-muted">{formatDate(item.issued_at)}</span></td>
                    <td className="px-5 py-4"><span className="text-xs text-text-muted">{formatDate(item.expires_at)}</span></td>
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-3">
                        <a href={`/verify/${item.id_number}`} target="_blank" rel="noopener noreferrer" className="text-xs text-text-muted hover:text-white transition-colors flex items-center gap-1">
                          <QrCode className="w-3.5 h-3.5" /> Verify
                        </a>
                        {item.status === "active" && (
                          <button onClick={() => revokeId(item.id)} className="text-xs text-red-400 hover:text-red-300 transition-colors flex items-center gap-1">
                            <Ban className="w-3.5 h-3.5" /> Revoke
                          </button>
                        )}
                      </div>
                    </td>
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
