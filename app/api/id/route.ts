import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/utils/server-auth";
import { createAdminClient } from "@/lib/supabase/server";
import { generateIdNumber } from "@/utils/format";
import { emailService } from "@/lib/email/service";
import type { ApiResponse } from "@/types/api.types";

export async function GET(request: NextRequest) {
  const id = new URL(request.url).searchParams.get("id");
  if (!id) return NextResponse.json<ApiResponse<null>>({ success: false, error: "ID required" }, { status: 400 });
  const supabase = await createAdminClient();
  const { data, error } = await supabase.from("digital_ids").select("*, users(full_name, email)").eq("id_number", id).single();
  if (error) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Not found" }, { status: 404 });
  return NextResponse.json<ApiResponse<typeof data>>({ success: true, data });
}

export async function POST(request: NextRequest) {
  try {
    const { supabase, userId, isAdmin } = await requireAdmin();
    if (!userId) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });
    if (!isAdmin) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });

    const { target_user_id } = await request.json();
    const id_number = generateIdNumber();
    const expires_at = new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString();

    const { data: newId, error } = await supabase
      .from("digital_ids")
      .insert({
        user_id: target_user_id as string,
        id_number,
        qr_code_url: null,
        expires_at,
        status: "active",
      })
      .select("*, users(full_name, email)")
      .single();

    if (error) throw error;

    await supabase.from("notifications").insert({
      user_id: target_user_id as string,
      title: "Digital ID Issued 🪪",
      body: `Your Nifelux Digital ID (${id_number}) is now active.`,
      type: "success",
    });

    const recipient = newId.users as { full_name: string; email: string } | null;
    if (recipient?.email) {
      await emailService.sendIdIssued({ to: recipient.email, name: recipient.full_name, idNumber: id_number }).catch(console.error);
    }

    return NextResponse.json<ApiResponse<typeof newId>>({ success: true, data: newId, message: "ID issued" });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to issue ID" }, { status: 500 });
  }
}
