import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import type { ApiResponse } from "@/types/api.types";

export async function POST(request: NextRequest) {
  try {
    const supabase = await createAdminClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });

    const { data: profile } = await supabase.from("users").select("role").eq("id", user.id).single();
    if (!profile || !["admin", "super_admin"].includes(profile.role)) {
      return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });
    }

    const { user_ids, title, body, type = "info" } = await request.json();
    if (!title || !body) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Missing title or body" }, { status: 400 });

    const rows = (user_ids as string[]).map((uid: string) => ({ user_id: uid, title, body, type }));
    const { error } = await supabase.from("notifications").insert(rows);
    if (error) throw error;

    return NextResponse.json<ApiResponse<{ sent: number }>>({ success: true, data: { sent: rows.length }, message: "Notifications sent" });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to send" }, { status: 500 });
  }
}
