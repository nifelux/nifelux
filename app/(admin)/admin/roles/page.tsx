"use client";
import { useEffect, useState, useCallback } from "react";
import { Shield, Search, Save } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import { toast } from "sonner";
import type { User, UserRole } from "@/types/user.types";

const ROLES: { value: UserRole; label: string; desc: string; color: string }[] = [
  { value: "user", label: "User", desc: "Standard access — dashboard, ID card, certifications.", color: "text-text-muted" },
  { value: "staff", label: "Staff", desc: "Internal team access — can view but not manage.", color: "text-brand-blue-light" },
  { value: "admin", label: "Admin", desc: "Full admin access — manage users, IDs, certs, payments.", color: "text-brand-purple-light" },
  { value: "super_admin", label: "Super Admin", desc: "Complete platform control including roles.", color: "text-brand-green" },
];

export default function RolesPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [pending, setPending] = useState<Record<string, UserRole>>({});
  const [saving, setSaving] = useState<string | null>(null);

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    const s = createClient();
    const { data } = await s.from("users").select("*").order("full_name");
    setUsers((data ?? []) as User[]);
    setLoading(false);
  }, []);

  useEffect(() => { fetchUsers(); }, [fetchUsers]);

  const updateRole = async (userId: string) => {
    const role = pending[userId];
    if (!role) return;
    setSaving(userId);
    const s = createClient();
    const { error } = await s.from("users").update({ role: role as "user" | "staff" | "admin" | "super_admin" }).eq("id", userId);
    if (error) { toast.error("Failed to update role"); setSaving(null); return; }
    setUsers((prev) => prev.map((u) => u.id === userId ? { ...u, role } : u));
    setPending((prev) => { const n = { ...prev }; delete n[userId]; return n; });
    setSaving(null);
    toast.success("Role updated successfully");
  };

  const roleBg: Record<string, string> = {
    user: "bg-white/[0.05]", staff: "bg-brand-blue/10",
    admin: "bg-brand-purple/10", super_admin: "bg-brand-green/10",
  };

  const filtered = users.filter((u) =>
    u.full_name.toLowerCase().includes(search.toLowerCase()) ||
    u.email.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <div>
        <h2 className="font-display text-2xl font-bold text-white mb-1">Role Management</h2>
        <p className="text-text-muted text-sm">Assign and manage user permissions.</p>
      </div>

      {/* Role Legend */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        {ROLES.map((r) => (
          <GlassCard key={r.value} className={`p-4 border border-white/[0.05] ${roleBg[r.value]}`}>
            <div className={`text-xs font-bold uppercase tracking-wider mb-1 ${r.color}`}>{r.label}</div>
            <p className="text-text-muted text-xs leading-relaxed">{r.desc}</p>
          </GlassCard>
        ))}
      </div>

      {/* User Table */}
      <GlassCard className="border border-white/[0.05] overflow-hidden">
        <div className="p-4 border-b border-white/[0.06]">
          <div className="relative max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search users..." className="input-brand pl-9" />
          </div>
        </div>

        {loading ? (
          <div className="p-12 text-center text-text-muted text-sm">Loading users...</div>
        ) : (
          <div className="divide-y divide-white/[0.04]">
            {filtered.map((user) => {
              const currentRole = pending[user.id] ?? user.role;
              const hasPending = !!pending[user.id] && pending[user.id] !== user.role;
              return (
                <div key={user.id} className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 px-5 py-4 hover:bg-white/[0.02] transition-colors">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-full bg-brand-gradient flex items-center justify-center text-xs font-bold text-white flex-shrink-0">
                      {user.full_name?.[0]?.toUpperCase() ?? "N"}
                    </div>
                    <div>
                      <div className="text-sm font-medium text-white">{user.full_name}</div>
                      <div className="text-xs text-text-muted">{user.email}</div>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <select
                      value={currentRole}
                      onChange={(e) => setPending((prev) => ({ ...prev, [user.id]: e.target.value as UserRole }))}
                      className="input-brand text-sm py-2 w-40"
                    >
                      {ROLES.map((r) => (
                        <option key={r.value} value={r.value}>{r.label}</option>
                      ))}
                    </select>
                    {hasPending && (
                      <GradientButton
                        variant="blue-purple" size="sm"
                        loading={saving === user.id}
                        onClick={() => updateRole(user.id)}
                        icon={<Save className="w-3.5 h-3.5" />} iconPosition="left"
                      >
                        Save
                      </GradientButton>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </GlassCard>
    </div>
  );
}
