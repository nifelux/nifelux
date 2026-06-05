import { createAdminClient } from "@/lib/supabase/server";

interface LogParams {
  actor_id: string;
  action: string;
  target_type?: string;
  target_id?: string;
  metadata?: Record<string, unknown>;
  ip_address?: string;
}

export async function logActivity(params: LogParams): Promise<void> {
  try {
    const supabase = await createAdminClient();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    await (supabase as any).from("activity_logs").insert({
      actor_id: params.actor_id,
      action: params.action,
      target_type: params.target_type ?? null,
      target_id: params.target_id ?? null,
      metadata: params.metadata ?? {},
      ip_address: params.ip_address ?? null,
    });
  } catch (err) {
    console.error("Activity log failed:", err);
  }
}

export function getClientIp(request: Request): string {
  const forwarded = request.headers.get("x-forwarded-for");
  return forwarded ? forwarded.split(",")[0].trim() : "unknown";
}
