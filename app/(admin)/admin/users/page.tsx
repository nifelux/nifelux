"use client";
import { useEffect, useState, useCallback } from "react";
import { Search, UserCog, Ban, CheckCircle, ChevronDown } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import { toast } from "sonner";
import type { User, UserRole } from "@/types/user.types";
import { formatDate } from "@/utils/format";

const ROLES: UserRole[] = ["user", "staff", "admin", "super_admin"];
const roleBadge: Record<string, string> = {
  user: "bg-white/[0.05] text-text-muted",
  staff: "bg-brand-blue/10 text-brand-blue-light",
  admin: "bg-brand-purple/10 text-brand-purple-light",
  super_admin: "bg-brand-green/10 text-brand-green",
};

export default function AdminUsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [editingRole, setEditingRole] = useState<string | null>(null);

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    const s = createClient();
    const { data } = await s.from("users").select("*").order("created_at", { ascending: false });
    setUsers((data ?? []) as User[]);
    setLoading(false);
  }, []);

  useEffect(() => { fetchUsers(); }, [fetchUsers]);

  const updateRole = async (userId: string, role: UserRole) => {
    const s = createClient();
    const { error } = await s.from("users").update({ role: role as "user" | "staff" | "admin" | "super_admin" }).eq("id", userId);
    if (error) { toast.error("Failed to update role"); return; }
    setUsers((prev) => prev.map((u) => u.id === userId ? { ...u, role } : u));
    setEditingRole(null);
    toast.success("Role updated");
  };

  const toggleStatus = async (user: User) => {
    const newStatus = user.status === "active" ? "suspended" : "active";
    const s = createClient();
    const { error } = await s.from("users").update({ status: newStatus as "active" | "suspended" | "pending" }).eq("id", user.id);
    if (error) { toast.error("Failed to update status"); return; }
    setUsers((prev) => prev.map((u) => u.id === user.id ? { ...u, status: newStatus } : u));
    toast.success(`User ${newStatus}`);
  };

  const filtered = users.filter((u) =>
    u.full_name.toLowerCase().includes(search.toLowerCase()) ||
    u.email.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="font-display text-2xl font-bold text-white mb-1">Users</h2>
          <p className="text-text-muted text-sm">{users.length} total users</p>
        </div>
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search users..."
            className="input-brand pl-9 w-64"
          />
        </div>
      </div>

      <GlassCard className="border border-white/[0.05] overflow-hidden">
        {loading ? (
          <div className="p-12 text-center text-text-muted text-sm">Loading users...</div>
        ) : filtered.length === 0 ? (
          <div className="p-12 text-center text-text-muted text-sm">No users found</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/[0.06]">
                  {["User", "Role", "Status", "Joined", "Actions"].map((h) => (
                    <th key={h} className="text-left px-5 py-3.5 text-xs font-semibold text-text-muted uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((user) => (
                  <tr key={user.id} className="border-b border-white/[0.04] hover:bg-white/[0.02] transition-colors">
                    <td className="px-5 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-brand-gradient flex items-center justify-center text-xs font-bold text-white flex-shrink-0">
                          {user.full_name?.[0]?.toUpperCase() ?? "N"}
                        </div>
                        <div>
                          <div className="text-sm font-medium text-white">{user.full_name}</div>
                          <div className="text-xs text-text-muted">{user.email}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-5 py-4">
                      <div className="relative">
                        <button
                          onClick={() => setEditingRole(editingRole === user.id ? null : user.id)}
                          className={`flex items-center gap-1.5 text-xs font-semibold px-2.5 py-1 rounded-full capitalize ${roleBadge[user.role]}`}
                        >
                          {user.role.replace("_", " ")}
                          <ChevronDown className="w-3 h-3" />
                        </button>
                        {editingRole === user.id && (
                          <div className="absolute top-8 left-0 z-10 w-36 glass-card border border-white/[0.08] shadow-card-hover overflow-hidden">
                            {ROLES.map((r) => (
                              <button
                                key={r}
                                onClick={() => updateRole(user.id, r)}
                                className={`w-full text-left px-3 py-2.5 text-xs font-medium capitalize hover:bg-white/[0.06] transition-colors ${user.role === r ? "text-brand-blue-light" : "text-text-secondary"}`}
                              >
                                {r.replace("_", " ")}
                              </button>
                            ))}
                          </div>
                        )}
                      </div>
                    </td>
                    <td className="px-5 py-4">
                      <span className={`text-xs px-2.5 py-1 rounded-full font-semibold capitalize ${user.status === "active" ? "bg-brand-green/10 text-brand-green" : "bg-red-500/10 text-red-400"}`}>
                        {user.status}
                      </span>
                    </td>
                    <td className="px-5 py-4">
                      <span className="text-xs text-text-muted">{formatDate(user.created_at)}</span>
                    </td>
                    <td className="px-5 py-4">
                      <button
                        onClick={() => toggleStatus(user)}
                        className="flex items-center gap-1.5 text-xs text-text-muted hover:text-white transition-colors"
                      >
                        {user.status === "active" ? <><Ban className="w-3.5 h-3.5 text-red-400" /> Suspend</> : <><CheckCircle className="w-3.5 h-3.5 text-brand-green" /> Activate</>}
                      </button>
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
