#!/bin/bash

# ============================================
# NIFELUX — MASTER TYPE FIX
# Fixes every TypeScript error in one run
# Root cause: Supabase query builder can't
# infer types without explicit casts when
# using the SSR client + custom Database type
# ============================================

echo "🔧 Applying master TypeScript fixes..."
echo ""

# ============================================
# FIX 1: SERVER AUTH HELPER
# Centralises the admin check so we only
# need the type cast in ONE place
# ============================================
echo "1/9  Writing server-auth helper..."

cat > utils/server-auth.ts << 'EOF'
import { createAdminClient } from "@/lib/supabase/server";
import type { SupabaseClient } from "@supabase/supabase-js";

interface AdminCheckResult {
  supabase: SupabaseClient;
  userId: string | null;
  isAdmin: boolean;
}

/** Use inside API routes to verify admin role server-side */
export async function requireAdmin(): Promise<AdminCheckResult> {
  const supabase = await createAdminClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { supabase, userId: null, isAdmin: false };

  const { data } = await supabase
    .from("users")
    .select("role")
    .eq("id", user.id)
    .single();

  const profile = data as { role: string } | null;
  const isAdmin = !!profile && ["admin", "super_admin"].includes(profile.role);
  return { supabase, userId: user.id, isAdmin };
}

/** Use to get current user without admin check */
export async function getCurrentUser() {
  const supabase = await createAdminClient();
  const { data: { user } } = await supabase.auth.getUser();
  return { supabase, user };
}
EOF

echo "   ✅ server-auth helper written"

# ============================================
# FIX 2: API/CERTIFICATIONS ROUTE
# ============================================
echo "2/9  Fixing certifications API route..."

cat > app/api/certifications/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/utils/server-auth";
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
    const { supabase, userId, isAdmin } = await requireAdmin();
    if (!userId) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });
    if (!isAdmin) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });

    const body = await request.json();
    const { target_user_id, title, description, issued_by, expires_at } = body;
    const verification_code = generateVerificationCode();

    const { data: cert, error } = await supabase
      .from("certifications")
      .insert({
        user_id: target_user_id as string,
        title: title as string,
        description: (description ?? null) as string | null,
        issued_by: issued_by as string,
        verification_code,
        expires_at: (expires_at ?? null) as string | null,
        status: "active",
        issued_at: new Date().toISOString(),
      })
      .select("*, users(full_name, email)")
      .single();

    if (error) throw error;

    await supabase.from("notifications").insert({
      user_id: target_user_id as string,
      title: "Certificate Issued 🏆",
      body: `You have been awarded: ${title as string}`,
      type: "success",
    });

    const recipient = cert.users as { full_name: string; email: string } | null;
    if (recipient?.email) {
      await emailService.sendCertificateIssued({ to: recipient.email, name: recipient.full_name, title: title as string, verificationCode: verification_code }).catch(console.error);
    }

    return NextResponse.json<ApiResponse<typeof cert>>({ success: true, data: cert, message: "Certificate issued" });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to issue certificate" }, { status: 500 });
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const { supabase, userId, isAdmin } = await requireAdmin();
    if (!userId) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });
    if (!isAdmin) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });

    const { id, status } = await request.json();
    const { error } = await supabase.from("certifications").update({ status: status as "active" | "expired" | "revoked" }).eq("id", id as string);
    if (error) throw error;
    return NextResponse.json<ApiResponse<null>>({ success: true, data: null, message: "Updated" });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to update" }, { status: 500 });
  }
}
EOF

echo "   ✅ certifications route fixed"

# ============================================
# FIX 3: API/ID ROUTE
# ============================================
echo "3/9  Fixing ID API route..."

cat > app/api/id/route.ts << 'EOF'
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
EOF

echo "   ✅ ID route fixed"

# ============================================
# FIX 4: API/PAYMENTS ROUTE
# ============================================
echo "4/9  Fixing payments API route..."

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
      const firstError = parsed.error.errors[0]?.message ?? "Validation failed";
      return NextResponse.json<ApiResponse<null>>({ success: false, error: firstError }, { status: 400 });
    }

    const { amount, email, purpose, user_id, anonymous, message } = parsed.data;
    const supabase = await createAdminClient();
    const reference = `NF-${Date.now()}-${Math.random().toString(36).substring(2, 8).toUpperCase()}`;

    const { data: payment, error: paymentError } = await supabase
      .from("payments")
      .insert({
        reference,
        amount,
        currency: "NGN",
        status: "pending",
        purpose,
        user_id: user_id ?? null,
        metadata: { email, anonymous: anonymous ?? false, message: message ?? "" } as Record<string, unknown>,
      })
      .select()
      .single();

    if (paymentError) throw paymentError;

    const callbackUrl = `${process.env.NEXT_PUBLIC_APP_URL}/payment/callback?reference=${reference}`;
    const ipayng = await ipayngClient.initiatePayment({
      email, amount: amount * 100, reference, callback_url: callbackUrl,
      metadata: { purpose, user_id, anonymous },
    });

    return NextResponse.json<ApiResponse<{ payment_url: string; reference: string }>>({
      success: true, data: { payment_url: ipayng.data.authorization_url, reference },
    });
  } catch (error) {
    console.error("Payment error:", error);
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Payment initiation failed" }, { status: 500 });
  }
}

export async function GET(request: NextRequest) {
  const reference = new URL(request.url).searchParams.get("reference");
  if (!reference) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Reference required" }, { status: 400 });
  const supabase = await createAdminClient();
  const { data, error } = await supabase.from("payments").select("*").eq("reference", reference).single();
  if (error) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Not found" }, { status: 404 });
  return NextResponse.json<ApiResponse<typeof data>>({ success: true, data });
}
EOF

echo "   ✅ payments route fixed"

# ============================================
# FIX 5: API/WEBHOOKS ROUTE
# ============================================
echo "5/9  Fixing webhooks route..."

cat > app/api/webhooks/route.ts << 'EOF'
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
EOF

echo "   ✅ webhooks route fixed"

# ============================================
# FIX 6: API/NOTIFICATIONS, QR, USERS, AUTH
# ============================================
echo "6/9  Fixing remaining API routes..."

cat > app/api/notifications/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/utils/server-auth";
import type { ApiResponse } from "@/types/api.types";

export async function POST(request: NextRequest) {
  try {
    const { supabase, userId, isAdmin } = await requireAdmin();
    if (!userId) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });
    if (!isAdmin) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });

    const { user_ids, title, body, type = "info" } = await request.json();
    if (!title || !body) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Missing title or body" }, { status: 400 });

    const rows = (user_ids as string[]).map((uid) => ({
      user_id: uid, title: title as string, body: body as string,
      type: (type as "info" | "success" | "warning" | "alert"),
    }));
    const { error } = await supabase.from("notifications").insert(rows);
    if (error) throw error;
    return NextResponse.json<ApiResponse<{ sent: number }>>({ success: true, data: { sent: rows.length } });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to send" }, { status: 500 });
  }
}
EOF

cat > app/api/qr/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/utils/server-auth";
import type { ApiResponse } from "@/types/api.types";

export async function POST(request: NextRequest) {
  try {
    const { supabase, userId, isAdmin } = await requireAdmin();
    if (!userId) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });
    if (!isAdmin) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });

    const { type, token } = await request.json();
    if (!token) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Token required" }, { status: 400 });

    const url = `${process.env.NEXT_PUBLIC_APP_URL}/verify/${token as string}`;

    if (type === "id") {
      await supabase.from("digital_ids").update({ qr_code_url: url }).eq("id_number", token as string);
    }

    return NextResponse.json<ApiResponse<{ verify_url: string }>>({ success: true, data: { verify_url: url } });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "QR generation failed" }, { status: 500 });
  }
}
EOF

cat > app/api/auth/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { getCurrentUser } from "@/utils/server-auth";
import type { ApiResponse } from "@/types/api.types";

export async function GET(_request: NextRequest) {
  try {
    const { supabase, user } = await getCurrentUser();
    if (!user) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Not authenticated" }, { status: 401 });
    const { data: profile } = await supabase.from("users").select("*").eq("id", user.id).single();
    return NextResponse.json<ApiResponse<typeof profile>>({ success: true, data: profile });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Server error" }, { status: 500 });
  }
}
EOF

cat > app/api/users/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { requireAdmin } from "@/utils/server-auth";
import type { ApiResponse } from "@/types/api.types";

export async function GET(_request: NextRequest) {
  try {
    const { supabase, userId, isAdmin } = await requireAdmin();
    if (!userId) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });
    if (!isAdmin) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });
    const { data, error } = await supabase.from("users").select("*").order("created_at", { ascending: false });
    if (error) throw error;
    return NextResponse.json<ApiResponse<typeof data>>({ success: true, data });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to fetch users" }, { status: 500 });
  }
}
EOF

echo "   ✅ notifications, qr, users, auth routes fixed"

# ============================================
# FIX 7: ADMIN PAGES — update() type casts
# ============================================
echo "7/9  Fixing admin page update calls..."

# Patch certifications page revoke function
sed -i "s/s\.from(\"certifications\")\.update({ status: \"revoked\" })/s.from(\"certifications\").update({ status: \"revoked\" as \"active\" | \"expired\" | \"revoked\" })/g" "app/(admin)/admin/certifications/page.tsx" 2>/dev/null || true

# Patch id-management page revoke function
sed -i "s/s\.from(\"digital_ids\")\.update({ status: \"revoked\" })/s.from(\"digital_ids\").update({ status: \"revoked\" as \"active\" | \"expired\" | \"revoked\" })/g" "app/(admin)/admin/id-management/page.tsx" 2>/dev/null || true

# Patch users page status toggle
sed -i "s/await s\.from(\"users\")\.update({ status: newStatus })/await s.from(\"users\").update({ status: newStatus as \"active\" | \"suspended\" | \"pending\" })/g" "app/(admin)/admin/users/page.tsx" 2>/dev/null || true

# Patch users page role update
sed -i "s/await s\.from(\"users\")\.update({ role })/await s.from(\"users\").update({ role: role as \"user\" | \"staff\" | \"admin\" | \"super_admin\" })/g" "app/(admin)/admin/users/page.tsx" 2>/dev/null || true

# Patch roles page
sed -i "s/await s\.from(\"users\")\.update({ role })/await s.from(\"users\").update({ role: role as \"user\" | \"staff\" | \"admin\" | \"super_admin\" })/g" "app/(admin)/admin/roles/page.tsx" 2>/dev/null || true

echo "   ✅ Admin page type casts applied"

# ============================================
# FIX 8: SUPPORT PAGE FORM TYPE
# ============================================
echo "8/9  Fixing support page form types..."

# The support page uses useForm twice (duplicate import) — fix it
sed -i '/^import { useForm as useFormLib/d' "app/(public)/support/page.tsx" 2>/dev/null || true

# Fix the form onSubmit handler type
sed -i 's/const onSubmit = async (data: Form) => {/const onSubmit = async (data: Form): Promise<void> => {/g' "app/(public)/support/page.tsx" 2>/dev/null || true

echo "   ✅ Support page fixed"

# ============================================
# FIX 9: FINAL EMPTY FILE SCAN + TYPE CHECK
# ============================================
echo "9/9  Scanning for empty files + running type check..."

find app components features lib services hooks store types utils -name "*.ts" -o -name "*.tsx" 2>/dev/null | while read f; do
  if [ -f "$f" ] && [ ! -s "$f" ]; then
    echo "   Fixing empty: $f"
    echo 'export {};' > "$f"
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Running full type check..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
npx tsc --noEmit 2>&1 | grep "error TS" | sort -u

TS_ERRORS=$(npx tsc --noEmit 2>&1 | grep -c "error TS" || true)

echo ""
if [ "$TS_ERRORS" -eq "0" ]; then
  echo "✅ ZERO TypeScript errors — run: npm run build"
else
  echo "⚠️  $TS_ERRORS error(s) remaining — see above"
  echo "   Run: npx tsc --noEmit 2>&1 | grep 'error TS'"
fi
echo ""
echo "🌍 Nifelux Technologies — Lagos, Nigeria"
