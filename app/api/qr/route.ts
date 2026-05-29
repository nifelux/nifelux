import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import { generateQRCodeDataURL, buildVerifyUrl } from "@/lib/qr/generator";
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

    const { type, token } = await request.json();
    if (!token) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Token required" }, { status: 400 });

    const url = buildVerifyUrl(token);
    const qrDataUrl = await generateQRCodeDataURL(url);

    // Store QR code URL back to the record
    if (type === "id") {
      await supabase.from("digital_ids").update({ qr_code_url: qrDataUrl }).eq("id_number", token);
    }

    return NextResponse.json<ApiResponse<{ qr_url: string; verify_url: string }>>({
      success: true,
      data: { qr_url: qrDataUrl, verify_url: url },
    });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "QR generation failed" }, { status: 500 });
  }
}
