"use client";
import { useEffect, useState, useCallback } from "react";
import { Award, Plus, Search, RefreshCw, Ban, ExternalLink } from "lucide-react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import { toast } from "sonner";
import { formatDate } from "@/utils/format";

const issueSchema = z.object({
  target_user_id: z.string().min(1, "Select a user"),
  title: z.string().min(3, "Min 3 characters"),
  issued_by: z.string().min(2, "Min 2 characters"),
  description: z.string().optional(),
  expires_at: z.string().optional(),
});
type IssueForm = z.infer<typeof issueSchema>;

interface CertRecord {
  id: string;
  title: string;
  issued_by: string;
  verification_code: string;
  status: string;
  issued_at: string;
  expires_at?: string;
  users: { full_name: string; email: string };
}

export default function AdminCertificationsPage() {
  const [certs, setCerts] = useState<CertRecord[]>([]);
  const [users, setUsers] = useState<{ id: string; full_name: string; email: string }[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [showForm, setShowForm] = useState(false);

  const { register, handleSubmit, reset, formState: { errors, isSubmitting } } = useForm<IssueForm>({
    resolver: zodResolver(issueSchema),
    defaultValues: { issued_by: "Nifelux Technologies" },
  });

  const fetchCerts = useCallback(async () => {
    setLoading(true);
    const s = createClient();
    const { data } = await s.from("certifications").select("*, users(full_name, email)").order("issued_at", { ascending: false });
    setCerts((data ?? []) as CertRecord[]);
    setLoading(false);
  }, []);

  const fetchUsers = useCallback(async () => {
    const s = createClient();
    const { data } = await s.from("users").select("id, full_name, email").order("full_name");
    setUsers(data ?? []);
  }, []);

  useEffect(() => { fetchCerts(); fetchUsers(); }, [fetchCerts, fetchUsers]);

  const onSubmit = async (data: IssueForm) => {
    try {
      const res = await fetch("/api/certifications", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(data) });
      const json = await res.json();
      if (!json.success) throw new Error(json.error);
      toast.success("Certificate issued successfully");
      reset();
      setShowForm(false);
      fetchCerts();
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : "Failed to issue certificate");
    }
  };

  const revoke = async (id: string) => {
    const s = createClient();
    const { error } = await s.from("certifications").update({ status: "revoked" }).eq("id", id);
    if (error) { toast.error("Failed to revoke"); return; }
    setCerts((prev) => prev.map((c) => c.id === id ? { ...c, status: "revoked" } : c));
    toast.success("Certificate revoked");
  };

  const filtered = certs.filter((c) =>
    c.users?.full_name?.toLowerCase().includes(search.toLowerCase()) ||
    c.title.toLowerCase().includes(search.toLowerCase()) ||
    c.verification_code.toLowerCase().includes(search.toLowerCase())
  );

  const statusBadge: Record<string, string> = {
    active: "bg-brand-green/10 text-brand-green",
    expired: "bg-yellow-500/10 text-yellow-400",
    revoked: "bg-red-500/10 text-red-400",
  };

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-display text-2xl font-bold text-white mb-1">Certifications</h2>
          <p className="text-text-muted text-sm">{certs.length} certificates issued</p>
        </div>
        <GradientButton variant="blue-purple" size="sm" onClick={() => setShowForm(!showForm)} icon={<Plus className="w-4 h-4" />} iconPosition="left">
          Issue Certificate
        </GradientButton>
      </div>

      {/* Issue Form */}
      {showForm && (
        <GlassCard className="p-6 border border-brand-green/20 bg-brand-green/5">
          <h3 className="font-display text-base font-bold text-white mb-5 flex items-center gap-2">
            <Award className="w-4 h-4 text-brand-green" /> Issue New Certificate
          </h3>
          <form onSubmit={handleSubmit(onSubmit)} className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Recipient</label>
              <select {...register("target_user_id")} className="input-brand">
                <option value="">Select user...</option>
                {users.map((u) => <option key={u.id} value={u.id}>{u.full_name} — {u.email}</option>)}
              </select>
              {errors.target_user_id && <p className="mt-1.5 text-xs text-red-400">{errors.target_user_id.message}</p>}
            </div>
            <div>
              <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Certificate Title</label>
              <input {...register("title")} className="input-brand" placeholder="e.g. AI Fundamentals Certificate" />
              {errors.title && <p className="mt-1.5 text-xs text-red-400">{errors.title.message}</p>}
            </div>
            <div>
              <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Issued By</label>
              <input {...register("issued_by")} className="input-brand" />
            </div>
            <div>
              <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Expiry Date (Optional)</label>
              <input {...register("expires_at")} type="date" className="input-brand" />
            </div>
            <div className="sm:col-span-2">
              <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Description (Optional)</label>
              <textarea {...register("description")} rows={2} className="input-brand resize-none" placeholder="Brief description of the certification..." />
            </div>
            <div className="sm:col-span-2 flex gap-3">
              <GradientButton type="submit" variant="green-blue" size="md" loading={isSubmitting} icon={<Award className="w-4 h-4" />} iconPosition="left">
                {isSubmitting ? "Issuing..." : "Issue Certificate"}
              </GradientButton>
              <GradientButton type="button" variant="outline" size="md" onClick={() => setShowForm(false)}>Cancel</GradientButton>
            </div>
          </form>
        </GlassCard>
      )}

      {/* Table */}
      <GlassCard className="border border-white/[0.05] overflow-hidden">
        <div className="p-4 border-b border-white/[0.06] flex items-center justify-between gap-4">
          <div className="relative flex-1 max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search certificates..." className="input-brand pl-9" />
          </div>
          <button onClick={fetchCerts} className="w-9 h-9 glass rounded-lg flex items-center justify-center text-text-muted hover:text-white transition-colors">
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>

        {loading ? (
          <div className="p-12 text-center text-text-muted text-sm">Loading certificates...</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/[0.06]">
                  {["Recipient", "Title", "Code", "Status", "Issued", "Actions"].map((h) => (
                    <th key={h} className="text-left px-5 py-3.5 text-xs font-semibold text-text-muted uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((cert) => (
                  <tr key={cert.id} className="border-b border-white/[0.04] hover:bg-white/[0.02] transition-colors">
                    <td className="px-5 py-4">
                      <div className="text-sm font-medium text-white">{cert.users?.full_name}</div>
                      <div className="text-xs text-text-muted">{cert.users?.email}</div>
                    </td>
                    <td className="px-5 py-4"><div className="text-sm text-white max-w-[180px] truncate">{cert.title}</div></td>
                    <td className="px-5 py-4"><span className="font-mono text-xs text-text-muted">{cert.verification_code}</span></td>
                    <td className="px-5 py-4"><span className={`text-xs px-2.5 py-1 rounded-full font-semibold capitalize ${statusBadge[cert.status]}`}>{cert.status}</span></td>
                    <td className="px-5 py-4"><span className="text-xs text-text-muted">{formatDate(cert.issued_at)}</span></td>
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-3">
                        <a href={`/verify/${cert.verification_code}`} target="_blank" rel="noopener noreferrer" className="text-xs text-text-muted hover:text-white transition-colors flex items-center gap-1">
                          <ExternalLink className="w-3.5 h-3.5" /> Verify
                        </a>
                        {cert.status === "active" && (
                          <button onClick={() => revoke(cert.id)} className="text-xs text-red-400 hover:text-red-300 transition-colors flex items-center gap-1">
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
