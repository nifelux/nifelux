import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/utils/server-auth";
import type { ApiResponse } from "@/types/api.types";

export async function POST(request: NextRequest) {
  try {
    const { supabase, userId, isAdmin } = await requireAdmin();
    if (!userId) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });
    if (!isAdmin) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });

    const { type, token } = await request.json();
    if (!token) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Token required" }, { status: 400 });

    const url = `${process.env.NEXT_PUBLIC_APP_URL}/verify/${token as string}`;

    if (type === "id") {
      await supabase.from("digital_ids").update({ qr_code_url: url }).eq("id_number", token as string);
    }

    return NextResponse.json<ApiResponse<{ verify_url: string }>>({ success: true, data: { verify_url: url } });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "QR generation failed" }, { status: 500 });
  }
}
