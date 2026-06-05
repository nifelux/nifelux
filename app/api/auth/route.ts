import { NextRequest, NextResponse } from "next/server";
import { getCurrentUser } from "@/utils/server-auth";
import type { ApiResponse } from "@/types/api.types";

export async function GET(_request: NextRequest) {
  try {
    const { supabase, user } = await getCurrentUser();
    if (!user) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Not authenticated" }, { status: 401 });
    const { data: profile } = await supabase.from("users").select("*").eq("id", user.id).single();
    return NextResponse.json<ApiResponse<typeof profile>>({ success: true, data: profile });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Server error" }, { status: 500 });
  }
}
