import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import type { ApiResponse } from "@/types/api.types";
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { amount, email, purpose, metadata } = body;
    if (!amount || !email || !purpose) return NextResponse.json<ApiResponse<null>>({ success:false, error:"Missing fields" }, { status:400 });
    if (amount < 100) return NextResponse.json<ApiResponse<null>>({ success:false, error:"Minimum ₦100" }, { status:400 });
    const supabase = await createAdminClient();
    const reference = `NF-${Date.now()}-${Math.random().toString(36).substring(2,8).toUpperCase()}`;
    const { data:payment, error } = await supabase.from("payments").insert({ reference, amount, currency:"NGN", status:"pending", purpose, metadata:{ email, ...metadata } }).select().single();
    if (error) throw error;
    // TODO: Replace payment_url with real iPayNG checkout URL
    return NextResponse.json<ApiResponse<{ reference:string; payment_url:string }>>({ success:true, data:{ reference, payment_url:`https://pay.ipayng.com/pay/${reference}` } });
  } catch (error) {
    return NextResponse.json<ApiResponse<null>>({ success:false, error:"Payment initiation failed" }, { status:500 });
  }
}
