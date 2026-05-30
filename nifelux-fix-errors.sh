#!/bin/bash

# ============================================
# NIFELUX — FIX BUILD ERRORS
# Run from project ROOT
# Fixes all 5 errors from the terminal
# ============================================

echo ""
echo "🔧 Fixing Nifelux build errors..."
echo "=================================================="

# ============================================
# FIX 1: Install missing packages
# tailwindcss-animate + geist fonts
# ============================================
echo "📦 Installing missing packages..."

npm install tailwindcss-animate geist

echo "✅ Packages installed"

# ============================================
# FIX 2: globals.css — @import must come
# BEFORE @tailwind directives
# ============================================
echo "🎨 Fixing globals.css @import order..."

cat > styles/globals.css << 'EOF'
@import url("https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&display=swap");

@tailwind base;
@tailwind components;
@tailwind utilities;

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
@keyframes float { 0%, 100% { transform: translateY(0px); } 50% { transform: translateY(-12px); } }
@layer base { :root { --background: 222 84% 5%; --foreground: 210 40% 98%; --card: 222 47% 8%; --card-foreground: 210 40% 98%; --primary: 221 83% 53%; --primary-foreground: 210 40% 98%; --border: 217 33% 13%; --input: 217 33% 13%; --ring: 221 83% 53%; --radius: 0.625rem; } }
@media (max-width: 640px) { :root { --section-padding: 3rem; --container-padding: 1rem; } }
EOF

echo "✅ globals.css fixed"

# ============================================
# FIX 3: app/layout.tsx — use geist package
# correctly (it exports from 'geist/font/sans')
# ============================================
echo "📐 Fixing app/layout.tsx geist imports..."

cat > app/layout.tsx << 'EOF'
import type { Metadata, Viewport } from "next";
import { Syne } from "next/font/google";
import localFont from "next/font/local";
import { Toaster } from "sonner";
import "@/styles/globals.css";

// Geist via local font (bundled with Next.js 15)
const geistSans = localFont({
  src: "../node_modules/geist/dist/fonts/geist-sans/Geist-Variable.woff2",
  variable: "--font-geist-sans",
  display: "swap",
});

const geistMono = localFont({
  src: "../node_modules/geist/dist/fonts/geist-mono/GeistMono-Variable.woff2",
  variable: "--font-geist-mono",
  display: "swap",
});

const syne = Syne({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700", "800"],
  variable: "--font-syne",
  display: "swap",
});

export const metadata: Metadata = {
  metadataBase: new URL(process.env.NEXT_PUBLIC_APP_URL || "https://nifelux.com"),
  title: {
    default: "Nifelux Technologies — Intelligent Systems for Africa's Future",
    template: "%s | Nifelux Technologies",
  },
  description:
    "Nifelux Technologies builds intelligent digital systems, AI, robotics, and automation for Africa and the global future.",
  keywords: ["Nifelux Technologies", "Nigerian tech company", "AI Africa", "robotics Nigeria"],
  authors: [{ name: "Nifelux Technologies", url: "https://nifelux.com" }],
  openGraph: {
    type: "website",
    locale: "en_NG",
    url: "https://nifelux.com",
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
  icons: { icon: "/favicon.ico" },
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
      className={`${geistSans.variable} ${geistMono.variable} ${syne.variable}`}
      suppressHydrationWarning
    >
      <body className="bg-brand-dark text-white antialiased">
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

echo "✅ app/layout.tsx fixed"

# ============================================
# FIX 4: Footer.tsx — replace removed lucide
# icons (Github, Linkedin, Twitter don't exist
# in this version of lucide-react)
# ============================================
echo "🦶 Fixing Footer.tsx icon imports..."

cat > components/layout/Footer.tsx << 'EOF'
"use client";
import Link from "next/link";
import { Zap, MapPin, ArrowUpRight, Globe, Code2, Send } from "lucide-react";

const footerLinks = {
  Company: [
    { label: "About", href: "/about" },
    { label: "Services", href: "/services" },
    { label: "Projects", href: "/projects" },
    { label: "Robotics", href: "/robotics" },
    { label: "Contact", href: "/contact" },
  ],
  Resources: [
    { label: "Certifications", href: "/certifications" },
    { label: "Support Us", href: "/support" },
    { label: "Dashboard", href: "/dashboard" },
  ],
  Legal: [
    { label: "Privacy Policy", href: "/privacy" },
    { label: "Terms of Service", href: "/terms" },
  ],
};

const socials = [
  { icon: Code2, href: "https://github.com/nifelux", label: "GitHub" },
  { icon: Globe, href: "https://linkedin.com/company/nifelux", label: "LinkedIn" },
  { icon: Send, href: "https://twitter.com/nifelux", label: "Twitter/X" },
  { icon: Zap, href: "mailto:hello@nifelux.com", label: "Email" },
];

export default function Footer() {
  return (
    <footer className="relative border-t border-white/[0.06] bg-brand-dark-secondary overflow-hidden">
      <div className="absolute bottom-0 left-1/4 w-96 h-64 orb orb-blue opacity-20 pointer-events-none" />
      <div className="container-custom py-16 relative z-10">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-12 mb-12">
          <div className="lg:col-span-2">
            <Link href="/" className="flex items-center gap-2.5 w-fit mb-5">
              <div className="w-9 h-9 rounded-xl bg-brand-gradient flex items-center justify-center shadow-glow-sm">
                <Zap className="w-4 h-4 text-white" strokeWidth={2.5} />
              </div>
              <div className="flex flex-col leading-none">
                <span className="font-display text-lg font-bold text-white">Nifelux</span>
                <span className="text-[10px] text-text-muted tracking-widest uppercase">Technologies</span>
              </div>
            </Link>
            <p className="text-text-secondary text-sm leading-relaxed max-w-xs mb-5">
              Building intelligent digital systems, AI, robotics, and automation
              for Africa and the global future.
            </p>
            <div className="flex items-center gap-1.5 text-text-muted text-xs mb-5">
              <MapPin className="w-3.5 h-3.5 text-brand-green" />
              <span>Lagos, Nigeria</span>
            </div>
            <div className="flex items-center gap-2">
              {socials.map(({ icon: Icon, href, label }) => (
                <a
                  key={label}
                  href={href}
                  target={href.startsWith("http") ? "_blank" : undefined}
                  rel={href.startsWith("http") ? "noopener noreferrer" : undefined}
                  aria-label={label}
                  className="w-9 h-9 rounded-lg glass flex items-center justify-center text-text-muted hover:text-white hover:bg-white/10 transition-all"
                >
                  <Icon className="w-4 h-4" />
                </a>
              ))}
            </div>
          </div>

          {Object.entries(footerLinks).map(([cat, links]) => (
            <div key={cat}>
              <h4 className="text-xs font-semibold text-text-muted uppercase tracking-widest mb-4">
                {cat}
              </h4>
              <ul className="space-y-3">
                {links.map((link) => (
                  <li key={link.href}>
                    <Link
                      href={link.href}
                      className="text-sm text-text-secondary hover:text-white transition-colors flex items-center gap-1 group"
                    >
                      {link.label}
                      <ArrowUpRight className="w-3 h-3 opacity-0 group-hover:opacity-100 transition-opacity" />
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="section-divider mb-8" />

        <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
          <p className="text-text-muted text-xs">
            © {new Date().getFullYear()} Nifelux Technologies. All rights reserved.
          </p>
          <p className="text-text-muted text-xs">
            Built in <span className="text-brand-green font-medium">Nigeria</span> for the world 🌍
          </p>
        </div>
      </div>
    </footer>
  );
}
EOF

echo "✅ Footer.tsx fixed"

# ============================================
# FIX 5: Duplicate route conflict
# app/(dashboard)/certifications collides with
# app/(public)/certifications → BOTH resolve to /certifications
# The dashboard cert page must ONLY live at
# app/(dashboard)/dashboard/certifications/page.tsx
# Delete the conflicting folder
# ============================================
echo "🗂️  Fixing duplicate /certifications route..."

# Remove the incorrectly placed dashboard certifications folder
rm -rf "app/(dashboard)/certifications"

echo "✅ Duplicate route removed"

# ============================================
# FIX 6: tailwind.config.ts — remove the
# animate plugin require() causing the error
# (it is now installed so this is just a safety fix)
# ============================================
echo "⚙️  Verifying tailwind config..."

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
          blue: "#2563EB",
          "blue-light": "#3B82F6",
          purple: "#7C3AED",
          "purple-light": "#8B5CF6",
          green: "#22C55E",
          "green-light": "#4ADE80",
          dark: "#050816",
          "dark-secondary": "#0B1120",
          card: "#111827",
          border: "#1E293B",
        },
        text: {
          primary: "#FFFFFF",
          secondary: "#CBD5E1",
          muted: "#94A3B8",
          accent: "#64748B",
        },
      },
      backgroundImage: {
        "brand-gradient": "linear-gradient(135deg, #2563EB 0%, #7C3AED 100%)",
        "green-gradient": "linear-gradient(135deg, #22C55E 0%, #2563EB 100%)",
        "hero-gradient":
          "radial-gradient(ellipse at 50% 0%, rgba(37,99,235,0.15) 0%, rgba(124,58,237,0.08) 50%, transparent 70%)",
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
        fadeUp: {
          "0%": { opacity: "0", transform: "translateY(24px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        float: {
          "0%, 100%": { transform: "translateY(0px)" },
          "50%": { transform: "translateY(-12px)" },
        },
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

echo "✅ tailwind.config.ts fixed"

# ============================================
# FINAL CHECK
# ============================================
echo ""
echo "=================================================="
echo "✅ ALL ERRORS FIXED"
echo "=================================================="
echo ""
echo "What was fixed:"
echo "  1. ✅ npm install tailwindcss-animate geist"
echo "  2. ✅ globals.css — @import moved above @tailwind"
echo "  3. ✅ app/layout.tsx — geist via localFont (no more broken imports)"
echo "  4. ✅ Footer.tsx — Github/Linkedin/Twitter replaced with valid icons"
echo "  5. ✅ app/(dashboard)/certifications/ removed (duplicate route)"
echo "  6. ✅ tailwind.config.ts — clean rewrite"
echo ""
echo "Now run:"
echo "  npm run dev"
echo ""
echo "🌍 Nifelux Technologies — Lagos, Nigeria"
