import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import { ipayngClient } from "@/lib/ipayng/client";
import type { ApiResponse } from "@/types/api.types";
import { z } from "zod";

const schema = z.object({
  amount: z.number().min(100, "Minimum ₦100"),
  email: z.string().email(),
  purpose: z.string().min(2),
  user_id: z.string().optional(),
  anonymous: z.boolean().optional(),
  message: z.string().optional(),
});

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const parsed = schema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json<ApiResponse<null>>(
        { success: false, error: parsed.error.errors[0].message },
        { status: 400 }
      );
    }

    const { amount, email, purpose, user_id, anonymous, message } = parsed.data;
    const supabase = await createAdminClient();

    // Generate unique reference
    const reference = `NF-${Date.now()}-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;

    // Store pending payment
    const { data: payment, error: paymentError } = await supabase
      .from("payments")
      .insert({
        reference,
        amount,
        currency: "NGN",
        status: "pending",
        purpose,
        user_id: user_id ?? null,
        metadata: { email, anonymous: anonymous ?? false, message: message ?? "" },
      })
      .select()
      .single();

    if (paymentError) throw paymentError;

    // Call iPayNG
    const callbackUrl = `${process.env.NEXT_PUBLIC_APP_URL}/payment/callback?reference=${reference}`;
    const ipayng = await ipayngClient.initiatePayment({
      email,
      amount: amount * 100, // convert to kobo
      reference,
      callback_url: callbackUrl,
      metadata: { purpose, user_id, anonymous },
    });

    return NextResponse.json<ApiResponse<{ payment_url: string; reference: string }>>({
      success: true,
      data: {
        payment_url: ipayng.data.authorization_url,
        reference,
      },
    });
  } catch (error) {
    console.error("Payment initiation error:", error);
    return NextResponse.json<ApiResponse<null>>(
      { success: false, error: "Payment initiation failed" },
      { status: 500 }
    );
  }
}

export async function GET(request: NextRequest) {
  const reference = new URL(request.url).searchParams.get("reference");
  if (!reference) {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Reference required" }, { status: 400 });
  }

  try {
    const supabase = await createAdminClient();
    const { data, error } = await supabase
      .from("payments")
      .select("*")
      .eq("reference", reference)
      .single();

    if (error) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Payment not found" }, { status: 404 });
    return NextResponse.json<ApiResponse<typeof data>>({ success: true, data });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to fetch payment" }, { status: 500 });
  }
}
