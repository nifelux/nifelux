import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/utils/server-auth";
import type { ApiResponse } from "@/types/api.types";

export async function GET(_request: NextRequest) {
  try {
    const { supabase, userId, isAdmin } = await requireAdmin();
    if (!userId) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });
    if (!isAdmin) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });
    const { data, error } = await supabase.from("users").select("*").order("created_at", { ascending: false });
    if (error) throw error;
    return NextResponse.json<ApiResponse<typeof data>>({ success: true, data });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to fetch users" }, { status: 500 });
  }
}
