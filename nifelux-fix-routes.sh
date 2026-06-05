#!/bin/bash

# ============================================
# NIFELUX — FIX EMPTY API ROUTE FILES
# Same root cause as before: touch creates
# empty .ts files that fail TypeScript build
# ============================================

echo "🔧 Fixing empty API route files..."

# app/api/auth/route.ts
cat > app/api/auth/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import type { ApiResponse } from "@/types/api.types";

// GET /api/auth — returns current session user
export async function GET(_request: NextRequest) {
  try {
    const supabase = await createClient();
    const { data: { user }, error } = await supabase.auth.getUser();
    if (error || !user) {
      return NextResponse.json<ApiResponse<null>>({ success: false, error: "Not authenticated" }, { status: 401 });
    }
    const { data: profile } = await supabase.from("users").select("*").eq("id", user.id).single();
    return NextResponse.json<ApiResponse<typeof profile>>({ success: true, data: profile });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Server error" }, { status: 500 });
  }
}
EOF

# app/api/users/route.ts
cat > app/api/users/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import type { ApiResponse } from "@/types/api.types";

// GET /api/users — admin only, returns all users
export async function GET(_request: NextRequest) {
  try {
    const supabase = await createAdminClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });

    const { data: profile } = await supabase.from("users").select("role").eq("id", user.id).single();
    if (!profile || !["admin", "super_admin"].includes(profile.role)) {
      return NextResponse.json<ApiResponse<null>>({ success: false, error: "Forbidden" }, { status: 403 });
    }

    const { data, error } = await supabase.from("users").select("*").order("created_at", { ascending: false });
    if (error) throw error;
    return NextResponse.json<ApiResponse<typeof data>>({ success: true, data });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to fetch users" }, { status: 500 });
  }
}
EOF

# app/api/qr/route.ts — already written in Phase 2 but check it exists
if [ ! -s app/api/qr/route.ts ]; then
cat > app/api/qr/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import type { ApiResponse } from "@/types/api.types";

export async function POST(request: NextRequest) {
  try {
    const { token } = await request.json();
    if (!token) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Token required" }, { status: 400 });
    const url = `${process.env.NEXT_PUBLIC_APP_URL}/verify/${token}`;
    return NextResponse.json<ApiResponse<{ verify_url: string }>>({ success: true, data: { verify_url: url } });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "QR generation failed" }, { status: 500 });
  }
}
EOF
fi

# app/api/notifications/route.ts — ensure not empty
if [ ! -s app/api/notifications/route.ts ]; then
cat > app/api/notifications/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import type { ApiResponse } from "@/types/api.types";

export async function POST(request: NextRequest) {
  try {
    const supabase = await createAdminClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Unauthorized" }, { status: 401 });

    const { user_ids, title, body, type = "info" } = await request.json();
    if (!title || !body) return NextResponse.json<ApiResponse<null>>({ success: false, error: "Missing title or body" }, { status: 400 });

    const rows = (user_ids as string[]).map((uid: string) => ({ user_id: uid, title, body, type }));
    const { error } = await supabase.from("notifications").insert(rows);
    if (error) throw error;

    return NextResponse.json<ApiResponse<{ sent: number }>>({ success: true, data: { sent: rows.length } });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success: false, error: "Failed to send" }, { status: 500 });
  }
}
EOF
fi

# Scan and fix ALL other empty .ts/.tsx files that would fail build
echo ""
echo "🔍 Scanning for other empty files..."

find app -name "*.ts" -o -name "*.tsx" | while read file; do
  if [ ! -s "$file" ]; then
    echo "  Empty: $file — adding placeholder export"
    echo 'export {};' > "$file"
  fi
done

echo ""
echo "✅ All empty API routes fixed"
echo ""
echo "Now run: npm run build"
