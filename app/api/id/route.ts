import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import { generateIdNumber } from "@/utils/format";
import type { ApiResponse } from "@/types/api.types";
export async function GET(request: NextRequest) {
  const id = new URL(request.url).searchParams.get("id");
  if (!id) return NextResponse.json<ApiResponse<null>>({ success:false, error:"ID required" }, { status:400 });
  const supabase = await createAdminClient();
  const { data, error } = await supabase.from("digital_ids").select("*, users(full_name, email)").eq("id_number", id).single();
  if (error) return NextResponse.json<ApiResponse<null>>({ success:false, error:"Not found" }, { status:404 });
  return NextResponse.json<ApiResponse<typeof data>>({ success:true, data });
}
export async function POST(request: NextRequest) {
  try {
    const supabase = await createAdminClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return NextResponse.json<ApiResponse<null>>({ success:false, error:"Unauthorized" }, { status:401 });
    const { data: profile } = await supabase.from("users").select("role").eq("id", user.id).single();
    if (!profile || !["admin","super_admin"].includes(profile.role)) return NextResponse.json<ApiResponse<null>>({ success:false, error:"Forbidden" }, { status:403 });
    const { target_user_id } = await request.json();
    const id_number = generateIdNumber();
    const expires_at = new Date(Date.now() + 365*24*60*60*1000).toISOString();
    const { data, error } = await supabase.from("digital_ids").insert({ user_id:target_user_id, id_number, qr_code_url:"", expires_at, status:"active" }).select().single();
    if (error) throw error;
    return NextResponse.json<ApiResponse<typeof data>>({ success:true, data, message:"ID issued" });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success:false, error:"Failed to issue ID" }, { status:500 });
  }
}
