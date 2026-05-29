import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import crypto from "crypto";
export async function POST(request: NextRequest) {
  try {
    const body = await request.text();
    const sig = request.headers.get("x-ipayng-signature") ?? "";
    const expected = crypto.createHmac("sha256", process.env.IPAYNG_WEBHOOK_SECRET!).update(body).digest("hex");
    if (sig !== expected) return NextResponse.json({ error:"Invalid signature" }, { status:401 });
    const event = JSON.parse(body);
    const supabase = await createAdminClient();
    if (event.event === "charge.success") {
      await supabase.from("payments").update({ status:"success", paid_at:new Date().toISOString() }).eq("reference", event.data.reference);
    }
    return NextResponse.json({ received:true });
  } catch {
    return NextResponse.json({ error:"Webhook failed" }, { status:500 });
  }
}
