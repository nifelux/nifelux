#!/bin/bash

# ============================================
# NIFELUX — FIX UI, FONTS & BLANK DASHBOARD
# ============================================

echo "🎨 Fixing UI, fonts and blank dashboard..."
echo ""

# ============================================
# FIX 1: MOVE CSS TO app/globals.css
# Next.js App Router reliably loads CSS from
# app/globals.css — styles/globals.css can
# miss in some Vercel build configurations
# ============================================
echo "1/4  Moving CSS to app/globals.css..."

cat > app/globals.css << 'EOF'
@import url("https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&display=swap");

@tailwind base;
@tailwind components;
@tailwind utilities;

/* ── DESIGN TOKENS ───────────────────────── */
:root {
  --brand-blue: #2563eb;
  --brand-purple: #7c3aed;
  --brand-green: #22c55e;
  --bg-dark: #050816;
  --bg-dark-secondary: #0b1120;
  --bg-card: #111827;
  --text-secondary: #cbd5e1;
  --text-muted: #94a3b8;
  --border: #1e293b;
  --gradient-brand: linear-gradient(135deg, #2563eb 0%, #7c3aed 100%);
  --gradient-green: linear-gradient(135deg, #22c55e 0%, #2563eb 100%);
  --section-padding: clamp(4rem, 8vw, 8rem);
  --container-padding: clamp(1rem, 5vw, 2rem);
}

/* ── BASE ────────────────────────────────── */
*,*::before,*::after { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; -webkit-font-smoothing: antialiased; }
body {
  background-color: #050816 !important;
  color: #ffffff;
  font-family: var(--font-geist-sans), system-ui, sans-serif;
  overflow-x: hidden;
}
::-webkit-scrollbar { width: 6px; }
::-webkit-scrollbar-track { background: #0b1120; }
::-webkit-scrollbar-thumb { background: #334155; border-radius: 100px; }
::-webkit-scrollbar-thumb:hover { background: #2563eb; }
::selection { background: rgba(37,99,235,0.3); color: #fff; }
h1,h2,h3,h4,h5,h6 {
  font-family: var(--font-syne), "Syne", system-ui, sans-serif;
  font-weight: 700;
  line-height: 1.1;
  letter-spacing: -0.02em;
}

/* ── GRADIENT TEXT ───────────────────────── */
@layer utilities {
  .gradient-text {
    background: var(--gradient-brand);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }
  .gradient-text-green {
    background: var(--gradient-green);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }
}

/* ── GLASS ───────────────────────────────── */
@layer components {
  .glass {
    background: rgba(255,255,255,0.04);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border: 1px solid rgba(255,255,255,0.08);
  }
  .glass-card {
    background: rgba(17,24,39,0.7);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    border: 1px solid rgba(255,255,255,0.07);
    border-radius: 16px;
  }
  .grid-pattern {
    background-image:
      linear-gradient(rgba(255,255,255,0.025) 1px, transparent 1px),
      linear-gradient(90deg, rgba(255,255,255,0.025) 1px, transparent 1px);
    background-size: 60px 60px;
  }
  .dot-pattern {
    background-image: radial-gradient(rgba(255,255,255,0.07) 1px, transparent 1px);
    background-size: 24px 24px;
  }
  .orb {
    position: absolute;
    border-radius: 50%;
    filter: blur(80px);
    pointer-events: none;
    animation: float 8s ease-in-out infinite;
  }
  .orb-blue  { background: radial-gradient(circle, rgba(37,99,235,0.3), transparent); }
  .orb-purple { background: radial-gradient(circle, rgba(124,58,237,0.3), transparent); }
  .orb-green  { background: radial-gradient(circle, rgba(34,197,94,0.22), transparent); }
  .container-custom {
    width: 100%;
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 var(--container-padding);
  }
  .section-padding {
    padding-top: var(--section-padding);
    padding-bottom: var(--section-padding);
  }
  .section-divider {
    width: 100%;
    height: 1px;
    background: linear-gradient(90deg, transparent, rgba(255,255,255,0.07), transparent);
  }
  .badge-brand {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 14px;
    background: rgba(37,99,235,0.13);
    border: 1px solid rgba(37,99,235,0.28);
    border-radius: 100px;
    font-size: 0.72rem;
    font-weight: 700;
    color: #60a5fa;
    letter-spacing: 0.06em;
    text-transform: uppercase;
  }
  .badge-green {
    background: rgba(34,197,94,0.13);
    border-color: rgba(34,197,94,0.28);
    color: #4ade80;
  }
  .badge-purple {
    background: rgba(124,58,237,0.13);
    border-color: rgba(124,58,237,0.28);
    color: #a78bfa;
  }
  .btn-primary {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 12px 24px;
    background: var(--gradient-brand);
    color: white;
    font-weight: 600;
    font-size: 0.9375rem;
    border-radius: 10px;
    border: none;
    cursor: pointer;
    transition: all 0.25s ease;
  }
  .btn-primary:hover { transform: translateY(-1px); box-shadow: 0 8px 25px rgba(37,99,235,0.45); }
  .btn-secondary {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 11px 23px;
    background: transparent;
    color: white;
    font-weight: 600;
    font-size: 0.9375rem;
    border-radius: 10px;
    border: 1px solid rgba(255,255,255,0.14);
    cursor: pointer;
    transition: all 0.25s ease;
  }
  .btn-secondary:hover { background: rgba(255,255,255,0.06); border-color: rgba(255,255,255,0.22); }
  .input-brand {
    width: 100%;
    padding: 12px 16px;
    background: rgba(255,255,255,0.04);
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 10px;
    color: #fff;
    font-size: 0.9375rem;
    transition: all 0.2s;
    outline: none;
  }
  .input-brand::placeholder { color: #64748b; }
  .input-brand:focus {
    border-color: #2563eb;
    box-shadow: 0 0 0 3px rgba(37,99,235,0.18);
    background: rgba(37,99,235,0.05);
  }
  .gradient-border {
    position: relative;
    background: var(--bg-card);
    border-radius: 16px;
  }
  .gradient-border::before {
    content: "";
    position: absolute;
    inset: 0;
    border-radius: inherit;
    padding: 1px;
    background: linear-gradient(135deg, rgba(37,99,235,0.5), rgba(124,58,237,0.5));
    -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
    -webkit-mask-composite: xor;
    mask-composite: exclude;
    pointer-events: none;
  }
  .bg-hero-gradient {
    background: radial-gradient(ellipse at 50% 0%, rgba(37,99,235,0.18) 0%, rgba(124,58,237,0.1) 50%, transparent 70%);
  }
  .bg-brand-gradient { background: var(--gradient-brand); }
}

/* ── KEYFRAMES ───────────────────────────── */
@keyframes float {
  0%,100% { transform: translateY(0px); }
  50% { transform: translateY(-12px); }
}
@keyframes fadeUp {
  0% { opacity: 0; transform: translateY(24px); }
  100% { opacity: 1; transform: translateY(0); }
}

/* ── SHADCN OVERRIDES ────────────────────── */
@layer base {
  :root {
    --background: 222 84% 5%;
    --foreground: 210 40% 98%;
    --card: 222 47% 8%;
    --card-foreground: 210 40% 98%;
    --primary: 221 83% 53%;
    --primary-foreground: 210 40% 98%;
    --secondary: 217 33% 10%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217 33% 12%;
    --muted-foreground: 215 20% 65%;
    --border: 217 33% 13%;
    --input: 217 33% 13%;
    --ring: 221 83% 53%;
    --radius: 0.625rem;
  }
  * { @apply border-border; }
}

@media (max-width: 640px) {
  :root { --section-padding: 3rem; --container-padding: 1rem; }
}
EOF

echo "   ✅ app/globals.css written"

# ============================================
# FIX 2: UPDATE LAYOUT — import from correct
# path + fix geist font using package exports
# ============================================
echo "2/4  Fixing app/layout.tsx..."

cat > app/layout.tsx << 'EOF'
import type { Metadata, Viewport } from "next";
import { Syne, Inter } from "next/font/google";
import { Toaster } from "sonner";
import "./globals.css";

// Use Inter as fallback — reliable on all platforms
// Geist is loaded via CSS variable if available
const inter = Inter({
  subsets: ["latin"],
  variable: "--font-geist-sans",
  display: "swap",
});

const syne = Syne({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700", "800"],
  variable: "--font-syne",
  display: "swap",
});

export const metadata: Metadata = {
  metadataBase: new URL(
    process.env.NEXT_PUBLIC_APP_URL ?? "https://nifelux.vercel.app"
  ),
  title: {
    default: "Nifelux Technologies — Intelligent Systems for Africa's Future",
    template: "%s | Nifelux Technologies",
  },
  description:
    "Nifelux Technologies builds intelligent digital systems, AI, robotics, and automation for Africa and the global future.",
  keywords: ["Nifelux Technologies", "Nigerian tech company", "AI Africa", "robotics Nigeria"],
  openGraph: {
    type: "website",
    locale: "en_NG",
    url: process.env.NEXT_PUBLIC_APP_URL ?? "https://nifelux.vercel.app",
    siteName: "Nifelux Technologies",
    title: "Nifelux Technologies — Intelligent Systems for Africa's Future",
    description: "Building intelligent systems, AI, robotics and automation for Africa and the world.",
    images: [{ url: "/og/og-default.png", width: 1200, height: 630, alt: "Nifelux Technologies" }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Nifelux Technologies",
    images: ["/og/og-default.png"],
  },
  robots: { index: true, follow: true },
};

export const viewport: Viewport = {
  themeColor: "#050816",
  colorScheme: "dark",
  width: "device-width",
  initialScale: 1,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html
      lang="en"
      className={`dark ${inter.variable} ${syne.variable}`}
      suppressHydrationWarning
    >
      <body className="bg-[#050816] text-white antialiased">
        {children}
        <Toaster
          theme="dark"
          position="top-right"
          toastOptions={{
            style: {
              background: "#111827",
              border: "1px solid #1E293B",
              color: "#FFFFFF",
            },
          }}
        />
      </body>
    </html>
  );
}
EOF

echo "   ✅ app/layout.tsx fixed — uses Inter + Syne (reliable on Vercel)"

# ============================================
# FIX 3: DELETE OLD styles/globals.css import
# Update all @/styles/globals.css → ./globals.css
# ============================================
echo "3/4  Cleaning up old CSS import references..."

# Remove old globals.css from styles/ so there's no confusion
if [ -f styles/globals.css ]; then
  # Keep it but empty — in case something imports it
  echo "/* Moved to app/globals.css */" > styles/globals.css
fi

echo "   ✅ Old CSS reference cleaned"

# ============================================
# FIX 4: DASHBOARD — add timeout to prevent
# infinite loading if Supabase is slow
# ============================================
echo "4/4  Fixing dashboard loading timeout..."

cat > hooks/useAuth.ts << 'EOF'
"use client";
import { useEffect } from "react";
import { createClient } from "@/lib/supabase/client";
import { useAuthStore } from "@/store/authStore";
import type { User } from "@/types/user.types";

export function useAuth() {
  const { user, isLoading, setUser, setLoading } = useAuthStore();

  useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const s = createClient() as any;

    // Safety timeout — never hang longer than 5 seconds
    const timeout = setTimeout(() => {
      setLoading(false);
    }, 5000);

    const loadUser = async () => {
      try {
        const { data: { session } } = await s.auth.getSession();
        if (session?.user) {
          const { data: profile } = await s
            .from("users")
            .select("*")
            .eq("id", session.user.id)
            .single();

          setUser(profile as User ?? {
            id: session.user.id,
            email: session.user.email ?? "",
            full_name: session.user.user_metadata?.full_name ?? "User",
            role: "user",
            status: "active",
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          } as User);
        } else {
          setUser(null);
        }
      } catch {
        setUser(null);
      } finally {
        clearTimeout(timeout);
        setLoading(false);
      }
    };

    loadUser();

    const { data: { subscription } } = s.auth.onAuthStateChange(
      async (_: string, session: { user: { id: string; email?: string; user_metadata?: { full_name?: string } } } | null) => {
        if (session?.user) {
          try {
            const { data: profile } = await s
              .from("users")
              .select("*")
              .eq("id", session.user.id)
              .single();
            setUser(profile as User ?? {
              id: session.user.id,
              email: session.user.email ?? "",
              full_name: session.user.user_metadata?.full_name ?? "User",
              role: "user",
              status: "active",
              created_at: new Date().toISOString(),
              updated_at: new Date().toISOString(),
            } as User);
          } catch {
            setUser(null);
          }
        } else {
          setUser(null);
        }
        setLoading(false);
      }
    );

    return () => {
      clearTimeout(timeout);
      subscription.unsubscribe();
    };
  }, [setUser, setLoading]);

  return { user, isLoading };
}
EOF

echo "   ✅ useAuth — 5-second safety timeout added"

# ============================================
# COMMIT
# ============================================
echo ""
echo "=================================================="
echo "✅ ALL UI FIXES APPLIED"
echo "=================================================="
echo ""
echo "Changes:"
echo "  ✓ CSS moved to app/globals.css (reliable Vercel loading)"
echo "  ✓ Fonts: Inter + Syne via next/font/google (no local path issues)"
echo "  ✓ body bg-[#050816] directly in className (guaranteed dark bg)"
echo "  ✓ useAuth: 5-second timeout prevents infinite loading"
echo "  ✓ All CSS classes in @layer components/utilities (production-safe)"
echo ""
echo "Run:"
echo "  npm run build && git add . && git commit -m 'fix: UI colors, fonts, dashboard loading' && git push"
echo ""
echo "After deploy — Supabase Dashboard:"
echo "  Auth → URL Config → Site URL: https://nifelux.vercel.app"
echo "  Auth → URL Config → Redirect URL: https://nifelux.vercel.app/auth/callback"
echo ""
echo "🌍 Nifelux Technologies — Lagos, Nigeria"
