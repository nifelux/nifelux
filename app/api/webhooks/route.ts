import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import { ipayngClient } from "@/lib/ipayng/client";
import { emailService } from "@/lib/email/service";

export async function POST(request: NextRequest) {
  const body = await request.text();
  const signature = request.headers.get("x-ipayng-signature") ?? "";

  // Verify signature
  if (!ipayngClient.verifyWebhookSignature(body, signature)) {
    return NextResponse.json({ error: "Invalid signature" }, { status: 401 });
  }

  let event: { event: string; data: { reference: string; amount: number; customer: { email: string } } };
  try {
    event = JSON.parse(body);
  } catch {
    return NextResponse.json({ error: "Invalid JSON" }, { status: 400 });
  }

  const supabase = await createAdminClient();

  if (event.event === "charge.success") {
    const { reference, amount, customer } = event.data;

    // Update payment record
    const { data: payment } = await supabase
      .from("payments")
      .update({ status: "success", paid_at: new Date().toISOString() })
      .eq("reference", reference)
      .select("*, users(id, full_name, email)")
      .single();

    if (payment) {
      // Log if it's a contribution
      if (payment.purpose === "contribution") {
        await supabase.from("support_contributions").insert({
          payment_id: payment.id,
          user_id: payment.user_id ?? null,
          amount: payment.amount,
          message: payment.metadata?.message ?? "",
          anonymous: payment.metadata?.anonymous ?? false,
        });
      }

      // Notify user if logged in
      if (payment.user_id) {
        await supabase.from("notifications").insert({
          user_id: payment.user_id,
          title: "Payment Confirmed",
          body: `Your payment of ₦${Number(payment.amount).toLocaleString()} was successful. Reference: ${reference}`,
          type: "success",
        });
      }

      // Send email receipt
      try {
        await emailService.sendPaymentReceipt({
          to: customer.email,
          amount: amount / 100,
          reference,
          purpose: payment.purpose,
        });
      } catch (emailErr) {
        console.error("Email receipt failed:", emailErr);
      }
    }
  }

  if (event.event === "charge.failed") {
    await supabase
      .from("payments")
      .update({ status: "failed" })
      .eq("reference", event.data.reference);
  }

  return NextResponse.json({ received: true });
}
