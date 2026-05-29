#!/bin/bash

# ============================================
# NIFELUX TECHNOLOGIES — FULL PLATFORM SETUP
# Run from the ROOT of your Next.js project
# No src/ — all paths from root
# ============================================

echo ""
echo "🚀 Nifelux Technologies — Building Full Platform..."
echo "=================================================="

# ============================================
# STEP 1: CREATE ALL DIRECTORIES
# ============================================
echo "📁 Creating directories..."

mkdir -p app/\(public\)/about
mkdir -p app/\(public\)/services
mkdir -p app/\(public\)/robotics
mkdir -p app/\(public\)/projects
mkdir -p app/\(public\)/certifications
mkdir -p app/\(public\)/support
mkdir -p app/\(public\)/contact
mkdir -p app/\(auth\)/login
mkdir -p app/\(auth\)/register
mkdir -p app/\(auth\)/verify
mkdir -p app/\(dashboard\)/dashboard
mkdir -p app/\(dashboard\)/id-card
mkdir -p app/\(dashboard\)/certifications
mkdir -p app/\(admin\)/admin/dashboard
mkdir -p app/\(admin\)/admin/users
mkdir -p app/\(admin\)/admin/certifications
mkdir -p app/\(admin\)/admin/id-management
mkdir -p app/\(admin\)/admin/payments
mkdir -p app/\(admin\)/admin/analytics
mkdir -p app/\(admin\)/admin/roles
mkdir -p app/\(admin\)/admin/activity-logs
mkdir -p app/api/payments
mkdir -p app/api/id
mkdir -p app/api/certifications
mkdir -p app/api/webhooks
mkdir -p app/verify/\[token\]
mkdir -p components/layout
mkdir -p components/common
mkdir -p features/auth
mkdir -p features/digital-id
mkdir -p features/certifications
mkdir -p features/payments
mkdir -p features/admin
mkdir -p lib/supabase
mkdir -p lib/validations
mkdir -p services
mkdir -p hooks
mkdir -p store
mkdir -p types
mkdir -p utils
mkdir -p styles
mkdir -p public/og
mkdir -p public/icons
mkdir -p public/assets/images
mkdir -p public/assets/logos
mkdir -p supabase/migrations

echo "✅ Directories created"

# ============================================
# STEP 2: ENV & CONFIG
# ============================================
echo "⚙️  Writing config files..."

cat > .env.example << 'EOF'
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
IPAYNG_SECRET_KEY=your_ipayng_secret_key
IPAYNG_PUBLIC_KEY=your_ipayng_public_key
IPAYNG_WEBHOOK_SECRET=your_ipayng_webhook_secret
RESEND_API_KEY=your_resend_api_key
QR_JWT_SECRET=your_random_secret_min_32_chars
ADMIN_EMAIL=admin@nifelux.com
EOF

cat > next.config.ts << 'EOF'
import type { NextConfig } from "next";
const nextConfig: NextConfig = {
  images: {
    remotePatterns: [{ protocol: "https", hostname: "*.supabase.co", pathname: "/storage/v1/object/public/**" }],
  },
  async headers() {
    return [{
      source: "/(.*)",
      headers: [
        { key: "X-Frame-Options", value: "DENY" },
        { key: "X-Content-Type-Options", value: "nosniff" },
        { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
      ],
    }];
  },
};
export default nextConfig;
EOF

cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

cat > tailwind.config.ts << 'EOF'
import type { Config } from "tailwindcss";
const config: Config = {
  darkMode: ["class"],
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./features/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          blue: "#2563EB", "blue-light": "#3B82F6",
          purple: "#7C3AED", "purple-light": "#8B5CF6",
          green: "#22C55E", "green-light": "#4ADE80",
          dark: "#050816", "dark-secondary": "#0B1120",
          card: "#111827", border: "#1E293B",
        },
        text: { primary: "#FFFFFF", secondary: "#CBD5E1", muted: "#94A3B8", accent: "#64748B" },
      },
      backgroundImage: {
        "brand-gradient": "linear-gradient(135deg, #2563EB 0%, #7C3AED 100%)",
        "green-gradient": "linear-gradient(135deg, #22C55E 0%, #2563EB 100%)",
        "hero-gradient": "radial-gradient(ellipse at 50% 0%, rgba(37,99,235,0.15) 0%, rgba(124,58,237,0.08) 50%, transparent 70%)",
      },
      fontFamily: {
        sans: ["var(--font-geist-sans)", "system-ui", "sans-serif"],
        mono: ["var(--font-geist-mono)", "monospace"],
        display: ["var(--font-syne)", "system-ui", "sans-serif"],
      },
      animation: {
        "fade-up": "fadeUp 0.6s ease-out forwards",
        float: "float 6s ease-in-out infinite",
        "float-slow": "float 8s ease-in-out infinite",
        "pulse-slow": "pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite",
      },
      keyframes: {
        fadeUp: { "0%": { opacity: "0", transform: "translateY(24px)" }, "100%": { opacity: "1", transform: "translateY(0)" } },
        float: { "0%, 100%": { transform: "translateY(0px)" }, "50%": { transform: "translateY(-12px)" } },
      },
      boxShadow: {
        "glow-sm": "0 0 15px rgba(37,99,235,0.2)",
        glow: "0 0 30px rgba(37,99,235,0.25)",
        "glow-purple": "0 0 30px rgba(124,58,237,0.25)",
        "glow-green": "0 0 30px rgba(34,197,94,0.25)",
        card: "0 4px 6px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.05)",
        "card-hover": "0 20px 40px rgba(0,0,0,0.6), 0 0 0 1px rgba(37,99,235,0.2)",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
};
export default config;
EOF

cat > middleware.ts << 'EOF'
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { createServerClient } from "@supabase/ssr";

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  let response = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return request.cookies.getAll(); },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) => response.cookies.set(name, value, options));
        },
      },
    }
  );

  const { data: { user } } = await supabase.auth.getUser();

  const isProtected = pathname.startsWith("/dashboard") || pathname.startsWith("/id-card");
  const isAdmin = pathname.startsWith("/admin");
  const isAuth = pathname.startsWith("/login") || pathname.startsWith("/register");

  if ((isProtected || isAdmin) && !user) {
    return NextResponse.redirect(new URL("/login", request.url));
  }
  if (isAuth && user) {
    return NextResponse.redirect(new URL("/dashboard", request.url));
  }
  return response;
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico|icons|assets|og|fonts).*)"],
};
EOF

echo "✅ Config files written"

# ============================================
# STEP 3: GLOBAL STYLES
# ============================================
echo "🎨 Writing global styles..."

cat > styles/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@import url("https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&display=swap");

:root {
  --brand-blue: #2563eb; --brand-purple: #7c3aed; --brand-green: #22c55e;
  --bg-dark: #050816; --bg-dark-secondary: #0b1120; --bg-card: #111827;
  --text-secondary: #cbd5e1; --text-muted: #94a3b8; --border: #1e293b;
  --gradient-brand: linear-gradient(135deg, #2563eb 0%, #7c3aed 100%);
  --gradient-green: linear-gradient(135deg, #22c55e 0%, #2563eb 100%);
  --section-padding: clamp(4rem, 8vw, 8rem);
  --container-padding: clamp(1rem, 5vw, 2rem);
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; -webkit-font-smoothing: antialiased; }
body { background-color: var(--bg-dark); color: #fff; font-family: var(--font-geist-sans), system-ui, sans-serif; overflow-x: hidden; }
::-webkit-scrollbar { width: 6px; }
::-webkit-scrollbar-track { background: var(--bg-dark-secondary); }
::-webkit-scrollbar-thumb { background: #334155; border-radius: 100px; }
::-webkit-scrollbar-thumb:hover { background: var(--brand-blue); }
::selection { background: rgba(37,99,235,0.3); color: #fff; }
h1,h2,h3,h4,h5,h6 { font-family: var(--font-syne), "Syne", system-ui, sans-serif; font-weight: 700; line-height: 1.1; letter-spacing: -0.02em; }
.gradient-text { background: var(--gradient-brand); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
.gradient-text-green { background: var(--gradient-green); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
.glass { background: rgba(255,255,255,0.03); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.06); }
.glass-card { background: rgba(17,24,39,0.6); backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px); border: 1px solid rgba(255,255,255,0.06); border-radius: 16px; }
.grid-pattern { background-image: linear-gradient(rgba(255,255,255,0.02) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.02) 1px, transparent 1px); background-size: 60px 60px; }
.dot-pattern { background-image: radial-gradient(rgba(255,255,255,0.06) 1px, transparent 1px); background-size: 24px 24px; }
.orb { position: absolute; border-radius: 50%; filter: blur(80px); pointer-events: none; animation: float 8s ease-in-out infinite; }
.orb-blue { background: radial-gradient(circle, rgba(37,99,235,0.25), transparent); }
.orb-purple { background: radial-gradient(circle, rgba(124,58,237,0.25), transparent); }
.orb-green { background: radial-gradient(circle, rgba(34,197,94,0.2), transparent); }
.btn-primary { display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 12px 24px; background: var(--gradient-brand); color: white; font-weight: 600; font-size: 0.9375rem; border-radius: 10px; border: none; cursor: pointer; transition: all 0.3s ease; }
.btn-primary:hover { transform: translateY(-1px); box-shadow: 0 8px 25px rgba(37,99,235,0.4); }
.btn-secondary { display: inline-flex; align-items: center; justify-content: center; gap: 8px; padding: 11px 23px; background: transparent; color: white; font-weight: 600; font-size: 0.9375rem; border-radius: 10px; border: 1px solid rgba(255,255,255,0.12); cursor: pointer; transition: all 0.3s ease; }
.btn-secondary:hover { background: rgba(255,255,255,0.05); }
.container-custom { width: 100%; max-width: 1200px; margin: 0 auto; padding: 0 var(--container-padding); }
.section-padding { padding-top: var(--section-padding); padding-bottom: var(--section-padding); }
.section-divider { width: 100%; height: 1px; background: linear-gradient(90deg, transparent, rgba(255,255,255,0.06), transparent); }
.badge-brand { display: inline-flex; align-items: center; gap: 6px; padding: 4px 12px; background: rgba(37,99,235,0.12); border: 1px solid rgba(37,99,235,0.25); border-radius: 100px; font-size: 0.75rem; font-weight: 600; color: #3B82F6; letter-spacing: 0.05em; text-transform: uppercase; }
.badge-green { background: rgba(34,197,94,0.12); border-color: rgba(34,197,94,0.25); color: #4ADE80; }
.badge-purple { background: rgba(124,58,237,0.12); border-color: rgba(124,58,237,0.25); color: #8B5CF6; }
.input-brand { width: 100%; padding: 12px 16px; background: rgba(255,255,255,0.03); border: 1px solid #1e293b; border-radius: 10px; color: #fff; font-size: 0.9375rem; transition: all 0.2s; outline: none; }
.input-brand::placeholder { color: #64748b; }
.input-brand:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37,99,235,0.15); }
.gradient-border { position: relative; background: var(--bg-card); border-radius: 16px; }
.gradient-border::before { content: ""; position: absolute; inset: 0; border-radius: inherit; padding: 1px; background: linear-gradient(135deg, rgba(37,99,235,0.4), rgba(124,58,237,0.4)); -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0); -webkit-mask-composite: xor; mask-composite: exclude; pointer-events: none; }
@layer base { :root { --background: 222 84% 5%; --foreground: 210 40% 98%; --card: 222 47% 8%; --card-foreground: 210 40% 98%; --primary: 221 83% 53%; --primary-foreground: 210 40% 98%; --border: 217 33% 13%; --input: 217 33% 13%; --ring: 221 83% 53%; --radius: 0.625rem; } }
@media (max-width: 640px) { :root { --section-padding: 3rem; --container-padding: 1rem; } }
EOF

# ============================================
# STEP 4: APP ROOT LAYOUT
# ============================================
echo "📐 Writing root layout..."

cat > app/layout.tsx << 'EOF'
import type { Metadata, Viewport } from "next";
import { GeistSans } from "geist/font/sans";
import { GeistMono } from "geist/font/mono";
import { Syne } from "next/font/google";
import { Toaster } from "sonner";
import "@/styles/globals.css";

const syne = Syne({ subsets: ["latin"], weight: ["400","500","600","700","800"], variable: "--font-syne", display: "swap" });

export const metadata: Metadata = {
  metadataBase: new URL(process.env.NEXT_PUBLIC_APP_URL || "https://nifelux.com"),
  title: { default: "Nifelux Technologies — Intelligent Systems for Africa's Future", template: "%s | Nifelux Technologies" },
  description: "Nifelux Technologies builds intelligent digital systems, AI, robotics, and automation for Africa and the global future.",
  keywords: ["Nifelux Technologies", "Nigerian tech company", "AI Africa", "robotics Nigeria"],
  openGraph: { type: "website", locale: "en_NG", url: "https://nifelux.com", siteName: "Nifelux Technologies", images: [{ url: "/og/og-default.png", width: 1200, height: 630 }] },
  twitter: { card: "summary_large_image", title: "Nifelux Technologies", images: ["/og/og-default.png"] },
  robots: { index: true, follow: true },
};

export const viewport: Viewport = { themeColor: "#050816", colorScheme: "dark", width: "device-width", initialScale: 1 };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${GeistSans.variable} ${GeistMono.variable} ${syne.variable}`} suppressHydrationWarning>
      <body className="bg-brand-dark text-white antialiased">
        {children}
        <Toaster theme="dark" position="top-right" toastOptions={{ style: { background: "#111827", border: "1px solid #1E293B", color: "#FFFFFF" } }} />
      </body>
    </html>
  );
}
EOF

# ============================================
# STEP 5: UTILITIES
# ============================================
echo "🔧 Writing utilities..."

cat > utils/cn.ts << 'EOF'
import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
export function cn(...inputs: ClassValue[]) { return twMerge(clsx(inputs)); }
EOF

cat > utils/format.ts << 'EOF'
export function formatCurrency(amount: number, currency = "NGN"): string {
  return new Intl.NumberFormat("en-NG", { style: "currency", currency }).format(amount);
}
export function formatDate(date: string | Date): string {
  return new Intl.DateTimeFormat("en-NG", { year: "numeric", month: "long", day: "numeric" }).format(new Date(date));
}
export function generateIdNumber(): string {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  let r = "NF-";
  for (let i = 0; i < 8; i++) r += chars[Math.floor(Math.random() * chars.length)];
  return r;
}
export function generateVerificationCode(): string {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  let r = "NF-CERT-";
  for (let i = 0; i < 6; i++) r += chars[Math.floor(Math.random() * chars.length)];
  return r;
}
export function truncate(str: string, length: number): string {
  return str.length > length ? str.slice(0, length) + "..." : str;
}
EOF

# ============================================
# STEP 6: TYPES
# ============================================
echo "📝 Writing types..."

cat > types/user.types.ts << 'EOF'
export type UserRole = "user" | "staff" | "admin" | "super_admin";
export type UserStatus = "active" | "suspended" | "pending";
export interface User { id: string; email: string; full_name: string; phone?: string; role: UserRole; status: UserStatus; avatar_url?: string; created_at: string; updated_at: string; }
export interface DigitalId { id: string; user_id: string; id_number: string; qr_code_url: string; issued_at: string; expires_at: string; status: "active" | "expired" | "revoked"; }
export interface Certification { id: string; user_id: string; title: string; description?: string; certificate_url?: string; issued_by: string; issued_at: string; expires_at?: string; verification_code: string; status: "active" | "expired" | "revoked"; }
export interface Payment { id: string; user_id?: string; reference: string; amount: number; currency: string; status: "pending" | "success" | "failed" | "refunded"; purpose: string; paid_at?: string; created_at: string; }
export interface Notification { id: string; user_id: string; title: string; body: string; type: "info" | "success" | "warning" | "alert"; read: boolean; created_at: string; }
EOF

cat > types/api.types.ts << 'EOF'
export interface ApiSuccess<T> { success: true; data: T; message?: string; }
export interface ApiError { success: false; error: string; code?: string; }
export type ApiResponse<T> = ApiSuccess<T> | ApiError;
EOF

cat > types/database.types.ts << 'EOF'
// Run: npx supabase gen types typescript --project-id YOUR_ID > types/database.types.ts
export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];
export interface Database {
  public: {
    Tables: {
      users: { Row: { id: string; email: string; full_name: string; role: string; status: string; created_at: string; updated_at: string; }; };
      digital_ids: { Row: { id: string; user_id: string; id_number: string; qr_code_url: string; status: string; issued_at: string; expires_at: string; }; };
      certifications: { Row: { id: string; user_id: string; title: string; verification_code: string; status: string; issued_at: string; issued_by: string; }; };
      payments: { Row: { id: string; reference: string; amount: number; status: string; created_at: string; }; };
      notifications: { Row: { id: string; user_id: string; title: string; body: string; read: boolean; created_at: string; }; };
    };
  };
}
EOF

# ============================================
# STEP 7: SUPABASE LIB
# ============================================
echo "🗄️  Writing Supabase lib..."

cat > lib/supabase/client.ts << 'EOF'
import { createBrowserClient } from "@supabase/ssr";
import type { Database } from "@/types/database.types";
export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
EOF

cat > lib/supabase/server.ts << 'EOF'
import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import type { Database } from "@/types/database.types";
export async function createClient() {
  const cookieStore = await cookies();
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { getAll() { return cookieStore.getAll(); }, setAll(c) { try { c.forEach(({ name, value, options }) => cookieStore.set(name, value, options)); } catch {} } } }
  );
}
export async function createAdminClient() {
  const cookieStore = await cookies();
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    { cookies: { getAll() { return cookieStore.getAll(); }, setAll(c) { try { c.forEach(({ name, value, options }) => cookieStore.set(name, value, options)); } catch {} } } }
  );
}
EOF

cat > lib/validations/auth.schema.ts << 'EOF'
import { z } from "zod";
export const loginSchema = z.object({ email: z.string().email("Invalid email"), password: z.string().min(6, "Min 6 characters") });
export const registerSchema = z.object({ full_name: z.string().min(2, "Min 2 characters"), email: z.string().email("Invalid email"), password: z.string().min(8, "Min 8 characters").regex(/[A-Z]/, "Need uppercase").regex(/[0-9]/, "Need number"), phone: z.string().optional() });
export const contactSchema = z.object({ name: z.string().min(2), email: z.string().email(), subject: z.string().min(5), message: z.string().min(20) });
export type LoginForm = z.infer<typeof loginSchema>;
export type RegisterForm = z.infer<typeof registerSchema>;
export type ContactForm = z.infer<typeof contactSchema>;
EOF

cat > lib/validations/payment.schema.ts << 'EOF'
import { z } from "zod";
export const contributionSchema = z.object({ amount: z.number().min(100, "Min ₦100"), name: z.string().optional(), email: z.string().email().optional().or(z.literal("")), message: z.string().max(200).optional(), anonymous: z.boolean().default(false) });
export type ContributionForm = z.infer<typeof contributionSchema>;
EOF

# ============================================
# STEP 8: SERVICES
# ============================================
echo "⚙️  Writing services..."

cat > services/auth.service.ts << 'EOF'
import { createClient } from "@/lib/supabase/client";
export const authService = {
  async signIn(email: string, password: string) { const s = createClient(); const { data, error } = await s.auth.signInWithPassword({ email, password }); if (error) throw error; return data; },
  async signUp(email: string, password: string, metadata: { full_name: string; phone?: string }) { const s = createClient(); const { data, error } = await s.auth.signUp({ email, password, options: { data: metadata } }); if (error) throw error; return data; },
  async signOut() { const s = createClient(); const { error } = await s.auth.signOut(); if (error) throw error; },
  async getUser() { const s = createClient(); const { data: { user } } = await s.auth.getUser(); return user; },
};
EOF

cat > services/user.service.ts << 'EOF'
import { createClient } from "@/lib/supabase/client";
import type { User } from "@/types/user.types";
export const userService = {
  async getProfile(userId: string): Promise<User | null> { const s = createClient(); const { data } = await s.from("users").select("*").eq("id", userId).single(); return data as User | null; },
  async updateProfile(userId: string, updates: Partial<User>) { const s = createClient(); const { data, error } = await s.from("users").update({ ...updates, updated_at: new Date().toISOString() }).eq("id", userId).select().single(); if (error) throw error; return data; },
};
EOF

cat > services/id.service.ts << 'EOF'
import { createClient } from "@/lib/supabase/client";
import type { DigitalId } from "@/types/user.types";
export const idService = {
  async getMyId(userId: string): Promise<DigitalId | null> { const s = createClient(); const { data } = await s.from("digital_ids").select("*").eq("user_id", userId).eq("status", "active").single(); return data as DigitalId | null; },
  async verifyId(idNumber: string) { const s = createClient(); const { data } = await s.from("digital_ids").select("*, users(full_name, email)").eq("id_number", idNumber).single(); return data; },
};
EOF

cat > services/certification.service.ts << 'EOF'
import { createClient } from "@/lib/supabase/client";
import type { Certification } from "@/types/user.types";
export const certificationService = {
  async getMyCertifications(userId: string): Promise<Certification[]> { const s = createClient(); const { data } = await s.from("certifications").select("*").eq("user_id", userId).order("issued_at", { ascending: false }); return (data ?? []) as Certification[]; },
  async verify(code: string) { const s = createClient(); const { data } = await s.from("certifications").select("*, users(full_name)").eq("verification_code", code).single(); return data; },
};
EOF

cat > services/payment.service.ts << 'EOF'
export const paymentService = {
  async initiate(amount: number, email: string, purpose: string, metadata?: Record<string, unknown>) {
    const res = await fetch("/api/payments", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ amount, email, purpose, metadata }) });
    if (!res.ok) throw new Error("Payment initiation failed");
    return res.json();
  },
};
EOF

# ============================================
# STEP 9: STORE + HOOKS
# ============================================
echo "🏪 Writing store and hooks..."

cat > store/authStore.ts << 'EOF'
import { create } from "zustand";
import type { User } from "@/types/user.types";
interface AuthState { user: User | null; isLoading: boolean; setUser: (u: User | null) => void; setLoading: (l: boolean) => void; reset: () => void; }
export const useAuthStore = create<AuthState>((set) => ({
  user: null, isLoading: true,
  setUser: (user) => set({ user }),
  setLoading: (isLoading) => set({ isLoading }),
  reset: () => set({ user: null, isLoading: false }),
}));
EOF

cat > store/uiStore.ts << 'EOF'
import { create } from "zustand";
interface UiState { sidebarOpen: boolean; setSidebarOpen: (o: boolean) => void; toggleSidebar: () => void; }
export const useUiStore = create<UiState>((set) => ({
  sidebarOpen: false,
  setSidebarOpen: (sidebarOpen) => set({ sidebarOpen }),
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
}));
EOF

cat > hooks/useAuth.ts << 'EOF'
"use client";
import { useEffect } from "react";
import { createClient } from "@/lib/supabase/client";
import { useAuthStore } from "@/store/authStore";
import { userService } from "@/services/user.service";
export function useAuth() {
  const { user, isLoading, setUser, setLoading } = useAuthStore();
  useEffect(() => {
    const s = createClient();
    s.auth.getSession().then(async ({ data: { session } }) => {
      if (session?.user) { const p = await userService.getProfile(session.user.id); setUser(p); }
      setLoading(false);
    });
    const { data: { subscription } } = s.auth.onAuthStateChange(async (_, session) => {
      if (session?.user) { const p = await userService.getProfile(session.user.id); setUser(p); } else { setUser(null); }
    });
    return () => subscription.unsubscribe();
  }, [setUser, setLoading]);
  return { user, isLoading };
}
EOF

cat > hooks/useUser.ts << 'EOF'
"use client";
import { useAuthStore } from "@/store/authStore";
export function useUser() {
  const user = useAuthStore((s) => s.user);
  return { user, isAdmin: user?.role === "admin" || user?.role === "super_admin", isSuperAdmin: user?.role === "super_admin" };
}
EOF

echo "✅ Store, hooks, services written"

# ============================================
# STEP 10: COMMON COMPONENTS
# ============================================
echo "🧩 Writing components..."

cat > components/common/GlassCard.tsx << 'EOF'
import { cn } from "@/utils/cn";
import { HTMLAttributes, forwardRef } from "react";
interface GlassCardProps extends HTMLAttributes<HTMLDivElement> { variant?: "default"|"bordered"|"gradient"|"elevated"; hover?: boolean; glow?: "blue"|"purple"|"green"|"none"; }
const GlassCard = forwardRef<HTMLDivElement, GlassCardProps>(({ className, variant="default", hover=false, glow="none", children, ...props }, ref) => (
  <div ref={ref} className={cn("relative rounded-2xl overflow-hidden transition-all duration-300",
    variant==="default"&&"glass-card", variant==="bordered"&&"gradient-border bg-brand-card",
    variant==="gradient"&&"bg-gradient-to-br from-white/[0.05] to-white/[0.02] border border-white/[0.06]",
    variant==="elevated"&&"bg-brand-card shadow-card border border-white/[0.05]",
    hover&&"hover:shadow-card-hover hover:-translate-y-1 cursor-pointer",
    glow==="blue"&&"hover:shadow-glow", glow==="purple"&&"hover:shadow-glow-purple", glow==="green"&&"hover:shadow-glow-green",
    className)} {...props}>{children}</div>
));
GlassCard.displayName = "GlassCard";
export default GlassCard;
EOF

cat > components/common/GradientButton.tsx << 'EOF'
"use client";
import { ButtonHTMLAttributes, forwardRef } from "react";
import Link from "next/link";
import { cn } from "@/utils/cn";
import { Loader2 } from "lucide-react";
interface GradientButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "blue-purple"|"green-blue"|"outline"|"ghost"; size?: "sm"|"md"|"lg";
  href?: string; external?: boolean; loading?: boolean; fullWidth?: boolean;
  icon?: React.ReactNode; iconPosition?: "left"|"right";
}
const GradientButton = forwardRef<HTMLButtonElement, GradientButtonProps>(
  ({ className, variant="blue-purple", size="md", href, external, loading, fullWidth, icon, iconPosition="right", children, disabled, ...props }, ref) => {
    const base = cn("relative inline-flex items-center justify-center gap-2 font-semibold rounded-xl border-0 transition-all duration-200 overflow-hidden whitespace-nowrap disabled:opacity-50 disabled:cursor-not-allowed focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-blue focus-visible:ring-offset-2 focus-visible:ring-offset-brand-dark",
      size==="sm"&&"text-sm px-4 py-2.5 h-9", size==="md"&&"text-sm px-5 py-3 h-11", size==="lg"&&"text-base px-7 py-3.5 h-12",
      variant==="blue-purple"&&"bg-gradient-to-r from-brand-blue to-brand-purple text-white hover:shadow-glow hover:-translate-y-0.5",
      variant==="green-blue"&&"bg-gradient-to-r from-brand-green to-brand-blue text-white hover:shadow-glow-green hover:-translate-y-0.5",
      variant==="outline"&&"bg-transparent text-white border border-white/10 hover:bg-white/[0.06] hover:border-white/20 hover:-translate-y-0.5",
      variant==="ghost"&&"bg-transparent text-text-secondary hover:text-white hover:bg-white/[0.05]",
      fullWidth&&"w-full", className);
    const content = loading ? <Loader2 className="w-4 h-4 animate-spin" /> : (
      <>{icon&&iconPosition==="left"&&<span className="flex-shrink-0">{icon}</span>}<span>{children}</span>{icon&&iconPosition==="right"&&<span className="flex-shrink-0">{icon}</span>}</>
    );
    if (href) return <Link href={href} target={external?"_blank":undefined} rel={external?"noopener noreferrer":undefined} className={base}>{content}</Link>;
    return <button ref={ref} className={base} disabled={disabled||loading} {...props}>{content}</button>;
  }
);
GradientButton.displayName = "GradientButton";
export default GradientButton;
EOF

cat > components/common/SectionHeading.tsx << 'EOF'
"use client";
import { motion } from "framer-motion";
import { cn } from "@/utils/cn";
interface SectionHeadingProps { badge?: string; title: string; titleHighlight?: string; description?: string; align?: "left"|"center"|"right"; className?: string; gradient?: "blue-purple"|"green-blue"; }
export default function SectionHeading({ badge, title, titleHighlight, description, align="center", className, gradient="blue-purple" }: SectionHeadingProps) {
  const alignClass = { left:"items-start text-left", center:"items-center text-center", right:"items-end text-right" }[align];
  return (
    <motion.div initial={{ opacity:0, y:20 }} whileInView={{ opacity:1, y:0 }} viewport={{ once:true, margin:"-80px" }} transition={{ duration:0.5 }} className={cn("flex flex-col gap-4", alignClass, className)}>
      {badge && <span className="badge-brand"><span className="w-1.5 h-1.5 rounded-full bg-brand-blue-light animate-pulse-slow" />{badge}</span>}
      <h2 className="font-display text-3xl md:text-4xl lg:text-5xl text-white">
        {title} {titleHighlight && <span className={gradient==="blue-purple"?"gradient-text":"gradient-text-green"}>{titleHighlight}</span>}
      </h2>
      {description && <p className={cn("text-text-secondary text-base md:text-lg leading-relaxed", align==="center"&&"max-w-2xl")}>{description}</p>}
    </motion.div>
  );
}
EOF

cat > components/common/AnimatedSection.tsx << 'EOF'
"use client";
import { motion, Variants } from "framer-motion";
import { cn } from "@/utils/cn";
const V: Record<string, Variants> = {
  up: { hidden:{ opacity:0, y:32 }, visible:{ opacity:1, y:0 } },
  down: { hidden:{ opacity:0, y:-24 }, visible:{ opacity:1, y:0 } },
  left: { hidden:{ opacity:0, x:32 }, visible:{ opacity:1, x:0 } },
  right: { hidden:{ opacity:0, x:-32 }, visible:{ opacity:1, x:0 } },
  none: { hidden:{ opacity:0 }, visible:{ opacity:1 } },
};
interface Props { children: React.ReactNode; className?: string; delay?: number; direction?: "up"|"down"|"left"|"right"|"none"; duration?: number; }
export default function AnimatedSection({ children, className, delay=0, direction="up", duration=0.55 }: Props) {
  return (
    <motion.div initial="hidden" whileInView="visible" viewport={{ once:true, margin:"-60px" }} variants={V[direction]} transition={{ duration, delay, ease:[0.21,0.47,0.32,0.98] }} className={cn(className)}>
      {children}
    </motion.div>
  );
}
export function StaggerContainer({ children, className, stagger=0.08, delay=0 }: { children:React.ReactNode; className?:string; stagger?:number; delay?:number }) {
  return (
    <motion.div initial="hidden" whileInView="visible" viewport={{ once:true, margin:"-60px" }}
      variants={{ hidden:{}, visible:{ transition:{ staggerChildren:stagger, delayChildren:delay } } }} className={cn(className)}>
      {children}
    </motion.div>
  );
}
export function StaggerItem({ children, className, direction="up" }: { children:React.ReactNode; className?:string; direction?:keyof typeof V }) {
  return <motion.div variants={V[direction]} transition={{ duration:0.5, ease:[0.21,0.47,0.32,0.98] }} className={cn(className)}>{children}</motion.div>;
}
EOF

cat > components/common/LoadingSpinner.tsx << 'EOF'
import { cn } from "@/utils/cn";
export default function LoadingSpinner({ size="md", className }: { size?:"sm"|"md"|"lg"; className?:string }) {
  const s = { sm:"w-4 h-4 border-2", md:"w-8 h-8 border-2", lg:"w-12 h-12 border-2" }[size];
  return <div className={cn("rounded-full border-white/20 border-t-brand-blue animate-spin", s, className)} />;
}
EOF

# ============================================
# STEP 11: NAVBAR + FOOTER
# ============================================

cat > components/layout/Navbar.tsx << 'EOF'
"use client";
import { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X, ChevronRight, Zap } from "lucide-react";
import { cn } from "@/utils/cn";

const navLinks = [
  { label:"Home", href:"/" }, { label:"About", href:"/about" }, { label:"Services", href:"/services" },
  { label:"Robotics", href:"/robotics" }, { label:"Projects", href:"/projects" },
  { label:"Certifications", href:"/certifications" }, { label:"Contact", href:"/contact" },
];

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);
  const pathname = usePathname();
  useEffect(() => { const fn = () => setScrolled(window.scrollY > 20); window.addEventListener("scroll", fn, { passive:true }); return () => window.removeEventListener("scroll", fn); }, []);
  useEffect(() => { setOpen(false); }, [pathname]);
  useEffect(() => { document.body.style.overflow = open ? "hidden" : ""; return () => { document.body.style.overflow = ""; }; }, [open]);
  return (
    <>
      <motion.header initial={{ y:-20, opacity:0 }} animate={{ y:0, opacity:1 }} transition={{ duration:0.5 }}
        className={cn("fixed top-0 left-0 right-0 z-50 transition-all duration-300", scrolled?"bg-brand-dark/80 backdrop-blur-xl border-b border-white/[0.06]":"bg-transparent")}>
        <div className="container-custom">
          <div className="flex items-center justify-between h-16">
            <Link href="/" className="flex items-center gap-2.5 group">
              <div className="w-8 h-8 rounded-lg bg-brand-gradient flex items-center justify-center shadow-glow-sm"><Zap className="w-4 h-4 text-white" strokeWidth={2.5} /></div>
              <div className="flex flex-col leading-none">
                <span className="font-display text-base font-bold text-white tracking-tight">Nifelux</span>
                <span className="text-[10px] font-medium text-text-muted tracking-widest uppercase">Technologies</span>
              </div>
            </Link>
            <nav className="hidden md:flex items-center gap-1">
              {navLinks.map((link) => {
                const active = pathname === link.href;
                return (
                  <Link key={link.href} href={link.href} className={cn("relative px-4 py-2 text-sm font-medium rounded-lg transition-all", active?"text-white":"text-text-secondary hover:text-white")}>
                    {active && <motion.span layoutId="nav-active" className="absolute inset-0 bg-white/[0.06] rounded-lg" transition={{ type:"spring", stiffness:400, damping:30 }} />}
                    <span className="relative z-10">{link.label}</span>
                  </Link>
                );
              })}
            </nav>
            <div className="hidden md:flex items-center gap-3">
              <Link href="/support" className="text-sm font-medium text-text-secondary hover:text-white transition-colors">Support</Link>
              <Link href="/dashboard" className="btn-primary text-sm py-2 px-4">Portal <ChevronRight className="w-4 h-4 inline" /></Link>
            </div>
            <button onClick={() => setOpen(!open)} className="md:hidden w-10 h-10 rounded-lg glass flex items-center justify-center text-white">
              {open ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
            </button>
          </div>
        </div>
      </motion.header>
      <AnimatePresence>
        {open && (
          <>
            <motion.div initial={{ opacity:0 }} animate={{ opacity:1 }} exit={{ opacity:0 }} onClick={() => setOpen(false)} className="fixed inset-0 z-40 bg-brand-dark/60 backdrop-blur-sm md:hidden" />
            <motion.div initial={{ x:"100%" }} animate={{ x:0 }} exit={{ x:"100%" }} transition={{ type:"spring", stiffness:300, damping:30 }}
              className="fixed top-0 right-0 bottom-0 z-50 w-72 bg-brand-dark-secondary border-l border-white/[0.06] flex flex-col md:hidden">
              <div className="flex items-center justify-between p-5 border-b border-white/[0.06]">
                <span className="font-display font-bold text-white">Nifelux</span>
                <button onClick={() => setOpen(false)} className="w-8 h-8 glass rounded-lg flex items-center justify-center text-text-muted"><X className="w-4 h-4" /></button>
              </div>
              <nav className="flex-1 p-4 space-y-1">
                {navLinks.map((link) => (
                  <Link key={link.href} href={link.href} className={cn("flex items-center px-4 py-3 rounded-xl text-sm font-medium transition-all", pathname===link.href?"bg-white/[0.08] text-white":"text-text-secondary hover:text-white hover:bg-white/[0.04]")}>{link.label}</Link>
                ))}
              </nav>
              <div className="p-4 border-t border-white/[0.06] space-y-3">
                <Link href="/support" className="btn-secondary w-full text-sm justify-center flex">Support Us</Link>
                <Link href="/dashboard" className="btn-primary w-full text-sm justify-center">Portal</Link>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
}
EOF

cat > components/layout/Footer.tsx << 'EOF'
"use client";
import Link from "next/link";
import { Zap, Twitter, Linkedin, Github, Mail, MapPin, ArrowUpRight } from "lucide-react";
const footerLinks = {
  Company: [{ label:"About", href:"/about" }, { label:"Services", href:"/services" }, { label:"Projects", href:"/projects" }, { label:"Robotics", href:"/robotics" }, { label:"Contact", href:"/contact" }],
  Resources: [{ label:"Certifications", href:"/certifications" }, { label:"Support Us", href:"/support" }, { label:"Dashboard", href:"/dashboard" }],
  Legal: [{ label:"Privacy Policy", href:"/privacy" }, { label:"Terms of Service", href:"/terms" }],
};
const socials = [
  { icon:Twitter, href:"https://twitter.com/nifelux", label:"Twitter" },
  { icon:Linkedin, href:"https://linkedin.com/company/nifelux", label:"LinkedIn" },
  { icon:Github, href:"https://github.com/nifelux", label:"GitHub" },
  { icon:Mail, href:"mailto:hello@nifelux.com", label:"Email" },
];
export default function Footer() {
  return (
    <footer className="relative border-t border-white/[0.06] bg-brand-dark-secondary overflow-hidden">
      <div className="absolute bottom-0 left-1/4 w-96 h-64 orb orb-blue opacity-20 pointer-events-none" />
      <div className="container-custom py-16 relative z-10">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-12 mb-12">
          <div className="lg:col-span-2">
            <Link href="/" className="flex items-center gap-2.5 w-fit mb-5">
              <div className="w-9 h-9 rounded-xl bg-brand-gradient flex items-center justify-center shadow-glow-sm"><Zap className="w-4 h-4 text-white" strokeWidth={2.5} /></div>
              <div className="flex flex-col leading-none"><span className="font-display text-lg font-bold text-white">Nifelux</span><span className="text-[10px] text-text-muted tracking-widest uppercase">Technologies</span></div>
            </Link>
            <p className="text-text-secondary text-sm leading-relaxed max-w-xs mb-5">Building intelligent digital systems, AI, robotics, and automation for Africa and the global future.</p>
            <div className="flex items-center gap-1.5 text-text-muted text-xs mb-5"><MapPin className="w-3.5 h-3.5 text-brand-green" /><span>Lagos, Nigeria</span></div>
            <div className="flex items-center gap-2">
              {socials.map(({ icon:I, href, label }) => (
                <a key={label} href={href} target={href.startsWith("http")?"_blank":undefined} rel={href.startsWith("http")?"noopener noreferrer":undefined} className="w-9 h-9 rounded-lg glass flex items-center justify-center text-text-muted hover:text-white hover:bg-white/10 transition-all">
                  <I className="w-4 h-4" />
                </a>
              ))}
            </div>
          </div>
          {Object.entries(footerLinks).map(([cat, links]) => (
            <div key={cat}>
              <h4 className="text-xs font-semibold text-text-muted uppercase tracking-widest mb-4">{cat}</h4>
              <ul className="space-y-3">
                {links.map((link) => (
                  <li key={link.href}>
                    <Link href={link.href} className="text-sm text-text-secondary hover:text-white transition-colors flex items-center gap-1 group">
                      {link.label}<ArrowUpRight className="w-3 h-3 opacity-0 group-hover:opacity-100 transition-opacity" />
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
        <div className="section-divider mb-8" />
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="text-text-muted text-xs">© {new Date().getFullYear()} Nifelux Technologies. All rights reserved.</p>
          <p className="text-text-muted text-xs">Built in <span className="text-brand-green font-medium">Nigeria</span> for the world 🌍</p>
        </div>
      </div>
    </footer>
  );
}
EOF

cat > app/\(public\)/layout.tsx << 'EOF'
import Navbar from "@/components/layout/Navbar";
import Footer from "@/components/layout/Footer";
export default function PublicLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex flex-col min-h-screen">
      <Navbar />
      <main className="flex-1 pt-16">{children}</main>
      <Footer />
    </div>
  );
}
EOF

echo "✅ Components written"

# ============================================
# STEP 12: PUBLIC PAGES
# ============================================
echo "📄 Writing public pages..."

cat > app/\(public\)/page.tsx << 'EOF'
"use client";
import { motion } from "framer-motion";
import { ArrowRight, Bot, Cpu, Globe, Shield, Zap, BrainCircuit, Network, Layers, ChevronRight, TrendingUp } from "lucide-react";
import Link from "next/link";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import SectionHeading from "@/components/common/SectionHeading";
import AnimatedSection, { StaggerContainer, StaggerItem } from "@/components/common/AnimatedSection";

const services = [
  { icon:BrainCircuit, title:"Artificial Intelligence", desc:"Intelligent systems that learn, adapt, and solve complex real-world problems at production scale.", color:"blue", href:"/services" },
  { icon:Bot, title:"Robotics Engineering", desc:"Advanced robotic systems for industrial, educational, and research applications across Africa.", color:"purple", href:"/robotics" },
  { icon:Cpu, title:"Automation Systems", desc:"Intelligent automation platforms that eliminate manual processes and scale with your business.", color:"green", href:"/services" },
  { icon:Shield, title:"Digital Infrastructure", desc:"Secure, scalable cloud architecture and digital identity systems for the next generation.", color:"blue", href:"/services" },
  { icon:Network, title:"Smart Platforms", desc:"SaaS and enterprise platforms built with enterprise-grade engineering from day one.", color:"purple", href:"/services" },
  { icon:Layers, title:"Software Engineering", desc:"Full-stack development using modern technologies with clean architecture and production-ready standards.", color:"green", href:"/services" },
];
const cmap: Record<string,"blue"|"purple"|"green"> = { blue:"blue", purple:"purple", green:"green" };
const gradMap: Record<string, string> = { blue:"from-brand-blue/10 to-transparent border-brand-blue/20 group-hover:border-brand-blue/40", purple:"from-brand-purple/10 to-transparent border-brand-purple/20 group-hover:border-brand-purple/40", green:"from-brand-green/10 to-transparent border-brand-green/20 group-hover:border-brand-green/40" };
const imap: Record<string, string> = { blue:"bg-brand-blue/10 text-brand-blue-light", purple:"bg-brand-purple/10 text-brand-purple-light", green:"bg-brand-green/10 text-brand-green" };

export default function HomePage() {
  return (
    <>
      <section className="relative min-h-[100svh] flex items-center justify-center overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark"><div className="absolute inset-0 bg-hero-gradient" /><div className="absolute inset-0 dot-pattern opacity-40" /></div>
        <div className="absolute top-1/4 left-1/4 w-96 h-96 orb orb-blue opacity-40 animate-float-slow" />
        <div className="absolute top-1/3 right-1/4 w-72 h-72 orb orb-purple opacity-30 animate-float" style={{ animationDelay:"2s" }} />
        <div className="container-custom relative z-10 py-24">
          <div className="flex flex-col items-center text-center max-w-5xl mx-auto">
            <motion.span initial={{ opacity:0, y:16 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.5 }} className="badge-brand mb-6">
              <span className="w-1.5 h-1.5 rounded-full bg-brand-green animate-pulse" />Africa&apos;s Future Technology Company
            </motion.span>
            <motion.h1 initial={{ opacity:0, y:24 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.6, delay:0.1 }}
              className="font-display text-[2.8rem] sm:text-[3.5rem] md:text-[4.5rem] lg:text-[5.5rem] leading-[1.05] tracking-tight text-white mb-6">
              Intelligent Systems<br /><span className="gradient-text">for Africa&apos;s</span><br />Future
            </motion.h1>
            <motion.p initial={{ opacity:0, y:24 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.6, delay:0.2 }} className="text-text-secondary text-base sm:text-lg md:text-xl leading-relaxed max-w-2xl mb-10">
              Nifelux Technologies builds world-class AI systems, robotics solutions, automation platforms, and digital infrastructure for Africa and the global future.
            </motion.p>
            <motion.div initial={{ opacity:0, y:24 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.6, delay:0.3 }} className="flex flex-col sm:flex-row items-center gap-3 mb-16">
              <GradientButton href="/services" variant="blue-purple" size="lg" icon={<ArrowRight className="w-5 h-5" />}>Explore Our Systems</GradientButton>
              <GradientButton href="/about" variant="outline" size="lg" icon={<ChevronRight className="w-5 h-5" />}>Our Vision</GradientButton>
            </motion.div>
            <motion.div initial={{ opacity:0, y:24 }} animate={{ opacity:1, y:0 }} transition={{ duration:0.6, delay:0.4 }} className="grid grid-cols-2 sm:grid-cols-4 gap-4 w-full max-w-3xl">
              {[{ v:"∞", l:"Possibilities", i:TrendingUp }, { v:"100%", l:"Nigeria-Built", i:Globe }, { v:"AI+", l:"Powered Systems", i:BrainCircuit }, { v:"Next", l:"Generation Ready", i:Zap }].map(({ v, l, i:I }) => (
                <div key={l} className="glass-card p-4 flex flex-col items-center gap-2">
                  <I className="w-5 h-5 text-brand-blue-light" />
                  <span className="font-display text-2xl font-bold text-white">{v}</span>
                  <span className="text-text-muted text-xs text-center">{l}</span>
                </div>
              ))}
            </motion.div>
          </div>
        </div>
        <motion.div initial={{ opacity:0 }} animate={{ opacity:1 }} transition={{ delay:1 }} className="absolute bottom-8 left-1/2 -translate-x-1/2 flex flex-col items-center gap-2">
          <span className="text-text-muted text-xs tracking-widest uppercase">Scroll</span>
          <motion.div animate={{ y:[0,6,0] }} transition={{ duration:1.5, repeat:Infinity }} className="w-0.5 h-8 bg-gradient-to-b from-brand-blue to-transparent rounded-full" />
        </motion.div>
      </section>

      <section className="section-padding relative overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark-secondary" /><div className="absolute inset-0 grid-pattern opacity-30" />
        <div className="container-custom relative z-10">
          <SectionHeading badge="What We Build" title="Systems That Shape" titleHighlight="Tomorrow" description="From AI infrastructure to robotics platforms, every system we build is engineered for scale, security, and real-world impact." className="mb-16" />
          <StaggerContainer className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {services.map((s) => {
              const I = s.icon;
              return (
                <StaggerItem key={s.title}>
                  <Link href={s.href} className="block group">
                    <GlassCard hover className={`p-6 h-full bg-gradient-to-br ${gradMap[s.color]} border`}>
                      <div className={`w-11 h-11 rounded-xl flex items-center justify-center mb-4 transition-colors ${imap[s.color]}`}><I className="w-5 h-5" /></div>
                      <h3 className="font-display text-base font-bold text-white mb-2">{s.title}</h3>
                      <p className="text-text-secondary text-sm leading-relaxed mb-4">{s.desc}</p>
                      <div className="flex items-center gap-1.5 text-xs font-medium text-text-muted group-hover:text-brand-blue-light transition-colors">Learn more <ArrowRight className="w-3.5 h-3.5 group-hover:translate-x-1 transition-transform" /></div>
                    </GlassCard>
                  </Link>
                </StaggerItem>
              );
            })}
          </StaggerContainer>
        </div>
      </section>

      <section className="section-padding relative overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark" />
        <div className="container-custom relative z-10 text-center">
          <AnimatedSection>
            <GlassCard variant="gradient" className="max-w-4xl mx-auto p-10 md:p-16 border border-white/[0.06]">
              <div className="text-7xl font-display text-brand-blue/20 leading-none mb-4">&ldquo;</div>
              <blockquote className="font-display text-xl md:text-2xl text-white leading-relaxed mb-8">We are not building for today — we are building the systems that will power Africa&apos;s most ambitious future.</blockquote>
              <div className="flex flex-col items-center gap-2">
                <div className="w-12 h-px bg-gradient-to-r from-transparent via-white/30 to-transparent" />
                <div className="text-sm font-semibold text-white">Oluwanifemi Abdullahi Olude</div>
                <div className="text-xs text-text-muted">Founder &amp; CEO, Nifelux Technologies</div>
              </div>
            </GlassCard>
          </AnimatedSection>
        </div>
      </section>

      <section className="section-padding relative overflow-hidden">
        <div className="absolute inset-0 bg-brand-dark-secondary" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[400px] orb orb-blue opacity-20" />
        <div className="container-custom relative z-10 text-center">
          <AnimatedSection>
            <span className="badge-brand mb-6 inline-flex"><span className="w-1.5 h-1.5 rounded-full bg-brand-blue-light animate-pulse" />Get In Touch</span>
            <h2 className="font-display text-4xl md:text-5xl text-white mb-6">Ready to Build the <span className="gradient-text">Future Together?</span></h2>
            <p className="text-text-secondary text-lg leading-relaxed mb-10 max-w-xl mx-auto">Whether you&apos;re a partner, investor, or someone who shares the vision — we want to hear from you.</p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
              <GradientButton href="/contact" variant="blue-purple" size="lg" icon={<ArrowRight className="w-5 h-5" />}>Contact Nifelux</GradientButton>
              <GradientButton href="/support" variant="green-blue" size="lg" icon={<Zap className="w-5 h-5" />} iconPosition="left">Support Our Mission</GradientButton>
            </div>
          </AnimatedSection>
        </div>
      </section>
    </>
  );
}
EOF

# Remaining public pages — full stubs with proper UI
for page in about services robotics projects certifications support contact; do
  CAP=$(echo "$page" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
cat > app/\(public\)/$page/page.tsx << PAGEEOF
import { Metadata } from "next";
export const metadata: Metadata = { title: "${CAP}" };
export default function ${CAP}Page() {
  return (
    <div className="min-h-screen bg-brand-dark flex items-center justify-center">
      <div className="text-center px-4">
        <div className="w-16 h-16 rounded-2xl bg-brand-gradient mx-auto flex items-center justify-center mb-6">
          <span className="text-2xl">🚀</span>
        </div>
        <h1 className="font-display text-3xl font-bold text-white mb-3">${CAP}</h1>
        <p className="text-text-muted text-sm max-w-sm mx-auto">Full page implementation ready. Copy the matching Phase 1 output file into this path.</p>
        <a href="/" className="inline-flex items-center gap-2 mt-6 text-sm text-brand-blue-light hover:text-white transition-colors">← Back to Home</a>
      </div>
    </div>
  );
}
PAGEEOF
done

echo "✅ Public pages written"

# ============================================
# STEP 13: AUTH PAGES
# ============================================
echo "🔐 Writing auth pages..."

cat > app/\(auth\)/layout.tsx << 'EOF'
export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-brand-dark flex items-center justify-center relative overflow-hidden">
      <div className="absolute inset-0 bg-hero-gradient" /><div className="absolute inset-0 dot-pattern opacity-30" />
      <div className="absolute top-1/4 left-1/4 w-80 h-80 orb orb-blue opacity-30 animate-float-slow" />
      <div className="absolute bottom-1/4 right-1/4 w-60 h-60 orb orb-purple opacity-20 animate-float" />
      <div className="relative z-10 w-full max-w-md px-4">{children}</div>
    </div>
  );
}
EOF

cat > app/\(auth\)/login/page.tsx << 'EOF'
"use client";
import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Eye, EyeOff, Zap } from "lucide-react";
import { toast } from "sonner";
import { loginSchema, type LoginForm } from "@/lib/validations/auth.schema";
import { authService } from "@/services/auth.service";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";

export default function LoginPage() {
  const [show, setShow] = useState(false);
  const router = useRouter();
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<LoginForm>({ resolver: zodResolver(loginSchema) });
  const onSubmit = async (data: LoginForm) => {
    try { await authService.signIn(data.email, data.password); toast.success("Welcome back!"); router.push("/dashboard"); }
    catch (err: unknown) { toast.error(err instanceof Error ? err.message : "Invalid credentials"); }
  };
  return (
    <GlassCard variant="gradient" className="p-8 border border-white/[0.06]">
      <div className="flex items-center gap-3 mb-8">
        <div className="w-10 h-10 rounded-xl bg-brand-gradient flex items-center justify-center shadow-glow-sm"><Zap className="w-5 h-5 text-white" strokeWidth={2.5} /></div>
        <div><div className="font-display text-lg font-bold text-white">Nifelux</div><div className="text-xs text-text-muted">Sign in to your account</div></div>
      </div>
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
        <div>
          <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Email</label>
          <input {...register("email")} type="email" placeholder="you@email.com" className="input-brand" />
          {errors.email && <p className="mt-1.5 text-xs text-red-400">{errors.email.message}</p>}
        </div>
        <div>
          <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Password</label>
          <div className="relative">
            <input {...register("password")} type={show?"text":"password"} placeholder="••••••••" className="input-brand pr-12" />
            <button type="button" onClick={() => setShow(!show)} className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted hover:text-white transition-colors">{show?<EyeOff className="w-4 h-4" />:<Eye className="w-4 h-4" />}</button>
          </div>
          {errors.password && <p className="mt-1.5 text-xs text-red-400">{errors.password.message}</p>}
        </div>
        <GradientButton type="submit" variant="blue-purple" size="md" fullWidth loading={isSubmitting}>{isSubmitting?"Signing in...":"Sign In"}</GradientButton>
      </form>
      <p className="text-center text-sm text-text-muted mt-6">Don&apos;t have an account? <Link href="/register" className="text-brand-blue-light hover:text-white transition-colors font-medium">Create one</Link></p>
    </GlassCard>
  );
}
EOF

cat > app/\(auth\)/register/page.tsx << 'EOF'
"use client";
import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Eye, EyeOff, Zap } from "lucide-react";
import { toast } from "sonner";
import { registerSchema, type RegisterForm } from "@/lib/validations/auth.schema";
import { authService } from "@/services/auth.service";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";

export default function RegisterPage() {
  const [show, setShow] = useState(false);
  const router = useRouter();
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<RegisterForm>({ resolver: zodResolver(registerSchema) });
  const onSubmit = async (data: RegisterForm) => {
    try { await authService.signUp(data.email, data.password, { full_name: data.full_name, phone: data.phone }); toast.success("Account created! Check your email."); router.push("/login"); }
    catch (err: unknown) { toast.error(err instanceof Error ? err.message : "Registration failed"); }
  };
  return (
    <GlassCard variant="gradient" className="p-8 border border-white/[0.06]">
      <div className="flex items-center gap-3 mb-8">
        <div className="w-10 h-10 rounded-xl bg-brand-gradient flex items-center justify-center shadow-glow-sm"><Zap className="w-5 h-5 text-white" strokeWidth={2.5} /></div>
        <div><div className="font-display text-lg font-bold text-white">Join Nifelux</div><div className="text-xs text-text-muted">Create your account</div></div>
      </div>
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        <div>
          <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Full Name</label>
          <input {...register("full_name")} placeholder="Your full name" className="input-brand" />
          {errors.full_name && <p className="mt-1.5 text-xs text-red-400">{errors.full_name.message}</p>}
        </div>
        <div>
          <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Email</label>
          <input {...register("email")} type="email" placeholder="you@email.com" className="input-brand" />
          {errors.email && <p className="mt-1.5 text-xs text-red-400">{errors.email.message}</p>}
        </div>
        <div>
          <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Phone (Optional)</label>
          <input {...register("phone")} type="tel" placeholder="+234 800 000 0000" className="input-brand" />
        </div>
        <div>
          <label className="block text-xs font-semibold text-text-secondary mb-2 uppercase tracking-wider">Password</label>
          <div className="relative">
            <input {...register("password")} type={show?"text":"password"} placeholder="Min 8 chars, 1 uppercase, 1 number" className="input-brand pr-12" />
            <button type="button" onClick={() => setShow(!show)} className="absolute right-3 top-1/2 -translate-y-1/2 text-text-muted hover:text-white">{show?<EyeOff className="w-4 h-4" />:<Eye className="w-4 h-4" />}</button>
          </div>
          {errors.password && <p className="mt-1.5 text-xs text-red-400">{errors.password.message}</p>}
        </div>
        <GradientButton type="submit" variant="blue-purple" size="md" fullWidth loading={isSubmitting}>{isSubmitting?"Creating...":"Create Account"}</GradientButton>
      </form>
      <p className="text-center text-sm text-text-muted mt-6">Already have an account? <Link href="/login" className="text-brand-blue-light hover:text-white transition-colors font-medium">Sign in</Link></p>
    </GlassCard>
  );
}
EOF

echo "✅ Auth pages written"

# ============================================
# STEP 14: DASHBOARD LAYOUT + PAGES
# ============================================
echo "📊 Writing dashboard..."

cat > app/\(dashboard\)/layout.tsx << 'EOF'
"use client";
import { useEffect } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { LayoutDashboard, CreditCard, Award, LogOut, Zap, Bell } from "lucide-react";
import { cn } from "@/utils/cn";
import { authService } from "@/services/auth.service";
import { useAuth } from "@/hooks/useAuth";
import { toast } from "sonner";
import LoadingSpinner from "@/components/common/LoadingSpinner";

const nav = [
  { icon:LayoutDashboard, label:"Dashboard", href:"/dashboard" },
  { icon:CreditCard, label:"My ID Card", href:"/id-card" },
  { icon:Award, label:"Certifications", href:"/dashboard/certifications" },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const { user, isLoading } = useAuth();
  const router = useRouter();
  const pathname = usePathname();
  useEffect(() => { if (!isLoading && !user) router.replace("/login"); }, [user, isLoading, router]);
  if (isLoading) return <div className="min-h-screen bg-brand-dark flex items-center justify-center"><LoadingSpinner size="lg" /></div>;
  if (!user) return null;
  const handleSignOut = async () => { await authService.signOut(); toast.success("Signed out"); router.push("/"); };
  return (
    <div className="min-h-screen bg-brand-dark flex">
      <aside className="hidden md:flex w-64 flex-col border-r border-white/[0.06] bg-brand-dark-secondary">
        <div className="p-6 border-b border-white/[0.06]">
          <Link href="/" className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-brand-gradient flex items-center justify-center"><Zap className="w-4 h-4 text-white" strokeWidth={2.5} /></div>
            <span className="font-display text-base font-bold text-white">Nifelux</span>
          </Link>
        </div>
        <nav className="flex-1 p-4 space-y-1">
          {nav.map(({ icon:I, label, href }) => (
            <Link key={href} href={href} className={cn("flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all", pathname===href?"bg-brand-blue/10 text-white border border-brand-blue/20":"text-text-secondary hover:text-white hover:bg-white/[0.04]")}>
              <I className="w-4 h-4" />{label}
            </Link>
          ))}
        </nav>
        <div className="p-4 border-t border-white/[0.06]">
          <div className="flex items-center gap-3 px-4 py-3 mb-2">
            <div className="w-8 h-8 rounded-full bg-brand-gradient flex items-center justify-center text-xs font-bold text-white">{user.full_name?.[0]?.toUpperCase()??"N"}</div>
            <div className="flex-1 min-w-0"><div className="text-sm font-medium text-white truncate">{user.full_name}</div><div className="text-xs text-text-muted capitalize">{user.role}</div></div>
          </div>
          <button onClick={handleSignOut} className="flex items-center gap-3 px-4 py-2.5 w-full rounded-xl text-sm text-text-secondary hover:text-white hover:bg-white/[0.04] transition-all"><LogOut className="w-4 h-4" />Sign Out</button>
        </div>
      </aside>
      <div className="flex-1 flex flex-col min-w-0">
        <header className="h-16 border-b border-white/[0.06] bg-brand-dark-secondary/50 backdrop-blur-sm flex items-center justify-between px-6">
          <h1 className="font-display text-base font-bold text-white">{nav.find((n) => n.href===pathname)?.label??"Dashboard"}</h1>
          <div className="flex items-center gap-3">
            <button className="w-9 h-9 rounded-lg glass flex items-center justify-center text-text-muted hover:text-white transition-colors"><Bell className="w-4 h-4" /></button>
            <div className="w-8 h-8 rounded-full bg-brand-gradient flex items-center justify-center text-xs font-bold text-white">{user.full_name?.[0]?.toUpperCase()??"N"}</div>
          </div>
        </header>
        <main className="flex-1 p-6 overflow-auto">{children}</main>
      </div>
    </div>
  );
}
EOF

cat > app/\(dashboard\)/dashboard/page.tsx << 'EOF'
"use client";
import { useEffect, useState } from "react";
import { CreditCard, Award, Zap, ArrowRight } from "lucide-react";
import Link from "next/link";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import { useUser } from "@/hooks/useUser";
import { idService } from "@/services/id.service";
import { certificationService } from "@/services/certification.service";
import type { DigitalId, Certification } from "@/types/user.types";

export default function DashboardPage() {
  const { user } = useUser();
  const [digitalId, setDigitalId] = useState<DigitalId | null>(null);
  const [certs, setCerts] = useState<Certification[]>([]);
  useEffect(() => { if (!user) return; idService.getMyId(user.id).then(setDigitalId); certificationService.getMyCertifications(user.id).then(setCerts); }, [user]);
  return (
    <div className="max-w-5xl mx-auto space-y-8">
      <div><h2 className="font-display text-2xl font-bold text-white mb-1">Welcome back, {user?.full_name?.split(" ")[0]} 👋</h2><p className="text-text-muted text-sm">Your Nifelux dashboard overview.</p></div>
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        {[
          { label:"Digital ID", value:digitalId?digitalId.id_number:"Not issued", icon:CreditCard, color:"blue", href:"/id-card" },
          { label:"Certifications", value:certs.length.toString(), icon:Award, color:"green", href:"/dashboard/certifications" },
          { label:"Account Status", value:user?.status??"Active", icon:Zap, color:"purple", href:"/dashboard" },
        ].map(({ label, value, icon:I, color, href }) => (
          <Link key={label} href={href}>
            <GlassCard hover className={`p-5 border ${color==="blue"?"border-brand-blue/20":color==="green"?"border-brand-green/20":"border-brand-purple/20"}`}>
              <div className={`w-9 h-9 rounded-xl flex items-center justify-center mb-3 ${color==="blue"?"bg-brand-blue/10 text-brand-blue-light":color==="green"?"bg-brand-green/10 text-brand-green":"bg-brand-purple/10 text-brand-purple-light"}`}><I className="w-4 h-4" /></div>
              <div className="text-xs text-text-muted mb-1">{label}</div>
              <div className="font-display text-base font-bold text-white">{value}</div>
            </GlassCard>
          </Link>
        ))}
      </div>
      <GlassCard className="p-6 border border-white/[0.05]">
        <h3 className="font-display text-base font-bold text-white mb-4 flex items-center gap-2"><CreditCard className="w-4 h-4 text-brand-blue-light" />Digital ID</h3>
        {digitalId ? (
          <div className="space-y-2">
            <div className="flex justify-between text-sm"><span className="text-text-muted">ID Number</span><span className="text-white font-mono text-xs">{digitalId.id_number}</span></div>
            <div className="flex justify-between text-sm"><span className="text-text-muted">Status</span><span className="text-brand-green capitalize">{digitalId.status}</span></div>
            <div className="mt-4"><GradientButton href="/id-card" variant="outline" size="sm" icon={<ArrowRight className="w-3.5 h-3.5" />}>View ID Card</GradientButton></div>
          </div>
        ) : (
          <div className="text-center py-4"><p className="text-text-muted text-sm mb-4">No digital ID has been issued yet.</p><GradientButton href="/contact" variant="outline" size="sm">Request ID</GradientButton></div>
        )}
      </GlassCard>
    </div>
  );
}
EOF

cat > app/\(dashboard\)/id-card/page.tsx << 'EOF'
"use client";
import { useEffect, useState } from "react";
import { QrCode, Shield, Calendar } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import { useUser } from "@/hooks/useUser";
import { idService } from "@/services/id.service";
import type { DigitalId } from "@/types/user.types";
import { formatDate } from "@/utils/format";

export default function IdCardPage() {
  const { user } = useUser();
  const [id, setId] = useState<DigitalId | null>(null);
  useEffect(() => { if (!user) return; idService.getMyId(user.id).then(setId); }, [user]);
  if (!id) return (
    <div className="max-w-2xl mx-auto text-center py-20">
      <QrCode className="w-12 h-12 text-text-muted mx-auto mb-4" />
      <h2 className="font-display text-xl font-bold text-white mb-2">No Digital ID Yet</h2>
      <p className="text-text-muted text-sm">Your digital ID will appear here once issued by an admin.</p>
    </div>
  );
  return (
    <div className="max-w-md mx-auto space-y-6">
      <h2 className="font-display text-2xl font-bold text-white">My Digital ID</h2>
      <GlassCard className="overflow-hidden">
        <div className="bg-brand-gradient p-6">
          <div className="flex items-center justify-between mb-6">
            <div><div className="text-white/70 text-xs uppercase tracking-widest">Nifelux Technologies</div><div className="text-white font-display text-sm font-bold">Digital Identity Card</div></div>
            <Shield className="w-6 h-6 text-white/70" />
          </div>
          <div className="text-white"><div className="text-2xl font-display font-bold mb-1">{user?.full_name}</div><div className="text-white/70 text-sm capitalize">{user?.role}</div></div>
        </div>
        <div className="p-6 bg-brand-card space-y-4">
          <div className="flex items-center justify-between">
            <div><div className="text-xs text-text-muted mb-1">ID Number</div><div className="font-mono text-sm text-white font-bold">{id.id_number}</div></div>
            <div className="text-right"><div className="text-xs text-text-muted mb-1">Status</div><span className="text-xs px-2.5 py-1 rounded-full bg-brand-green/10 text-brand-green font-semibold capitalize">{id.status}</span></div>
          </div>
          <div className="flex items-center justify-between">
            <div><div className="text-xs text-text-muted mb-1 flex items-center gap-1"><Calendar className="w-3 h-3" />Issued</div><div className="text-xs text-white">{formatDate(id.issued_at)}</div></div>
            <div className="text-right"><div className="text-xs text-text-muted mb-1">Expires</div><div className="text-xs text-white">{formatDate(id.expires_at)}</div></div>
          </div>
          {id.qr_code_url && <div className="flex justify-center pt-2"><img src={id.qr_code_url} alt="QR Code" className="w-24 h-24 rounded-lg" /></div>}
          <div className="text-center text-xs text-text-muted pt-2 border-t border-white/[0.06]">Verify at nifelux.com/verify</div>
        </div>
      </GlassCard>
    </div>
  );
}
EOF

cat > app/\(dashboard\)/certifications/page.tsx << 'EOF'
"use client";
import { useEffect, useState } from "react";
import { Award, Download, ExternalLink } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import { useUser } from "@/hooks/useUser";
import { certificationService } from "@/services/certification.service";
import type { Certification } from "@/types/user.types";
import { formatDate } from "@/utils/format";

export default function CertificationsPage() {
  const { user } = useUser();
  const [certs, setCerts] = useState<Certification[]>([]);
  useEffect(() => { if (!user) return; certificationService.getMyCertifications(user.id).then(setCerts); }, [user]);
  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <h2 className="font-display text-2xl font-bold text-white">My Certifications</h2>
      {certs.length===0 ? (
        <GlassCard className="p-12 border border-white/[0.05] text-center"><Award className="w-12 h-12 text-text-muted mx-auto mb-4" /><h3 className="font-display text-lg font-bold text-white mb-2">No certifications yet</h3><p className="text-text-muted text-sm">Your certifications will appear here once issued.</p></GlassCard>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {certs.map((cert) => (
            <GlassCard key={cert.id} className="p-6 border border-white/[0.05]">
              <div className="flex items-start justify-between mb-4">
                <div className="w-10 h-10 rounded-xl bg-brand-green/10 flex items-center justify-center"><Award className="w-5 h-5 text-brand-green" /></div>
                <span className={`text-xs px-2.5 py-1 rounded-full font-semibold ${cert.status==="active"?"bg-brand-green/10 text-brand-green":"bg-white/[0.05] text-text-muted"}`}>{cert.status}</span>
              </div>
              <h3 className="font-display text-base font-bold text-white mb-1">{cert.title}</h3>
              <p className="text-text-muted text-xs mb-3">Issued by {cert.issued_by} · {formatDate(cert.issued_at)}</p>
              <div className="text-xs text-text-muted font-mono bg-white/[0.03] px-3 py-2 rounded-lg mb-4">{cert.verification_code}</div>
              <div className="flex gap-3">
                {cert.certificate_url && <a href={cert.certificate_url} target="_blank" rel="noopener noreferrer" className="flex items-center gap-1.5 text-xs text-brand-blue-light hover:text-white transition-colors"><Download className="w-3.5 h-3.5" />Download</a>}
                <a href={`/verify/${cert.verification_code}`} target="_blank" rel="noopener noreferrer" className="flex items-center gap-1.5 text-xs text-text-muted hover:text-white transition-colors"><ExternalLink className="w-3.5 h-3.5" />Verify</a>
              </div>
            </GlassCard>
          ))}
        </div>
      )}
    </div>
  );
}
EOF

echo "✅ Dashboard pages written"

# ============================================
# STEP 15: ADMIN
# ============================================
echo "🛡️  Writing admin..."

cat > app/\(admin\)/layout.tsx << 'EOF'
"use client";
import { useEffect } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { LayoutDashboard, Users, CreditCard, Award, BarChart2, Activity, Shield, LogOut, Zap } from "lucide-react";
import { cn } from "@/utils/cn";
import { authService } from "@/services/auth.service";
import { useAuth } from "@/hooks/useAuth";
import { useUser } from "@/hooks/useUser";
import { toast } from "sonner";
import LoadingSpinner from "@/components/common/LoadingSpinner";

const nav = [
  { icon:LayoutDashboard, label:"Overview", href:"/admin/dashboard" },
  { icon:Users, label:"Users", href:"/admin/users" },
  { icon:CreditCard, label:"ID Management", href:"/admin/id-management" },
  { icon:Award, label:"Certifications", href:"/admin/certifications" },
  { icon:BarChart2, label:"Payments", href:"/admin/payments" },
  { icon:Activity, label:"Activity Logs", href:"/admin/activity-logs" },
  { icon:BarChart2, label:"Analytics", href:"/admin/analytics" },
  { icon:Shield, label:"Roles", href:"/admin/roles" },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const { user, isLoading } = useAuth();
  const { isAdmin } = useUser();
  const router = useRouter();
  const pathname = usePathname();
  useEffect(() => { if (!isLoading && (!user || !isAdmin)) router.replace("/login"); }, [user, isLoading, isAdmin, router]);
  if (isLoading) return <div className="min-h-screen bg-brand-dark flex items-center justify-center"><LoadingSpinner size="lg" /></div>;
  if (!user || !isAdmin) return null;
  const handleSignOut = async () => { await authService.signOut(); toast.success("Signed out"); router.push("/"); };
  return (
    <div className="min-h-screen bg-brand-dark flex">
      <aside className="w-64 flex-col border-r border-white/[0.06] bg-brand-dark-secondary hidden md:flex">
        <div className="p-6 border-b border-white/[0.06]">
          <Link href="/" className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-brand-gradient flex items-center justify-center"><Zap className="w-4 h-4 text-white" strokeWidth={2.5} /></div>
            <div><div className="font-display text-sm font-bold text-white">Nifelux</div><div className="text-[10px] text-red-400 font-semibold uppercase tracking-widest">Admin</div></div>
          </Link>
        </div>
        <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
          {nav.map(({ icon:I, label, href }) => (
            <Link key={href} href={href} className={cn("flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-medium transition-all", pathname.startsWith(href)?"bg-brand-blue/10 text-white border border-brand-blue/20":"text-text-secondary hover:text-white hover:bg-white/[0.04]")}>
              <I className="w-4 h-4" />{label}
            </Link>
          ))}
        </nav>
        <div className="p-4 border-t border-white/[0.06]">
          <div className="text-xs text-text-muted px-4 py-2">{user.email}</div>
          <button onClick={handleSignOut} className="flex items-center gap-3 px-4 py-2.5 w-full rounded-xl text-sm text-text-secondary hover:text-white hover:bg-white/[0.04] transition-all"><LogOut className="w-4 h-4" />Sign Out</button>
        </div>
      </aside>
      <div className="flex-1 flex flex-col min-w-0">
        <header className="h-16 border-b border-white/[0.06] bg-brand-dark-secondary/50 backdrop-blur-sm flex items-center justify-between px-6">
          <h1 className="font-display text-base font-bold text-white">{nav.find((n) => pathname.startsWith(n.href))?.label??"Admin"}</h1>
          <span className="badge-brand text-xs">Admin Panel</span>
        </header>
        <main className="flex-1 p-6 overflow-auto">{children}</main>
      </div>
    </div>
  );
}
EOF

cat > app/\(admin\)/admin/dashboard/page.tsx << 'EOF'
"use client";
import { Users, CreditCard, Award, DollarSign, TrendingUp, Activity } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import { StaggerContainer, StaggerItem } from "@/components/common/AnimatedSection";
const stats = [
  { label:"Total Users", value:"—", icon:Users, color:"blue" },
  { label:"IDs Issued", value:"—", icon:CreditCard, color:"purple" },
  { label:"Certifications", value:"—", icon:Award, color:"green" },
  { label:"Contributions", value:"₦—", icon:DollarSign, color:"blue" },
];
export default function AdminDashboard() {
  return (
    <div className="max-w-6xl mx-auto space-y-8">
      <div><h2 className="font-display text-2xl font-bold text-white mb-1">Admin Overview</h2><p className="text-text-muted text-sm">Platform analytics and management hub.</p></div>
      <StaggerContainer className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {stats.map(({ label, value, icon:I, color }) => (
          <StaggerItem key={label}>
            <GlassCard className={`p-5 border ${color==="blue"?"border-brand-blue/20":color==="green"?"border-brand-green/20":"border-brand-purple/20"}`}>
              <div className={`w-9 h-9 rounded-xl flex items-center justify-center mb-4 ${color==="blue"?"bg-brand-blue/10 text-brand-blue-light":color==="green"?"bg-brand-green/10 text-brand-green":"bg-brand-purple/10 text-brand-purple-light"}`}><I className="w-4 h-4" /></div>
              <div className="font-display text-2xl font-bold text-white mb-1">{value}</div>
              <div className="text-xs text-text-muted">{label}</div>
            </GlassCard>
          </StaggerItem>
        ))}
      </StaggerContainer>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <GlassCard className="p-6 border border-white/[0.05]"><h3 className="font-display text-base font-bold text-white mb-4 flex items-center gap-2"><Activity className="w-4 h-4 text-brand-blue-light" />Recent Activity</h3><div className="text-center py-8 text-text-muted text-sm">Connect Supabase to load activity.</div></GlassCard>
        <GlassCard className="p-6 border border-white/[0.05]"><h3 className="font-display text-base font-bold text-white mb-4 flex items-center gap-2"><Users className="w-4 h-4 text-brand-purple-light" />Recent Users</h3><div className="text-center py-8 text-text-muted text-sm">Connect Supabase to load users.</div></GlassCard>
      </div>
    </div>
  );
}
EOF

for page in users id-management certifications payments analytics roles activity-logs; do
  TITLE=$(echo "$page" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
cat > "app/(admin)/admin/$page/page.tsx" << PEOF
export default function Page() {
  return (
    <div className="max-w-6xl mx-auto">
      <h2 className="font-display text-2xl font-bold text-white mb-6">${TITLE}</h2>
      <div className="glass-card p-12 border border-white/[0.05] text-center">
        <p className="text-text-muted text-sm">Connect Supabase to enable this module.</p>
      </div>
    </div>
  );
}
PEOF
done

echo "✅ Admin pages written"

# ============================================
# STEP 16: API ROUTES
# ============================================
echo "🔌 Writing API routes..."

cat > app/api/payments/route.ts << 'EOF'
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
EOF

cat > app/api/webhooks/route.ts << 'EOF'
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
EOF

cat > app/api/id/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import { generateIdNumber } from "@/utils/format";
import type { ApiResponse } from "@/types/api.types";
export async function GET(request: NextRequest) {
  const id = new URL(request.url).searchParams.get("id");
  if (!id) return NextResponse.json<ApiResponse<null>>({ success:false, error:"ID required" }, { status:400 });
  const supabase = await createAdminClient();
  const { data, error } = await supabase.from("digital_ids").select("*, users(full_name, email)").eq("id_number", id).single();
  if (error) return NextResponse.json<ApiResponse<null>>({ success:false, error:"Not found" }, { status:404 });
  return NextResponse.json<ApiResponse<typeof data>>({ success:true, data });
}
export async function POST(request: NextRequest) {
  try {
    const supabase = await createAdminClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return NextResponse.json<ApiResponse<null>>({ success:false, error:"Unauthorized" }, { status:401 });
    const { data: profile } = await supabase.from("users").select("role").eq("id", user.id).single();
    if (!profile || !["admin","super_admin"].includes(profile.role)) return NextResponse.json<ApiResponse<null>>({ success:false, error:"Forbidden" }, { status:403 });
    const { target_user_id } = await request.json();
    const id_number = generateIdNumber();
    const expires_at = new Date(Date.now() + 365*24*60*60*1000).toISOString();
    const { data, error } = await supabase.from("digital_ids").insert({ user_id:target_user_id, id_number, qr_code_url:"", expires_at, status:"active" }).select().single();
    if (error) throw error;
    return NextResponse.json<ApiResponse<typeof data>>({ success:true, data, message:"ID issued" });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success:false, error:"Failed to issue ID" }, { status:500 });
  }
}
EOF

cat > app/api/certifications/route.ts << 'EOF'
import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/server";
import { generateVerificationCode } from "@/utils/format";
import type { ApiResponse } from "@/types/api.types";
export async function GET(request: NextRequest) {
  const code = new URL(request.url).searchParams.get("code");
  if (!code) return NextResponse.json<ApiResponse<null>>({ success:false, error:"Code required" }, { status:400 });
  const supabase = await createAdminClient();
  const { data, error } = await supabase.from("certifications").select("*, users(full_name)").eq("verification_code", code).single();
  if (error) return NextResponse.json<ApiResponse<null>>({ success:false, error:"Not found" }, { status:404 });
  return NextResponse.json<ApiResponse<typeof data>>({ success:true, data });
}
export async function POST(request: NextRequest) {
  try {
    const supabase = await createAdminClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return NextResponse.json<ApiResponse<null>>({ success:false, error:"Unauthorized" }, { status:401 });
    const { data: profile } = await supabase.from("users").select("role").eq("id", user.id).single();
    if (!profile || !["admin","super_admin"].includes(profile.role)) return NextResponse.json<ApiResponse<null>>({ success:false, error:"Forbidden" }, { status:403 });
    const { target_user_id, title, description, issued_by, expires_at } = await request.json();
    const verification_code = generateVerificationCode();
    const { data, error } = await supabase.from("certifications").insert({ user_id:target_user_id, title, description, issued_by, verification_code, expires_at, status:"active", issued_at:new Date().toISOString() }).select().single();
    if (error) throw error;
    return NextResponse.json<ApiResponse<typeof data>>({ success:true, data, message:"Certificate issued" });
  } catch {
    return NextResponse.json<ApiResponse<null>>({ success:false, error:"Failed to issue certificate" }, { status:500 });
  }
}
EOF

cat > app/verify/\[token\]/page.tsx << 'EOF'
import { createAdminClient } from "@/lib/supabase/server";
import { Shield, CheckCircle, XCircle, AlertTriangle } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";
import GradientButton from "@/components/common/GradientButton";
import { formatDate } from "@/utils/format";
interface Props { params: Promise<{ token: string }>; }
export default async function VerifyPage({ params }: Props) {
  const { token } = await params;
  const supabase = await createAdminClient();
  const { data: id } = await supabase.from("digital_ids").select("*, users(full_name, email)").eq("id_number", token).single();
  const { data: cert } = !id ? await supabase.from("certifications").select("*, users(full_name)").eq("verification_code", token).single() : { data: null };
  const isValid = id?.status==="active" || cert?.status==="active";
  const isExpired = id?.status==="expired" || cert?.status==="expired";
  return (
    <div className="min-h-screen bg-brand-dark flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-hero-gradient" /><div className="absolute inset-0 dot-pattern opacity-20" />
      <div className="relative z-10 w-full max-w-lg">
        <GlassCard variant="gradient" className="p-8 border border-white/[0.06]">
          <div className="text-center mb-8">
            <div className={`w-16 h-16 rounded-2xl mx-auto flex items-center justify-center mb-4 ${isValid?"bg-brand-green/10":"bg-red-500/10"}`}>
              {isValid?<CheckCircle className="w-8 h-8 text-brand-green" />:isExpired?<AlertTriangle className="w-8 h-8 text-yellow-400" />:<XCircle className="w-8 h-8 text-red-400" />}
            </div>
            <h1 className="font-display text-2xl font-bold text-white mb-2">{isValid?"Verified ✓":isExpired?"Expired":"Not Found"}</h1>
            <p className="text-text-muted text-sm">{isValid?"This credential is authentic and valid.":"This credential could not be verified."}</p>
          </div>
          {(id||cert) && (
            <div className="space-y-3 mb-6">
              {id && <>
                <div className="flex justify-between text-sm"><span className="text-text-muted">Name</span><span className="text-white font-medium">{(id.users as { full_name:string })?.full_name}</span></div>
                <div className="flex justify-between text-sm"><span className="text-text-muted">ID Number</span><span className="text-white font-mono text-xs">{id.id_number}</span></div>
                <div className="flex justify-between text-sm"><span className="text-text-muted">Expires</span><span className="text-white text-xs">{formatDate(id.expires_at)}</span></div>
              </>}
              {cert && <>
                <div className="flex justify-between text-sm"><span className="text-text-muted">Recipient</span><span className="text-white font-medium">{(cert.users as { full_name:string })?.full_name}</span></div>
                <div className="flex justify-between text-sm"><span className="text-text-muted">Certificate</span><span className="text-white text-xs">{cert.title}</span></div>
                <div className="flex justify-between text-sm"><span className="text-text-muted">Issued</span><span className="text-white text-xs">{formatDate(cert.issued_at)}</span></div>
              </>}
              <div className="flex justify-between text-sm"><span className="text-text-muted">Issuer</span><span className="text-white font-medium">Nifelux Technologies</span></div>
            </div>
          )}
          <div className="flex items-center justify-center gap-2 text-xs text-text-muted pt-4 border-t border-white/[0.06] mb-4"><Shield className="w-3.5 h-3.5 text-brand-blue-light" />Verified by Nifelux Technologies</div>
          <div className="text-center"><GradientButton href="/" variant="outline" size="sm">Back to Nifelux</GradientButton></div>
        </GlassCard>
      </div>
    </div>
  );
}
EOF

echo "✅ API routes written"

# ============================================
# STEP 17: DATABASE MIGRATION
# ============================================
echo "🗄️  Writing database migration..."

cat > supabase/migrations/001_initial_schema.sql << 'EOF'
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user','staff','admin','super_admin')),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended','pending')),
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.digital_ids (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  id_number TEXT UNIQUE NOT NULL,
  qr_code_url TEXT,
  issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','expired','revoked')),
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.certifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  certificate_url TEXT,
  issued_by TEXT NOT NULL,
  issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  verification_code TEXT UNIQUE NOT NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','expired','revoked')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  reference TEXT UNIQUE NOT NULL,
  amount NUMERIC NOT NULL,
  currency TEXT NOT NULL DEFAULT 'NGN',
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','success','failed','refunded')),
  purpose TEXT NOT NULL,
  metadata JSONB,
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'info' CHECK (type IN ('info','success','warning','alert')),
  read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.activity_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  target_type TEXT,
  target_id UUID,
  metadata JSONB,
  ip_address TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_digital_ids_user ON public.digital_ids(user_id);
CREATE INDEX IF NOT EXISTS idx_digital_ids_number ON public.digital_ids(id_number);
CREATE INDEX IF NOT EXISTS idx_certifications_user ON public.certifications(user_id);
CREATE INDEX IF NOT EXISTS idx_certifications_code ON public.certifications(verification_code);
CREATE INDEX IF NOT EXISTS idx_payments_ref ON public.payments(reference);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id, read);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.digital_ids ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "own_profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "update_own_profile" ON public.users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "admin_all_users" ON public.users FOR ALL USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin','super_admin')));
CREATE POLICY "own_id" ON public.digital_ids FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "public_verify_id" ON public.digital_ids FOR SELECT USING (TRUE);
CREATE POLICY "admin_manage_ids" ON public.digital_ids FOR ALL USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin','super_admin')));
CREATE POLICY "own_certs" ON public.certifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "public_verify_certs" ON public.certifications FOR SELECT USING (TRUE);
CREATE POLICY "admin_manage_certs" ON public.certifications FOR ALL USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin','super_admin')));
CREATE POLICY "own_notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "update_own_notifications" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION public.handle_new_user() RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, role, status)
  VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'), 'user', 'active');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE OR REPLACE FUNCTION update_updated_at() RETURNS trigger AS $$ BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$ LANGUAGE plpgsql;
CREATE TRIGGER users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at();
EOF

echo "✅ Migration written"

# ============================================
# DONE
# ============================================
echo ""
echo "=================================================="
echo "✅ NIFELUX TECHNOLOGIES — SETUP COMPLETE"
echo "=================================================="
echo ""
echo "📋 What was created:"
echo "   ✓ 60+ directories"
echo "   ✓ Config: tailwind, tsconfig, next.config, middleware"
echo "   ✓ Styles: globals.css with full design system"
echo "   ✓ App: root layout with Syne + Geist fonts + SEO"
echo "   ✓ Lib: Supabase client/server/admin + Zod schemas"
echo "   ✓ Services: auth, user, id, certification, payment"
echo "   ✓ Hooks: useAuth, useUser"
echo "   ✓ Store: authStore, uiStore (Zustand)"
echo "   ✓ Types: user, api, database"
echo "   ✓ Utils: cn, format, validators"
echo "   ✓ Components: GlassCard, GradientButton, SectionHeading, AnimatedSection, Navbar, Footer"
echo "   ✓ Pages: Home, 7 public stubs, Login, Register, Dashboard, ID Card, Certifications, Admin"
echo "   ✓ API: /payments, /webhooks, /id, /certifications"
echo "   ✓ Verify: /verify/[token] — public QR verification"
echo "   ✓ DB: Full PostgreSQL migration with RLS policies"
echo ""
echo "📋 Next Steps:"
echo "   1. cp .env.example .env.local && fill in your keys"
echo "   2. npx supabase login"
echo "   3. npx supabase db push"
echo "   4. npm run dev"
echo "   5. Visit http://localhost:3000"
echo ""
echo "   To enable full public pages, copy the Phase 1"
echo "   output files into the matching page.tsx paths."
echo ""
echo "🌍 Built for Nifelux Technologies — Lagos, Nigeria"
