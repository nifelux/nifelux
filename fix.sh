#!/bin/bash

# Nifelux Final Fix & Premium Design Script (v3)
# This script resolves build errors and applies a premium theme.

set -e

# Repository check
if [ -d "nifelux_repo" ]; then
  cd nifelux_repo
elif [ ! -f "package.json" ]; then
  echo "Error: Please run this script from the root of the nifelux repository."
  exit 1
fi

echo "🚀 Starting Nifelux Restoration..."

# 1. Robust Tailwind v4 Configuration
# We'll use a standard Tailwind v4 setup that works with Next.js Turbopack
cat << 'EOF' > app/globals.css
@import "tailwindcss";

@theme {
  --font-display: "Syne", system-ui, sans-serif;
  --color-brand-blue: #007BFF;
  --color-brand-blue-light: #66B2FF;
  --color-brand-green: #28A745;
  --color-brand-green-light: #66BB6A;
  --color-brand-red: #DC3545;
  --color-brand-red-light: #FF6B6B;
  --color-brand-white: #FFFFFF;
  --color-bg-dark: #050816;
}

@layer base {
  body {
    background-color: #050816 !important;
    color: #ffffff;
    font-family: "Inter", sans-serif;
  }
}

@layer utilities {
  .gradient-text {
    background: linear-gradient(135deg, #007BFF 0%, #28A745 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .glass-card {
    background: rgba(17, 24, 39, 0.75);
    backdrop-filter: blur(20px);
    border: 1px solid rgba(255, 255, 255, 0.07);
    border-radius: 16px;
  }

  .btn-primary {
    background: linear-gradient(135deg, #007BFF 0%, #28A745 100%);
    @apply text-white font-semibold rounded-xl px-6 py-3 inline-flex items-center gap-2 transition-all hover:shadow-[0_0_30px_rgba(0,123,255,0.28)] hover:-translate-y-0.5;
  }

  .btn-secondary {
    @apply bg-white/[0.06] text-white font-semibold rounded-xl px-6 py-3 inline-flex items-center gap-2 border border-white/10 transition-all hover:bg-white/[0.1] hover:-translate-y-0.5;
  }

  .input-brand {
    @apply w-full px-4 py-3 rounded-xl bg-white/[0.04] border border-white/10 text-white transition-all focus:outline-none focus:ring-2 focus:ring-[#007BFF]/50 focus:border-[#007BFF];
  }
}
EOF

# 2. Fix Admin Layout (Super Admin Restriction)
cat << 'EOF' > app/\(admin\)/layout.tsx
"use client";
import { useEffect } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { LayoutDashboard, Users, CreditCard, Award, BarChart2, Activity, Shield, LogOut, Zap, Bell } from "lucide-react";
import { cn } from "@/utils/cn";
import { authService } from "@/services/auth.service";
import { useAuth } from "@/hooks/useAuth";
import { useUser } from "@/hooks/useUser";

const nav = [
  { icon: LayoutDashboard, label: "Overview",       href: "/admin/dashboard" },
  { icon: Users,           label: "Users",           href: "/admin/users" },
  { icon: CreditCard,      label: "ID Management",   href: "/admin/id-management" },
  { icon: Award,           label: "Certifications",  href: "/admin/certifications" },
  { icon: BarChart2,       label: "Payments",        href: "/admin/payments" },
  { icon: BarChart2,       label: "Analytics",       href: "/admin/analytics" },
  { icon: Bell,            label: "Notifications",   href: "/admin/notifications" },
  { icon: Activity,        label: "Activity Logs",   href: "/admin/activity-logs" },
  { icon: Shield,          label: "Roles",           href: "/admin/roles" },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const { user, isLoading } = useAuth();
  const { isSuperAdmin } = useUser();
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    if (!isLoading && !user) router.replace("/login");
  }, [user, isLoading, router]);

  if (isLoading) return <div className="min-h-screen bg-[#050816] flex items-center justify-center text-white">Loading Admin...</div>;
  if (!user) return null;

  if (!isSuperAdmin) {
    return (
      <div className="min-h-screen bg-[#050816] flex items-center justify-center p-4 text-center">
        <div className="glass-card p-8 max-w-sm w-full">
          <Shield className="w-12 h-12 text-[#DC3545] mx-auto mb-4" />
          <h2 className="text-xl font-bold mb-2">Access Denied</h2>
          <p className="text-text-muted mb-6">Super Admin privileges required.</p>
          <Link href="/dashboard" className="btn-primary w-full">Return to Dashboard</Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#050816] flex">
      <aside className="w-64 border-r border-white/5 bg-[#0B1120] hidden md:flex flex-col">
        <div className="p-6 border-b border-white/5">
          <Link href="/" className="flex items-center gap-2">
            <Zap className="w-6 h-6 text-[#007BFF]" />
            <span className="font-bold text-lg">Nifelux Admin</span>
          </Link>
        </div>
        <nav className="flex-1 p-4 space-y-1">
          {nav.map((item) => (
            <Link key={item.href} href={item.href} className={cn("flex items-center gap-3 px-4 py-2 rounded-lg text-sm transition-all", pathname.startsWith(item.href) ? "bg-[#007BFF]/10 text-[#007BFF] border border-[#007BFF]/20" : "text-text-muted hover:text-white hover:bg-white/5")}>
              <item.icon className="w-4 h-4" /> {item.label}
            </Link>
          ))}
        </nav>
        <div className="p-4 border-t border-white/5">
          <button onClick={() => authService.signOut().then(() => router.push("/"))} className="flex items-center gap-3 px-4 py-2 w-full text-sm text-text-muted hover:text-[#DC3545]">
            <LogOut className="w-4 h-4" /> Sign Out
          </button>
        </div>
      </aside>
      <main className="flex-1 flex flex-col min-w-0">
        <header className="h-16 border-b border-white/5 flex items-center justify-between px-8">
          <h1 className="font-bold">{nav.find(n => pathname.startsWith(n.href))?.label || "Admin"}</h1>
          <div className="badge-brand">Admin Panel</div>
        </header>
        <div className="p-8 overflow-auto">{children}</div>
      </main>
    </div>
  );
}
EOF

# 3. Secure Payment API
cat << 'EOF' > app/api/payments/route.ts
import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import { ipayngClient } from "@/lib/ipayng/client";
import { z } from "zod";

const schema = z.object({
  amount: z.number().min(100),
  email: z.string().email(),
  purpose: z.string(),
  user_id: z.string().optional(),
  anonymous: z.boolean().optional(),
  message: z.string().optional(),
});

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const parsed = schema.parse(body);
    const supabase = await createAdminClient();
    const reference = `NF-${Date.now()}-${Math.random().toString(36).slice(2, 8).toUpperCase()}`;

    await supabase.from("payments").insert({
      reference, amount: parsed.amount, status: "pending", purpose: parsed.purpose,
      user_id: parsed.user_id, metadata: { email: parsed.email, anonymous: parsed.anonymous, message: parsed.message }
    });

    const ipay = await ipayngClient.initiatePayment({
      email: parsed.email, amount: parsed.amount * 100, reference,
      callback_url: `${process.env.NEXT_PUBLIC_APP_URL}/payment/callback?reference=${reference}`
    });

    return NextResponse.json({ success: true, data: { payment_url: ipay.data.authorization_url, reference } });
  } catch (e) {
    return NextResponse.json({ success: false, error: "Payment failed" }, { status: 500 });
  }
}

export async function GET(req: NextRequest) {
  const reference = new URL(req.url).searchParams.get("reference");
  if (!reference) return NextResponse.json({ success: false, error: "Missing reference" }, { status: 400 });

  const supabase = await createAdminClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ success: false, error: "Unauthorized" }, { status: 401 });

  const { data, error } = await supabase.from("payments").select("*").eq("reference", reference).single();
  if (error) return NextResponse.json({ success: false, error: "Not found" }, { status: 404 });
  
  const { data: profile } = await supabase.from("users").select("role").eq("id", user.id).single();
  if (data.user_id !== user.id && profile?.role !== "super_admin") {
    return NextResponse.json({ success: false, error: "Forbidden" }, { status: 403 });
  }

  return NextResponse.json({ success: true, data });
}
EOF

# 4. Generate Valid Admin Pages (Fixed PascalCase)
PAGES=("users" "id-management" "payments" "analytics" "notifications" "activity-logs" "roles")

for page in "${PAGES[@]}"; do
  # Convert kebab-case to PascalCase
  # e.g., id-management -> IdManagement
  IFS='-' read -ra ADDR <<< "$page"
  PASCAL_NAME=""
  for i in "${ADDR[@]}"; do
    PASCAL_NAME="${PASCAL_NAME}${i^}"
  done
  
  DIR="app/(admin)/admin/$page"
  mkdir -p "$DIR"
  
  cat << EOF > "$DIR/page.tsx"
export default function Admin${PASCAL_NAME}Page() {
  return (
    <div className="glass-card p-8">
      <h2 className="text-2xl font-bold mb-4 capitalize">${page//-/ }</h2>
      <p className="text-text-muted">Module initialized successfully.</p>
    </div>
  );
}
EOF
done

# 5. Fix Registration Redirect
sed -i 's/router.push("\/login")/router.push("\/verify")/' app/\(auth\)/register/page.tsx

echo "✅ Fixes applied. Run 'npm run build' to verify."
