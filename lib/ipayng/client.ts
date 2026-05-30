// ============================================
// NIFELUX — iPayNG Payment Gateway Client
// All calls run SERVER-SIDE only
// Never import this in client components
// ============================================

const IPAYNG_BASE = "https://api.ipayng.com/v1";

interface InitiatePaymentParams {
  email: string;
  amount: number; // in kobo (NGN * 100)
  reference: string;
  callback_url: string;
  metadata?: Record<string, unknown>;
}

interface InitiatePaymentResponse {
  status: boolean;
  message: string;
  data: {
    authorization_url: string;
    access_code: string;
    reference: string;
  };
}

interface VerifyPaymentResponse {
  status: boolean;
  message: string;
  data: {
    status: string; // "success" | "failed" | "pending"
    reference: string;
    amount: number;
    paid_at: string;
    customer: { email: string };
  };
}

export const ipayngClient = {
  async initiatePayment(params: InitiatePaymentParams): Promise<InitiatePaymentResponse> {
    const res = await fetch(`${IPAYNG_BASE}/transaction/initialize`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.IPAYNG_SECRET_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: params.email,
        amount: params.amount,
        reference: params.reference,
        callback_url: params.callback_url,
        metadata: params.metadata ?? {},
      }),
    });

    if (!res.ok) {
      const err = await res.text();
      throw new Error(`iPayNG initiate failed: ${err}`);
    }

    return res.json();
  },

  async verifyPayment(reference: string): Promise<VerifyPaymentResponse> {
    const res = await fetch(`${IPAYNG_BASE}/transaction/verify/${reference}`, {
      headers: {
        Authorization: `Bearer ${process.env.IPAYNG_SECRET_KEY}`,
      },
    });

    if (!res.ok) {
      const err = await res.text();
      throw new Error(`iPayNG verify failed: ${err}`);
    }

    return res.json();
  },

  verifyWebhookSignature(payload: string, signature: string): boolean {
    const crypto = require("crypto");
    const expected = crypto
      .createHmac("sha512", process.env.IPAYNG_WEBHOOK_SECRET!)
      .update(payload)
      .digest("hex");
    return expected === signature;
  },
};
