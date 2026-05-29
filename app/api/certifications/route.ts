import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import { generateVerificationCode } from "@/utils/format";
import type { ApiResponse } from "@/types/api.types";
export async function GET(request: NextRequest) {
  const code = new URL(request.url).searchParams.get("code");
  if (!code) return NextResponse.json<ApiResponse<null>>({ success:false, error:"Code required" }, { status:400 });
  const supabase = await createAdminClient();
  const { data, error } = await supabase.from("certifications").select("*, users(full_name)").eq("verification_code", code).single();
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
    const { target_user_id, title, description, issued_by, expires_at } = await request.json();
    const verification_code = generateVerificationCode();
    const { data, error } = await supabase.from("certifications").insert({ user_id:target_user_id, title, description, issued_by, verification_code, expires_at, status:"active", issued_at:new Date().toISOString() }).select().single();
    if (error) throw error;
    return NextResponse.json<ApiResponse<typeof data>>({ success:true, data, message:"Certificate issued" });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success:false, error:"Failed to issue certificate" }, { status:500 });
  }
}
