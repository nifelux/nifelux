import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/utils/server-auth";
import type { ApiResponse } from "@/types/api.types";

export async function POST(request: NextRequest) {
  try {
    const { supabase, userId, isAdmin } = await requireAdmin();
    if (!userId) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });
    if (!isAdmin) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });

    const { user_ids, title, body, type = "info" } = await request.json();
    if (!title || !body) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Missing title or body" }, { status: 400 });

    const rows = (user_ids as string[]).map((uid) => ({
      user_id: uid, title: title as string, body: body as string,
      type: (type as "info" | "success" | "warning" | "alert"),
    }));
    const { error } = await supabase.from("notifications").insert(rows);
    if (error) throw error;
    return NextResponse.json<ApiResponse<{ sent: number }>>({ success: true, data: { sent: rows.length } });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to send" }, { status: 500 });
  }
}
