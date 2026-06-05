import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/utils/server-auth";
import { createAdminClient } from "@/lib/supabase/server";
import { generateVerificationCode } from "@/utils/format";
import { emailService } from "@/lib/email/service";
import type { ApiResponse } from "@/types/api.types";

export async function GET(request: NextRequest) {
  const code = new URL(request.url).searchParams.get("code");
  if (!code) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Code required" }, { status: 400 });
  const supabase = await createAdminClient();
  const { data, error } = await supabase.from("certifications").select("*, users(full_name, email)").eq("verification_code", code).single();
  if (error) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Not found" }, { status: 404 });
  return NextResponse.json<ApiResponse<typeof data>>({ success: true, data });
}

export async function POST(request: NextRequest) {
  try {
    const { supabase, userId, isAdmin } = await requireAdmin();
    if (!userId) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });
    if (!isAdmin) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });

    const body = await request.json();
    const { target_user_id, title, description, issued_by, expires_at } = body;
    const verification_code = generateVerificationCode();

    const { data: cert, error } = await supabase
      .from("certifications")
      .insert({
        user_id: target_user_id as string,
        title: title as string,
        description: (description ?? null) as string | null,
        issued_by: issued_by as string,
        verification_code,
        expires_at: (expires_at ?? null) as string | null,
        status: "active",
        issued_at: new Date().toISOString(),
      })
      .select("*, users(full_name, email)")
      .single();

    if (error) throw error;

    await supabase.from("notifications").insert({
      user_id: target_user_id as string,
      title: "Certificate Issued 🏆",
      body: `You have been awarded: ${title as string}`,
      type: "success",
    });

    const recipient = cert.users as { full_name: string; email: string } | null;
    if (recipient?.email) {
      await emailService.sendCertificateIssued({ to: recipient.email, name: recipient.full_name, title: title as string, verificationCode: verification_code }).catch(console.error);
    }

    return NextResponse.json<ApiResponse<typeof cert>>({ success: true, data: cert, message: "Certificate issued" });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to issue certificate" }, { status: 500 });
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const { supabase, userId, isAdmin } = await requireAdmin();
    if (!userId) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });
    if (!isAdmin) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });

    const { id, status } = await request.json();
    const { error } = await supabase.from("certifications").update({ status: status as "active" | "expired" | "revoked" }).eq("id", id as string);
    if (error) throw error;
    return NextResponse.json<ApiResponse<null>>({ success: true, data: null, message: "Updated" });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to update" }, { status: 500 });
  }
}
