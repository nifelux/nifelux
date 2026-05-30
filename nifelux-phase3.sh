#!/bin/bash
#!/bin/bash

# ============================================
# NIFELUX TECHNOLOGIES — PHASE 3
# Payments (iPayNG), Contributions, Email (Resend), Analytics
# Run from project ROOT (no src/)
# ============================================

echo ""
echo "💳 Nifelux Phase 3 — Payments, Email & Analytics..."
echo "=================================================="

# ============================================
# STEP 1: IPAYNG PAYMENT CLIENT
# ============================================
echo "💳 Writing iPayNG client..."

mkdir -p lib/ipayng

cat > lib/ipayng/client.ts << 'EOF'
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
EOF

echo "✅ iPayNG client written"

# ============================================
# STEP 2: PAYMENT API ROUTE (UPDATED)
# ============================================
echo "🔌 Updating payment API route..."

cat > app/api/payments/route.ts << 'EOF'
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
EOF

echo "✅ Payment API updated"

# ============================================
# STEP 3: WEBHOOK ROUTE (FULL iPayNG HANDLER)
# ============================================
echo "🪝 Writing webhook handler..."

cat > app/api/webhooks/route.ts << 'EOF'
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
EOF

echo "✅ Webhook handler written"

# ============================================
# STEP 4: PAYMENT CALLBACK PAGE
# ============================================
echo "📄 Writing payment callback page..."

mkdir -p app/payment/callback

cat > app/payment/callback/page.tsx << 'EOF'
"use client";
import { useEffect, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { CheckCircle, XCircle, Loader2, ArrowRight } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";

type Status = "loading" | "success" | "failed";

export default function PaymentCallbackPage() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const reference = searchParams.get("reference");
  const [status, setStatus] = useState<Status>("loading");
  const [amount, setAmount] = useState<number | null>(null);

  useEffect(() => {
    if (!reference) { setStatus("failed"); return; }

    const checkPayment = async () => {
      try {
        const res = await fetch(`/api/payments?reference=${reference}`);
        const json = await res.json();
        if (json.success) {
          setAmount(json.data.amount);
          setStatus(json.data.status === "success" ? "success" : "failed");
        } else {
          setStatus("failed");
        }
      } catch {
        setStatus("failed");
      }
    };

    // Poll for 10 seconds to allow webhook to process
    const timer = setTimeout(checkPayment, 2000);
    return () => clearTimeout(timer);
  }, [reference]);

  return (
    <div className="min-h-screen bg-brand-dark flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-hero-gradient" />
      <div className="absolute inset-0 dot-pattern opacity-20" />
      <div className="relative z-10 w-full max-w-md">
        <GlassCard variant="gradient" className="p-10 border border-white/[0.06] text-center">
          {status === "loading" && (
            <>
              <Loader2 className="w-14 h-14 text-brand-blue-light mx-auto mb-5 animate-spin" />
              <h1 className="font-display text-xl font-bold text-white mb-2">Confirming Payment</h1>
              <p className="text-text-muted text-sm">Please wait while we verify your transaction...</p>
            </>
          )}

          {status === "success" && (
            <>
              <div className="w-16 h-16 rounded-2xl bg-brand-green/10 border border-brand-green/20 flex items-center justify-center mx-auto mb-5">
                <CheckCircle className="w-8 h-8 text-brand-green" />
              </div>
              <h1 className="font-display text-xl font-bold text-white mb-2">Payment Successful!</h1>
              {amount && (
                <p className="text-brand-green font-bold text-2xl mb-2">
                  ₦{amount.toLocaleString()}
                </p>
              )}
              <p className="text-text-muted text-sm mb-2">Reference: <span className="font-mono text-xs text-white">{reference}</span></p>
              <p className="text-text-muted text-sm mb-8">Thank you for supporting Nifelux Technologies. A receipt has been sent to your email.</p>
              <div className="flex flex-col gap-3">
                <GradientButton href="/dashboard" variant="blue-purple" size="md" icon={<ArrowRight className="w-4 h-4" />}>
                  Go to Dashboard
                </GradientButton>
                <GradientButton href="/" variant="outline" size="md">Back to Home</GradientButton>
              </div>
            </>
          )}

          {status === "failed" && (
            <>
              <div className="w-16 h-16 rounded-2xl bg-red-500/10 border border-red-500/20 flex items-center justify-center mx-auto mb-5">
                <XCircle className="w-8 h-8 text-red-400" />
              </div>
              <h1 className="font-display text-xl font-bold text-white mb-2">Payment Failed</h1>
              <p className="text-text-muted text-sm mb-8">
                Your payment could not be processed. No charges were made.
                Please try again or contact us if the issue persists.
              </p>
              <div className="flex flex-col gap-3">
                <GradientButton href="/support" variant="blue-purple" size="md">Try Again</GradientButton>
                <GradientButton href="/contact" variant="outline" size="md">Contact Support</GradientButton>
              </div>
            </>
          )}
        </GlassCard>
      </div>
    </div>
  );
}
EOF

echo "✅ Payment callback page written"

# ============================================
# STEP 5: EMAIL SERVICE (RESEND)
# ============================================
echo "📧 Writing email service..."

mkdir -p lib/email

cat > lib/email/service.ts << 'EOF'
// ============================================
// NIFELUX — Email Service (Resend)
// SERVER-SIDE ONLY — never import in client
// ============================================

const RESEND_API = "https://api.resend.com/emails";
const FROM = "Nifelux Technologies <noreply@nifelux.com>";

async function sendEmail(payload: {
  to: string;
  subject: string;
  html: string;
}) {
  if (!process.env.RESEND_API_KEY) {
    console.warn("RESEND_API_KEY not set — email skipped");
    return;
  }

  const res = await fetch(RESEND_API, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ from: FROM, ...payload }),
  });

  if (!res.ok) {
    const err = await res.text();
    console.error("Email send failed:", err);
    throw new Error(`Email failed: ${err}`);
  }

  return res.json();
}

export const emailService = {
  async sendPaymentReceipt({
    to,
    amount,
    reference,
    purpose,
  }: {
    to: string;
    amount: number;
    reference: string;
    purpose: string;
  }) {
    return sendEmail({
      to,
      subject: `Payment Receipt — ₦${amount.toLocaleString()} | Nifelux Technologies`,
      html: `
        <div style="font-family:system-ui,sans-serif;max-width:520px;margin:0 auto;background:#050816;color:#fff;border-radius:16px;overflow:hidden;">
          <div style="background:linear-gradient(135deg,#2563EB,#7C3AED);padding:32px 24px;text-align:center;">
            <h1 style="margin:0;font-size:24px;font-weight:700;">Nifelux Technologies</h1>
            <p style="margin:8px 0 0;opacity:0.8;font-size:14px;">Payment Receipt</p>
          </div>
          <div style="padding:32px 24px;">
            <p style="color:#CBD5E1;font-size:14px;margin:0 0 24px;">Thank you for your payment. Here are your transaction details:</p>
            <div style="background:#111827;border-radius:12px;padding:20px;margin-bottom:24px;">
              <div style="display:flex;justify-content:space-between;margin-bottom:12px;">
                <span style="color:#94A3B8;font-size:13px;">Amount</span>
                <span style="color:#22C55E;font-weight:700;font-size:18px;">₦${amount.toLocaleString()}</span>
              </div>
              <div style="display:flex;justify-content:space-between;margin-bottom:12px;">
                <span style="color:#94A3B8;font-size:13px;">Reference</span>
                <span style="color:#fff;font-size:12px;font-family:monospace;">${reference}</span>
              </div>
              <div style="display:flex;justify-content:space-between;margin-bottom:12px;">
                <span style="color:#94A3B8;font-size:13px;">Purpose</span>
                <span style="color:#fff;font-size:13px;text-transform:capitalize;">${purpose}</span>
              </div>
              <div style="display:flex;justify-content:space-between;">
                <span style="color:#94A3B8;font-size:13px;">Status</span>
                <span style="color:#22C55E;font-size:13px;font-weight:600;">Successful ✓</span>
              </div>
            </div>
            <p style="color:#64748B;font-size:12px;text-align:center;margin:0;">
              Questions? Contact us at <a href="mailto:hello@nifelux.com" style="color:#3B82F6;">hello@nifelux.com</a>
            </p>
          </div>
          <div style="background:#0B1120;padding:16px 24px;text-align:center;">
            <p style="color:#475569;font-size:11px;margin:0;">© ${new Date().getFullYear()} Nifelux Technologies, Lagos Nigeria</p>
          </div>
        </div>
      `,
    });
  },

  async sendWelcomeEmail({ to, name }: { to: string; name: string }) {
    return sendEmail({
      to,
      subject: "Welcome to Nifelux Technologies 🚀",
      html: `
        <div style="font-family:system-ui,sans-serif;max-width:520px;margin:0 auto;background:#050816;color:#fff;border-radius:16px;overflow:hidden;">
          <div style="background:linear-gradient(135deg,#2563EB,#7C3AED);padding:32px 24px;text-align:center;">
            <h1 style="margin:0;font-size:24px;font-weight:700;">Welcome to Nifelux</h1>
          </div>
          <div style="padding:32px 24px;">
            <h2 style="margin:0 0 12px;font-size:20px;">Hi ${name} 👋</h2>
            <p style="color:#CBD5E1;font-size:14px;line-height:1.6;margin:0 0 24px;">
              Your Nifelux Technologies account has been created successfully.
              You now have access to your digital dashboard, certifications, and ID management.
            </p>
            <a href="${process.env.NEXT_PUBLIC_APP_URL}/dashboard" 
               style="display:inline-block;background:linear-gradient(135deg,#2563EB,#7C3AED);color:#fff;padding:12px 24px;border-radius:10px;text-decoration:none;font-weight:600;font-size:14px;">
              Go to Dashboard →
            </a>
          </div>
          <div style="background:#0B1120;padding:16px 24px;text-align:center;">
            <p style="color:#475569;font-size:11px;margin:0;">© ${new Date().getFullYear()} Nifelux Technologies, Lagos Nigeria</p>
          </div>
        </div>
      `,
    });
  },

  async sendCertificateIssued({
    to,
    name,
    title,
    verificationCode,
  }: {
    to: string;
    name: string;
    title: string;
    verificationCode: string;
  }) {
    return sendEmail({
      to,
      subject: `Your Certificate: ${title} | Nifelux Technologies`,
      html: `
        <div style="font-family:system-ui,sans-serif;max-width:520px;margin:0 auto;background:#050816;color:#fff;border-radius:16px;overflow:hidden;">
          <div style="background:linear-gradient(135deg,#22C55E,#2563EB);padding:32px 24px;text-align:center;">
            <h1 style="margin:0;font-size:24px;font-weight:700;">🏆 Certificate Issued</h1>
          </div>
          <div style="padding:32px 24px;">
            <h2 style="margin:0 0 8px;font-size:18px;">Congratulations, ${name}!</h2>
            <p style="color:#CBD5E1;font-size:14px;line-height:1.6;margin:0 0 24px;">
              You have been awarded the following certificate by Nifelux Technologies:
            </p>
            <div style="background:#111827;border-radius:12px;padding:20px;margin-bottom:24px;text-align:center;">
              <p style="color:#22C55E;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:0.1em;margin:0 0 8px;">Certificate of Achievement</p>
              <h3 style="color:#fff;font-size:20px;margin:0 0 16px;">${title}</h3>
              <p style="color:#94A3B8;font-size:11px;margin:0 0 4px;">Verification Code</p>
              <p style="color:#fff;font-family:monospace;font-size:14px;background:#1F2937;padding:8px 16px;border-radius:8px;display:inline-block;margin:0;">${verificationCode}</p>
            </div>
            <a href="${process.env.NEXT_PUBLIC_APP_URL}/verify/${verificationCode}"
               style="display:inline-block;background:linear-gradient(135deg,#22C55E,#2563EB);color:#fff;padding:12px 24px;border-radius:10px;text-decoration:none;font-weight:600;font-size:14px;">
              View & Verify Certificate →
            </a>
          </div>
          <div style="background:#0B1120;padding:16px 24px;text-align:center;">
            <p style="color:#475569;font-size:11px;margin:0;">© ${new Date().getFullYear()} Nifelux Technologies, Lagos Nigeria</p>
          </div>
        </div>
      `,
    });
  },

  async sendIdIssued({
    to,
    name,
    idNumber,
  }: {
    to: string;
    name: string;
    idNumber: string;
  }) {
    return sendEmail({
      to,
      subject: "Your Nifelux Digital ID Has Been Issued",
      html: `
        <div style="font-family:system-ui,sans-serif;max-width:520px;margin:0 auto;background:#050816;color:#fff;border-radius:16px;overflow:hidden;">
          <div style="background:linear-gradient(135deg,#2563EB,#7C3AED);padding:32px 24px;text-align:center;">
            <h1 style="margin:0;font-size:24px;font-weight:700;">🪪 Digital ID Issued</h1>
          </div>
          <div style="padding:32px 24px;">
            <h2 style="margin:0 0 12px;font-size:18px;">Hi ${name},</h2>
            <p style="color:#CBD5E1;font-size:14px;line-height:1.6;margin:0 0 24px;">Your Nifelux Digital ID has been issued and is now active.</p>
            <div style="background:#111827;border-radius:12px;padding:20px;margin-bottom:24px;text-align:center;">
              <p style="color:#94A3B8;font-size:11px;margin:0 0 8px;">ID Number</p>
              <p style="color:#fff;font-family:monospace;font-size:20px;font-weight:700;margin:0;">${idNumber}</p>
            </div>
            <a href="${process.env.NEXT_PUBLIC_APP_URL}/id-card"
               style="display:inline-block;background:linear-gradient(135deg,#2563EB,#7C3AED);color:#fff;padding:12px 24px;border-radius:10px;text-decoration:none;font-weight:600;font-size:14px;">
              View My ID Card →
            </a>
          </div>
          <div style="background:#0B1120;padding:16px 24px;text-align:center;">
            <p style="color:#475569;font-size:11px;margin:0;">© ${new Date().getFullYear()} Nifelux Technologies, Lagos Nigeria</p>
          </div>
        </div>
      `,
    });
  },
};
EOF

echo "✅ Email service written"

# ============================================
# STEP 6: WIRE EMAIL INTO CERTIFICATIONS API
# ============================================
echo "🔗 Wiring email into certifications API..."

cat > app/api/certifications/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
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
    const supabase = await createAdminClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });

    const { data: profile } = await supabase.from("users").select("role").eq("id", user.id).single();
    if (!profile || !["admin", "super_admin"].includes(profile.role)) {
      return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });
    }

    const { target_user_id, title, description, issued_by, expires_at } = await request.json();
    const verification_code = generateVerificationCode();

    const { data: cert, error } = await supabase
      .from("certifications")
      .insert({ user_id: target_user_id, title, description, issued_by, verification_code, expires_at, status: "active", issued_at: new Date().toISOString() })
      .select("*, users(full_name, email)")
      .single();

    if (error) throw error;

    // Notify user in-app
    await supabase.from("notifications").insert({
      user_id: target_user_id,
      title: "Certificate Issued 🏆",
      body: `You have been awarded: ${title}. View and download it from your dashboard.`,
      type: "success",
    });

    // Send email
    const recipient = cert.users as { full_name: string; email: string };
    if (recipient?.email) {
      await emailService.sendCertificateIssued({
        to: recipient.email,
        name: recipient.full_name,
        title,
        verificationCode: verification_code,
      }).catch(console.error);
    }

    return NextResponse.json<ApiResponse<typeof cert>>({ success: true, data: cert, message: "Certificate issued" });
  } catch (error) {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to issue certificate" }, { status: 500 });
  }
}
EOF

echo "✅ Certifications API updated with email"

# ============================================
# STEP 7: WIRE EMAIL INTO ID API
# ============================================
cat > app/api/id/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
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
    const supabase = await createAdminClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });

    const { data: profile } = await supabase.from("users").select("role").eq("id", user.id).single();
    if (!profile || !["admin", "super_admin"].includes(profile.role)) {
      return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });
    }

    const { target_user_id } = await request.json();
    const id_number = generateIdNumber();
    const expires_at = new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString();

    const { data: newId, error } = await supabase
      .from("digital_ids")
      .insert({ user_id: target_user_id, id_number, qr_code_url: "", expires_at, status: "active" })
      .select("*, users(full_name, email)")
      .single();

    if (error) throw error;

    // In-app notification
    await supabase.from("notifications").insert({
      user_id: target_user_id,
      title: "Digital ID Issued 🪪",
      body: `Your Nifelux Digital ID (${id_number}) has been issued and is now active.`,
      type: "success",
    });

    // Email notification
    const recipient = newId.users as { full_name: string; email: string };
    if (recipient?.email) {
      await emailService.sendIdIssued({
        to: recipient.email,
        name: recipient.full_name,
        idNumber: id_number,
      }).catch(console.error);
    }

    return NextResponse.json<ApiResponse<typeof newId>>({ success: true, data: newId, message: "ID issued" });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to issue ID" }, { status: 500 });
  }
}
EOF

echo "✅ ID API updated with email"

# ============================================
# STEP 8: SUPPORT PAGE — FULLY WIRED
# ============================================
echo "💚 Writing wired support/contribution page..."

cat > "app/(public)/support/page.tsx" << 'EOF'
"use client";
import { useState } from "react";
import { motion } from "framer-motion";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Heart, Zap, Globe, Cpu, Bot, BrainCircuit, ArrowRight, CheckCircle } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import SectionHeading from "@/components/common/SectionHeading";
import AnimatedSection from "@/components/common/AnimatedSection";
import { toast } from "sonner";

const schema = z.object({
  amount: z.number({ invalid_type_error: "Enter a valid amount" }).min(100, "Minimum is ₦100"),
  email: z.string().email("Enter a valid email"),
  name: z.string().optional(),
  message: z.string().max(200).optional(),
  anonymous: z.boolean().default(false),
});
type Form = z.infer<typeof schema>;

const presets = [500, 1000, 2500, 5000, 10000, 25000];

const impactItems = [
  { icon: BrainCircuit, label: "AI Research", desc: "Fund AI model training and research infrastructure." },
  { icon: Bot, label: "Robotics Hardware", desc: "Source components for robotic prototype development." },
  { icon: Globe, label: "Platform Growth", desc: "Scale the Nifelux platform to serve more of Africa." },
  { icon: Cpu, label: "Engineering Tools", desc: "Equip our engineers with the best tools available." },
];

export default function SupportPage() {
  const [selectedPreset, setSelectedPreset] = useState<number | null>(null);
  const [customAmount, setCustomAmount] = useState("");
  const [submitted, setSubmitted] = useState(false);

  const { register, handleSubmit, setValue, formState: { errors, isSubmitting } } = useForm<Form>({
    resolver: zodResolver(schema),
    defaultValues: { anonymous: false },
  });

  const selectPreset = (amount: number) => {
    setSelectedPreset(amount);
    setCustomAmount("");
    setValue("amount", amount);
  };

  const onSubmit = async (data: Form) => {
    try {
      const res = await fetch("/api/payments", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          amount: data.amount,
          email: data.email,
          purpose: "contribution",
          anonymous: data.anonymous,
          message: data.message ?? "",
        }),
      });

      const json = await res.json();
      if (!json.success) throw new Error(json.error);

      // Redirect to iPayNG payment page
      window.location.href = json.data.payment_url;
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : "Payment failed. Please try again.");
    }
  };

  return (
    <>
      <section className="relative min-h-[55vh] flex items-center overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark"><div className="absolute inset-0 bg-hero-gradient" /><div className="absolute inset-0 dot-pattern opacity-25" /></div>
        <div className="absolute top-1/3 left-1/4 w-72 h-72 orb orb-green opacity-20 animate-float" />
        <div className="container-custom relative z-10 py-24">
          <div className="max-w-3xl">
            <motion.span initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} className="badge-green inline-flex mb-6">
              <span className="w-1.5 h-1.5 rounded-full bg-brand-green animate-pulse" />Support Our Mission
            </motion.span>
            <motion.h1 initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
              className="font-display text-4xl md:text-6xl text-white mb-6">
              Help Build<br /><span className="gradient-text-green">Africa&apos;s Future</span>
            </motion.h1>
            <motion.p initial={{ opacity: 0, y: 24 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}
              className="text-text-secondary text-lg leading-relaxed max-w-2xl">
              Every contribution goes directly into building AI systems, robotics platforms, and digital
              infrastructure that will define Africa&apos;s technology future.
            </motion.p>
          </div>
        </div>
      </section>

      <section className="section-padding relative">
        <div className="absolute inset-0 bg-brand-dark-secondary" /><div className="absolute inset-0 grid-pattern opacity-15" />
        <div className="container-custom relative z-10">
          <div className="grid grid-cols-1 lg:grid-cols-5 gap-10">

            {/* Left: Context */}
            <AnimatedSection direction="right" className="lg:col-span-2">
              <h2 className="font-display text-2xl font-bold text-white mb-4">Why Support Nifelux?</h2>
              <p className="text-text-secondary text-sm leading-relaxed mb-7">
                We are a bootstrapped Nigerian technology company with a big vision. Your support
                directly fuels research, hardware, and the engineers building these systems.
              </p>
              <div className="space-y-4 mb-8">
                {impactItems.map(({ icon: I, label, desc }) => (
                  <div key={label} className="flex items-start gap-3">
                    <div className="w-9 h-9 rounded-lg bg-brand-green/10 flex items-center justify-center flex-shrink-0 mt-0.5">
                      <I className="w-4 h-4 text-brand-green" />
                    </div>
                    <div><div className="text-sm font-semibold text-white mb-0.5">{label}</div><div className="text-xs text-text-muted leading-relaxed">{desc}</div></div>
                  </div>
                ))}
              </div>
              <GlassCard className="p-5 border border-brand-green/20 bg-brand-green/5">
                <p className="text-text-muted text-xs leading-relaxed">
                  Payments are processed securely via <span className="text-brand-green font-semibold">iPayNG</span>.
                  Nigerian cards, bank transfers, and USSD are supported.
                </p>
              </GlassCard>
            </AnimatedSection>

            {/* Right: Form */}
            <AnimatedSection direction="left" delay={0.1} className="lg:col-span-3">
              <GlassCard variant="gradient" className="p-8 border border-white/[0.06]">
                <div className="flex items-center gap-3 mb-6">
                  <div className="w-10 h-10 rounded-xl bg-brand-green/10 flex items-center justify-center"><Heart className="w-5 h-5 text-brand-green" /></div>
                  <div>
                    <h3 className="font-display text-lg font-bold text-white">Make a Contribution</h3>
                    <p className="text-xs text-text-muted">Secure payment via iPayNG</p>
                  </div>
                </div>

                <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
                  {/* Preset amounts */}
                  <div>
                    <label className="block text-xs font-semibold text-text-secondary mb-3 uppercase tracking-wider">Choose Amount (₦)</label>
                    <div className="grid grid-cols-3 gap-2.5 mb-3">
                      {presets.map((p) => (
                        <button key={p} type="button" onClick={() => selectPreset(p)}
                          className={`py-2.5 px-3 text-sm font-semibold rounded-xl border transition-all duration-200 ${selectedPreset === p ? "border-brand-green/60 bg-brand-green/10 text-brand-green" : "border-white/10 text-text-secondary hover:border-brand-green/40 hover:text-white"}`}>
                          ₦{p.toLocaleString()}
                        </button>
                      ))}
                    </div>
                    <input
                      type="number"
                      placeholder="Or enter custom amount"
                      value={customAmount}
                      onChange={(e) => { setCustomAmount(e.target.value); setSelectedPreset(null); setValue("amount", Number(e.target.value)); }}
                      className="input-brand"
                      min={100}
                    />
                    {errors.amount && <p className="mt-1.5 text-xs text-red-400">{errors.amount.message}</p>}
                  </div>

                  {/* Email */}
                  <div>
                    <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Email Address <span className="text-red-400">*</span></label>
                    <input {...register("email")} type="email" placeholder="you@email.com" className="input-brand" />
                    {errors.email && <p className="mt-1.5 text-xs text-red-400">{errors.email.message}</p>}
                  </div>

                  {/* Name */}
                  <div>
                    <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Your Name (Optional)</label>
                    <input {...register("name")} placeholder="Your name" className="input-brand" />
                  </div>

                  {/* Message */}
                  <div>
                    <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Message (Optional)</label>
                    <textarea {...register("message")} rows={2} placeholder="Leave a message of support..." className="input-brand resize-none" />
                  </div>

                  {/* Anonymous */}
                  <label className="flex items-center gap-3 cursor-pointer group">
                    <input {...register("anonymous")} type="checkbox" className="w-4 h-4 rounded border-white/20 bg-transparent accent-brand-green" />
                    <span className="text-sm text-text-secondary group-hover:text-white transition-colors">Contribute anonymously</span>
                  </label>

                  <GradientButton type="submit" variant="green-blue" size="md" fullWidth loading={isSubmitting}
                    icon={<Zap className="w-4 h-4" />} iconPosition="left">
                    {isSubmitting ? "Redirecting to payment..." : "Contribute via iPayNG"}
                  </GradientButton>

                  <p className="text-center text-xs text-text-muted">
                    You will be redirected to a secure iPayNG payment page.
                  </p>
                </form>
              </GlassCard>
            </AnimatedSection>
          </div>
        </div>
      </section>

      <section className="py-20 relative overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[300px] orb orb-green opacity-15" />
        <div className="container-custom relative z-10 text-center">
          <AnimatedSection>
            <Heart className="w-12 h-12 text-brand-green mx-auto mb-5 animate-float" />
            <h2 className="font-display text-4xl text-white mb-4">Every Naira Counts</h2>
            <p className="text-text-secondary max-w-xl mx-auto text-sm leading-relaxed mb-7">
              Whether it&apos;s ₦500 or ₦500,000 — you are directly funding the systems
              that will power Africa&apos;s next technological era.
            </p>
            <GradientButton href="/about" variant="outline" size="md" icon={<ArrowRight className="w-4 h-4" />}>
              Learn More About Our Vision
            </GradientButton>
          </AnimatedSection>
        </div>
      </section>
    </>
  );
}
EOF

echo "✅ Support page wired to iPayNG"

# ============================================
# STEP 9: ADMIN PAYMENTS PAGE (FULL)
# ============================================
echo "💳 Writing admin payments page..."

cat > "app/(admin)/admin/payments/page.tsx" << 'EOF'
"use client";
import { useEffect, useState, useCallback } from "react";
import { DollarSign, RefreshCw, Search, TrendingUp } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import { formatDate } from "@/utils/format";

interface PaymentRecord {
  id: string;
  reference: string;
  amount: number;
  currency: string;
  status: string;
  purpose: string;
  paid_at: string | null;
  created_at: string;
  metadata: { email?: string; anonymous?: boolean } | null;
  users?: { full_name: string } | null;
}

const statusBadge: Record<string, string> = {
  success: "bg-brand-green/10 text-brand-green",
  pending: "bg-yellow-500/10 text-yellow-400",
  failed: "bg-red-500/10 text-red-400",
  refunded: "bg-brand-blue/10 text-brand-blue-light",
};

export default function AdminPaymentsPage() {
  const [payments, setPayments] = useState<PaymentRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  const fetchPayments = useCallback(async () => {
    setLoading(true);
    const s = createClient();
    const { data } = await s
      .from("payments")
      .select("*, users(full_name)")
      .order("created_at", { ascending: false });
    setPayments((data ?? []) as PaymentRecord[]);
    setLoading(false);
  }, []);

  useEffect(() => { fetchPayments(); }, [fetchPayments]);

  const totalSuccess = payments.filter((p) => p.status === "success").reduce((a, p) => a + Number(p.amount), 0);
  const totalCount = payments.filter((p) => p.status === "success").length;
  const pending = payments.filter((p) => p.status === "pending").length;

  const filtered = payments.filter((p) =>
    p.reference.toLowerCase().includes(search.toLowerCase()) ||
    p.purpose.toLowerCase().includes(search.toLowerCase()) ||
    p.users?.full_name?.toLowerCase().includes(search.toLowerCase()) ||
    (p.metadata?.email ?? "").toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div>
        <h2 className="font-display text-2xl font-bold text-white mb-1">Payments</h2>
        <p className="text-text-muted text-sm">All transactions across the platform.</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        {[
          { label: "Total Revenue", value: `₦${totalSuccess.toLocaleString()}`, icon: DollarSign, color: "green" },
          { label: "Successful Payments", value: totalCount.toString(), icon: TrendingUp, color: "blue" },
          { label: "Pending", value: pending.toString(), icon: RefreshCw, color: "purple" },
        ].map(({ label, value, icon: I, color }) => (
          <GlassCard key={label} className={`p-5 border ${color === "green" ? "border-brand-green/20" : color === "blue" ? "border-brand-blue/20" : "border-brand-purple/20"}`}>
            <div className={`w-9 h-9 rounded-xl flex items-center justify-center mb-3 ${color === "green" ? "bg-brand-green/10 text-brand-green" : color === "blue" ? "bg-brand-blue/10 text-brand-blue-light" : "bg-brand-purple/10 text-brand-purple-light"}`}>
              <I className="w-4 h-4" />
            </div>
            <div className="font-display text-xl font-bold text-white mb-1">{value}</div>
            <div className="text-xs text-text-muted">{label}</div>
          </GlassCard>
        ))}
      </div>

      {/* Table */}
      <GlassCard className="border border-white/[0.05] overflow-hidden">
        <div className="p-4 border-b border-white/[0.06] flex items-center justify-between gap-4">
          <div className="relative flex-1 max-w-sm">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-text-muted" />
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="Search payments..." className="input-brand pl-9" />
          </div>
          <button onClick={fetchPayments} className="w-9 h-9 glass rounded-lg flex items-center justify-center text-text-muted hover:text-white transition-colors">
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>

        {loading ? (
          <div className="p-12 text-center text-text-muted text-sm">Loading payments...</div>
        ) : filtered.length === 0 ? (
          <div className="p-12 text-center text-text-muted text-sm">No payments found.</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/[0.06]">
                  {["Reference", "User / Email", "Amount", "Purpose", "Status", "Date"].map((h) => (
                    <th key={h} className="text-left px-5 py-3.5 text-xs font-semibold text-text-muted uppercase tracking-wider">{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((p) => (
                  <tr key={p.id} className="border-b border-white/[0.04] hover:bg-white/[0.02] transition-colors">
                    <td className="px-5 py-4"><span className="font-mono text-xs text-white">{p.reference}</span></td>
                    <td className="px-5 py-4">
                      <div className="text-sm font-medium text-white">{p.users?.full_name ?? (p.metadata?.anonymous ? "Anonymous" : "Guest")}</div>
                      <div className="text-xs text-text-muted">{p.metadata?.email ?? "—"}</div>
                    </td>
                    <td className="px-5 py-4"><span className={`text-sm font-bold ${p.status === "success" ? "text-brand-green" : "text-white"}`}>₦{Number(p.amount).toLocaleString()}</span></td>
                    <td className="px-5 py-4"><span className="text-xs text-text-secondary capitalize">{p.purpose}</span></td>
                    <td className="px-5 py-4"><span className={`text-xs px-2.5 py-1 rounded-full font-semibold capitalize ${statusBadge[p.status] ?? "bg-white/[0.05] text-text-muted"}`}>{p.status}</span></td>
                    <td className="px-5 py-4"><span className="text-xs text-text-muted">{formatDate(p.paid_at ?? p.created_at)}</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </GlassCard>
    </div>
  );
}
EOF

echo "✅ Admin payments page written"

# ============================================
# STEP 10: ADMIN ANALYTICS (FULL)
# ============================================
echo "📊 Writing admin analytics page..."

cat > "app/(admin)/admin/analytics/page.tsx" << 'EOF'
"use client";
import { useEffect, useState, useCallback } from "react";
import { Users, CreditCard, Award, DollarSign, TrendingUp, RefreshCw } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import GlassCard from "@/components/common/GlassCard";
import { StaggerContainer, StaggerItem } from "@/components/common/AnimatedSection";

interface Stats {
  totalUsers: number;
  activeIds: number;
  totalCerts: number;
  totalRevenue: number;
  newUsersThisWeek: number;
  successfulPayments: number;
}

export default function AdminAnalyticsPage() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);

  const fetchStats = useCallback(async () => {
    setLoading(true);
    const s = createClient();

    const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();

    const [users, ids, certs, payments, newUsers, successPay] = await Promise.all([
      s.from("users").select("*", { count: "exact", head: true }),
      s.from("digital_ids").select("*", { count: "exact", head: true }).eq("status", "active"),
      s.from("certifications").select("*", { count: "exact", head: true }),
      s.from("payments").select("amount").eq("status", "success"),
      s.from("users").select("*", { count: "exact", head: true }).gte("created_at", weekAgo),
      s.from("payments").select("*", { count: "exact", head: true }).eq("status", "success"),
    ]);

    const totalRevenue = (payments.data ?? []).reduce((a, p) => a + Number(p.amount), 0);

    setStats({
      totalUsers: users.count ?? 0,
      activeIds: ids.count ?? 0,
      totalCerts: certs.count ?? 0,
      totalRevenue,
      newUsersThisWeek: newUsers.count ?? 0,
      successfulPayments: successPay.count ?? 0,
    });
    setLoading(false);
  }, []);

  useEffect(() => { fetchStats(); }, [fetchStats]);

  const kpis = stats ? [
    { label: "Total Users", value: stats.totalUsers.toLocaleString(), icon: Users, color: "blue", sub: `+${stats.newUsersThisWeek} this week` },
    { label: "Active Digital IDs", value: stats.activeIds.toLocaleString(), icon: CreditCard, color: "purple", sub: "Currently active" },
    { label: "Certificates Issued", value: stats.totalCerts.toLocaleString(), icon: Award, color: "green", sub: "All time" },
    { label: "Total Revenue", value: `₦${stats.totalRevenue.toLocaleString()}`, icon: DollarSign, color: "green", sub: `${stats.successfulPayments} transactions` },
  ] : [];

  return (
    <div className="max-w-6xl mx-auto space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="font-display text-2xl font-bold text-white mb-1">Analytics</h2>
          <p className="text-text-muted text-sm">Platform performance overview.</p>
        </div>
        <button onClick={fetchStats} className="w-9 h-9 glass rounded-lg flex items-center justify-center text-text-muted hover:text-white transition-colors">
          <RefreshCw className={`w-4 h-4 ${loading ? "animate-spin" : ""}`} />
        </button>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {[...Array(4)].map((_, i) => (
            <div key={i} className="glass-card p-5 h-32 animate-pulse" />
          ))}
        </div>
      ) : (
        <StaggerContainer className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {kpis.map(({ label, value, icon: I, color, sub }) => (
            <StaggerItem key={label}>
              <GlassCard className={`p-5 border ${color === "blue" ? "border-brand-blue/20" : color === "green" ? "border-brand-green/20" : "border-brand-purple/20"}`}>
                <div className="flex items-center justify-between mb-4">
                  <div className={`w-9 h-9 rounded-xl flex items-center justify-center ${color === "blue" ? "bg-brand-blue/10 text-brand-blue-light" : color === "green" ? "bg-brand-green/10 text-brand-green" : "bg-brand-purple/10 text-brand-purple-light"}`}>
                    <I className="w-4 h-4" />
                  </div>
                  <TrendingUp className="w-4 h-4 text-text-muted" />
                </div>
                <div className="font-display text-2xl font-bold text-white mb-1">{value}</div>
                <div className="text-xs text-text-muted">{label}</div>
                <div className="text-xs text-brand-green mt-1">{sub}</div>
              </GlassCard>
            </StaggerItem>
          ))}
        </StaggerContainer>
      )}

      {/* Breakdown */}
      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <GlassCard className="p-6 border border-white/[0.05]">
            <h3 className="font-display text-base font-bold text-white mb-5 flex items-center gap-2">
              <Users className="w-4 h-4 text-brand-blue-light" />Platform Summary
            </h3>
            <div className="space-y-4">
              {[
                { label: "Registered Users", value: stats.totalUsers, max: Math.max(stats.totalUsers, 1), color: "bg-brand-blue" },
                { label: "Active Digital IDs", value: stats.activeIds, max: Math.max(stats.totalUsers, 1), color: "bg-brand-purple" },
                { label: "Certificates Issued", value: stats.totalCerts, max: Math.max(stats.totalUsers, 1), color: "bg-brand-green" },
              ].map(({ label, value, max, color }) => (
                <div key={label}>
                  <div className="flex items-center justify-between mb-1.5">
                    <span className="text-xs text-text-secondary">{label}</span>
                    <span className="text-xs font-semibold text-white">{value}</span>
                  </div>
                  <div className="h-1.5 bg-white/[0.06] rounded-full overflow-hidden">
                    <div className={`h-full ${color} rounded-full transition-all duration-700`} style={{ width: `${Math.min((value / max) * 100, 100)}%` }} />
                  </div>
                </div>
              ))}
            </div>
          </GlassCard>

          <GlassCard className="p-6 border border-white/[0.05]">
            <h3 className="font-display text-base font-bold text-white mb-5 flex items-center gap-2">
              <DollarSign className="w-4 h-4 text-brand-green" />Revenue Summary
            </h3>
            <div className="space-y-4">
              {[
                { label: "Total Revenue", value: `₦${stats.totalRevenue.toLocaleString()}` },
                { label: "Successful Transactions", value: stats.successfulPayments.toString() },
                { label: "Average Transaction", value: stats.successfulPayments > 0 ? `₦${Math.round(stats.totalRevenue / stats.successfulPayments).toLocaleString()}` : "—" },
              ].map(({ label, value }) => (
                <div key={label} className="flex items-center justify-between py-3 border-b border-white/[0.04] last:border-0">
                  <span className="text-sm text-text-muted">{label}</span>
                  <span className="text-sm font-bold text-white">{value}</span>
                </div>
              ))}
            </div>
          </GlassCard>
        </div>
      )}
    </div>
  );
}
EOF

echo "✅ Admin analytics page written"

# ============================================
# STEP 11: UPDATE DB MIGRATION — ADD CONTRIBUTIONS TABLE
# ============================================
echo "🗄️  Updating database migration..."

cat > supabase/migrations/002_contributions.sql << 'EOF'
-- Support contributions table
CREATE TABLE IF NOT EXISTS public.support_contributions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  payment_id UUID REFERENCES public.payments(id) ON DELETE SET NULL,
  amount NUMERIC NOT NULL,
  message TEXT,
  anonymous BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contributions_user ON public.support_contributions(user_id);
CREATE INDEX IF NOT EXISTS idx_contributions_payment ON public.support_contributions(payment_id);

ALTER TABLE public.support_contributions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_view_contributions" ON public.support_contributions
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

CREATE POLICY "public_create_contribution" ON public.support_contributions
  FOR INSERT WITH CHECK (TRUE);
EOF

echo "✅ Migration 002 written"

# ============================================
# DONE
# ============================================
echo ""
echo "=================================================="
echo "✅ NIFELUX PHASE 3 — COMPLETE"
echo "=================================================="
echo ""
echo "📋 What was added in Phase 3:"
echo "   ✓ lib/ipayng/client.ts — Full iPayNG payment client"
echo "   ✓ lib/email/service.ts — Resend email (receipt, welcome, cert, ID)"
echo "   ✓ app/api/payments/route.ts — Real iPayNG integration"
echo "   ✓ app/api/webhooks/route.ts — Full webhook with HMAC verify"
echo "   ✓ app/api/certifications/route.ts — Auto-sends email on issue"
echo "   ✓ app/api/id/route.ts — Auto-sends email on issue"
echo "   ✓ app/payment/callback/page.tsx — Payment success/fail page"
echo "   ✓ app/(public)/support/page.tsx — Fully wired to iPayNG"
echo "   ✓ app/(admin)/admin/payments/page.tsx — Full payment table + stats"
echo "   ✓ app/(admin)/admin/analytics/page.tsx — Live platform analytics"
echo "   ✓ supabase/migrations/002_contributions.sql — Contributions table"
echo ""
echo "📋 Action Items:"
echo "   1. Fill .env.local with real keys:"
echo "      IPAYNG_SECRET_KEY=..."
echo "      IPAYNG_PUBLIC_KEY=..."
echo "      IPAYNG_WEBHOOK_SECRET=..."
echo "      RESEND_API_KEY=..."
echo "   2. Run: npx supabase db push"
echo "   3. In iPayNG dashboard, set webhook URL to:"
echo "      https://yourdomain.com/api/webhooks"
echo "   4. Run: npm run dev"
echo ""
echo "   Phase 4 → SEO, performance optimization, Vercel deployment"
echo ""
echo "🌍 Built for Nifelux Technologies — Lagos, Nigeria"
