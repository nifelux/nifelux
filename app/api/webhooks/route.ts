import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import { ipayngClient } from "@/lib/ipayng/client";
import { emailService } from "@/lib/email/service";

export async function POST(request: NextRequest) {
  const body = await request.text();
  const signature = request.headers.get("x-ipayng-signature") ?? "";
  if (!ipayngClient.verifyWebhookSignature(body, signature)) {
    return NextResponse.json({ error: "Invalid signature" }, { status: 401 });
  }

  let event: { event: string; data: { reference: string; amount: number; customer: { email: string } } };
  try { event = JSON.parse(body); } catch { return NextResponse.json({ error: "Invalid JSON" }, { status: 400 }); }

  const supabase = await createAdminClient();

  if (event.event === "charge.success") {
    const { reference, amount, customer } = event.data;

    const { data: payment } = await supabase
      .from("payments")
      .update({ status: "success", paid_at: new Date().toISOString() })
      .eq("reference", reference)
      .select("id, user_id, amount, purpose, metadata")
      .single();

    if (payment) {
      const p = payment as { id: string; user_id: string | null; amount: number; purpose: string; metadata: Record<string, unknown> | null };

      if (p.purpose === "contribution") {
        await supabase.from("support_contributions").insert({
          payment_id: p.id,
          user_id: p.user_id,
          amount: p.amount,
          message: (p.metadata?.message as string) ?? null,
          anonymous: (p.metadata?.anonymous as boolean) ?? false,
        });
      }

      if (p.user_id) {
        await supabase.from("notifications").insert({
          user_id: p.user_id,
          title: "Payment Confirmed ✅",
          body: `₦${Number(p.amount).toLocaleString()} received. Ref: ${reference}`,
          type: "success",
        });
      }

      try {
        await emailService.sendPaymentReceipt({ to: customer.email, amount: amount / 100, reference, purpose: p.purpose });
      } catch (e) { console.error("Email failed:", e); }
    }
  }

  if (event.event === "charge.failed") {
    await supabase.from("payments").update({ status: "failed" }).eq("reference", event.data.reference);
  }

  return NextResponse.json({ received: true });
}
