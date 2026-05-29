"use client";
import { useEffect, useState, useCallback } from "react";
import { Activity, RefreshCw, Search } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import { formatDate } from "@/utils/format";

interface Log {
  id: string;
  actor_id: string;
  action: string;
  target_type: string;
  ip_address: string;
  created_at: string;
  users?: { full_name: string; email: string };
}

export default function ActivityLogsPage() {
  const [logs, setLogs] = useState<Log[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  const fetchLogs = useCallback(async () => {
    setLoading(true);
    const s = createClient();
    const { data } = await s
      .from("activity_logs")
      .select("*, users(full_name, email)")
      .order("created_at", { ascending: false })
      .limit(100);
    setLogs((data ?? []) as Log[]);
    setLoading(false);
  }, []);

  useEffect(() => { fetchLogs(); }, [fetchLogs]);

  const filtered = logs.filter((l) =>
    l.action?.toLowerCase().includes(search.toLowerCase()) ||
    l.users?.full_name?.toLowerCase().includes(search.toLowerCase()) ||
    l.target_type?.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div>
        <h2 className="font-display text-2xl font-bold text-white mb-1">Activity Logs</h2>
        <p className="text-text-muted text-sm">Full audit trail of platform activity.</p>
      </div>

      <GlassCard className="border border-white/[0.05] overflow-hidden">
        <div className="p-4 border-b border-white/[0.06] flex items-center justify-between gap-4">
          <div className="relative flex-1 max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search logs..." className="input-brand pl-9" />
          </div>
          <button onClick={fetchLogs} className="w-9 h-9 glass rounded-lg flex items-center justify-center text-text-muted hover:text-white transition-colors">
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>

        {loading ? (
          <div className="p-12 text-center text-text-muted text-sm">Loading logs...</div>
        ) : filtered.length === 0 ? (
          <div className="p-12 text-center">
            <Activity className="w-10 h-10 text-text-muted mx-auto mb-3" />
            <p className="text-text-muted text-sm">No activity logs yet.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/[0.06]">
                  {["Actor", "Action", "Target", "IP", "Time"].map((h) => (
                    <th key={h} className="text-left px-5 py-3.5 text-xs font-semibold text-text-muted uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((log) => (
                  <tr key={log.id} className="border-b border-white/[0.04] hover:bg-white/[0.02] transition-colors">
                    <td className="px-5 py-3.5">
                      <div className="text-sm font-medium text-white">{log.users?.full_name ?? "System"}</div>
                      <div className="text-xs text-text-muted">{log.users?.email ?? "—"}</div>
                    </td>
                    <td className="px-5 py-3.5"><span className="text-sm text-white font-mono text-xs">{log.action}</span></td>
                    <td className="px-5 py-3.5"><span className="text-xs text-text-muted capitalize">{log.target_type ?? "—"}</span></td>
                    <td className="px-5 py-3.5"><span className="text-xs text-text-muted font-mono">{log.ip_address ?? "—"}</span></td>
                    <td className="px-5 py-3.5"><span className="text-xs text-text-muted">{formatDate(log.created_at)}</span></td>
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
