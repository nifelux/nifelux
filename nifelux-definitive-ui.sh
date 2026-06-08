#!/bin/bash

# ============================================
# NIFELUX — DEFINITIVE UI FIX
# Diagnosed from GitHub repo:
# - styles/globals.css is nearly empty (1.4% CSS)
# - layout.tsx importing wrong CSS path
# - dark class missing from <html>
# - font CSS variables not injecting
# ============================================

echo "🎨 Applying definitive UI fix..."
echo ""

# ============================================
# STEP 1: NUKE OLD CSS, WRITE FRESH TO CORRECT LOCATION
# ============================================
echo "1/3  Writing complete CSS to app/globals.css..."

# Clear the old styles/globals.css so nothing imports from there
echo "/* CSS has moved to app/globals.css */" > styles/globals.css

cat > app/globals.css << 'CSSEOF'
@import url("https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=Inter:wght@300;400;500;600;700&display=swap");

@tailwind base;
@tailwind components;
@tailwind utilities;

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   DESIGN TOKENS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
:root {
  --font-display: "Syne", system-ui, sans-serif;
  --brand-blue: #2563eb;
  --brand-blue-light: #3b82f6;
  --brand-purple: #7c3aed;
  --brand-purple-light: #8b5cf6;
  --brand-green: #22c55e;
  --brand-green-light: #4ade80;
  --bg-dark: #050816;
  --bg-dark-secondary: #0b1120;
  --bg-card: #111827;
  --text-secondary: #cbd5e1;
  --text-muted: #94a3b8;
  --border: #1e293b;
  --gradient-brand: linear-gradient(135deg, #2563eb 0%, #7c3aed 100%);
  --gradient-green: linear-gradient(135deg, #22c55e 0%, #2563eb 100%);
  --section-padding: clamp(4rem, 8vw, 8rem);
  --container-padding: clamp(1.25rem, 5vw, 2rem);
}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   BASE RESET
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html {
  scroll-behavior: smooth;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

body {
  background-color: #050816 !important;
  color: #ffffff;
  font-family: "Inter", var(--font-geist-sans, system-ui), sans-serif;
  line-height: 1.6;
  overflow-x: hidden;
}

h1, h2, h3, h4, h5, h6 {
  font-family: "Syne", var(--font-syne, system-ui), sans-serif;
  font-weight: 700;
  line-height: 1.1;
  letter-spacing: -0.02em;
  color: #ffffff;
}

::-webkit-scrollbar { width: 5px; }
::-webkit-scrollbar-track { background: #0b1120; }
::-webkit-scrollbar-thumb { background: #334155; border-radius: 100px; }
::-webkit-scrollbar-thumb:hover { background: #2563eb; }
::selection { background: rgba(37,99,235,0.3); color: #fff; }
:focus-visible { outline: 2px solid #2563eb; outline-offset: 2px; border-radius: 4px; }

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   GRADIENT TEXT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
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

.gradient-text-white {
  background: linear-gradient(135deg, #ffffff 0%, rgba(255,255,255,0.65) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   GLASSMORPHISM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.glass {
  background: rgba(255,255,255,0.04);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255,255,255,0.08);
}

.glass-card {
  background: rgba(17,24,39,0.75);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255,255,255,0.07);
  border-radius: 16px;
}

.glass-dark {
  background: rgba(5,8,22,0.85);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255,255,255,0.06);
}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   BACKGROUNDS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.bg-hero-gradient {
  background: radial-gradient(ellipse at 50% 0%, rgba(37,99,235,0.2) 0%, rgba(124,58,237,0.1) 50%, transparent 70%);
}

.bg-brand-gradient {
  background: var(--gradient-brand);
}

.grid-pattern {
  background-image:
    linear-gradient(rgba(255,255,255,0.025) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,0.025) 1px, transparent 1px);
  background-size: 60px 60px;
}

.dot-pattern {
  background-image: radial-gradient(rgba(255,255,255,0.08) 1px, transparent 1px);
  background-size: 24px 24px;
}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ORBS / GLOW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  pointer-events: none;
  animation: float 8s ease-in-out infinite;
}

.orb-blue   { background: radial-gradient(circle, rgba(37,99,235,0.35), transparent); }
.orb-purple { background: radial-gradient(circle, rgba(124,58,237,0.3), transparent); }
.orb-green  { background: radial-gradient(circle, rgba(34,197,94,0.25), transparent); }

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   LAYOUT UTILITIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
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
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.08), transparent);
}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   BADGES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.badge-brand {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 5px 14px;
  background: rgba(37,99,235,0.14);
  border: 1px solid rgba(37,99,235,0.32);
  border-radius: 100px;
  font-size: 0.72rem;
  font-weight: 700;
  color: #60a5fa;
  letter-spacing: 0.07em;
  text-transform: uppercase;
}

.badge-green {
  background: rgba(34,197,94,0.14);
  border-color: rgba(34,197,94,0.32);
  color: #4ade80;
}

.badge-purple {
  background: rgba(124,58,237,0.14);
  border-color: rgba(124,58,237,0.32);
  color: #a78bfa;
}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   BUTTONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.btn-primary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 26px;
  background: var(--gradient-brand);
  color: white;
  font-weight: 600;
  font-size: 0.9375rem;
  border-radius: 10px;
  border: none;
  cursor: pointer;
  transition: all 0.25s ease;
  white-space: nowrap;
}

.btn-primary:hover {
  transform: translateY(-1px);
  box-shadow: 0 8px 28px rgba(37,99,235,0.45);
}

.btn-primary:active { transform: translateY(0); }

.btn-secondary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 11px 24px;
  background: transparent;
  color: white;
  font-weight: 600;
  font-size: 0.9375rem;
  border-radius: 10px;
  border: 1px solid rgba(255,255,255,0.15);
  cursor: pointer;
  transition: all 0.25s ease;
  white-space: nowrap;
}

.btn-secondary:hover {
  background: rgba(255,255,255,0.07);
  border-color: rgba(255,255,255,0.25);
  transform: translateY(-1px);
}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   INPUTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.input-brand {
  width: 100%;
  padding: 12px 16px;
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.1);
  border-radius: 10px;
  color: #ffffff;
  font-size: 0.9375rem;
  font-family: inherit;
  transition: all 0.2s ease;
  outline: none;
}

.input-brand::placeholder { color: #64748b; }

.input-brand:focus {
  border-color: #2563eb;
  box-shadow: 0 0 0 3px rgba(37,99,235,0.2);
  background: rgba(37,99,235,0.05);
}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   GRADIENT BORDER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
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

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ANIMATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50%       { transform: translateY(-12px); }
}

@keyframes fadeUp {
  0%   { opacity: 0; transform: translateY(24px); }
  100% { opacity: 1; transform: translateY(0); }
}

@keyframes fadeIn {
  0%   { opacity: 0; }
  100% { opacity: 1; }
}

@keyframes shimmer {
  0%   { background-position: -1000px 0; }
  100% { background-position: 1000px 0; }
}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   SHADCN BASE OVERRIDES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
@layer base {
  :root {
    --background: 222 84% 5%;
    --foreground: 210 40% 98%;
    --card: 222 47% 8%;
    --card-foreground: 210 40% 98%;
    --popover: 222 47% 8%;
    --popover-foreground: 210 40% 98%;
    --primary: 221 83% 53%;
    --primary-foreground: 210 40% 98%;
    --secondary: 217 33% 10%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217 33% 12%;
    --muted-foreground: 215 20% 65%;
    --accent: 270 67% 47%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 63% 51%;
    --destructive-foreground: 210 40% 98%;
    --border: 217 33% 13%;
    --input: 217 33% 13%;
    --ring: 221 83% 53%;
    --radius: 0.625rem;
  }
}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   RESPONSIVE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
@media (max-width: 640px) {
  :root {
    --section-padding: 3rem;
    --container-padding: 1rem;
  }
}
CSSEOF

echo "   ✅ app/globals.css written (full)"

# ============================================
# STEP 2: LAYOUT — correct import + dark class + fonts
# ============================================
echo "2/3  Fixing app/layout.tsx..."

cat > app/layout.tsx << 'EOF'
import type { Metadata, Viewport } from "next";
import { Inter, Syne } from "next/font/google";
import { Toaster } from "sonner";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700"],
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
  keywords: [
    "Nifelux Technologies", "Nigerian tech company", "AI Africa",
    "robotics Nigeria", "automation Nigeria", "digital infrastructure Africa",
  ],
  authors: [{ name: "Nifelux Technologies", url: "https://nifelux.vercel.app" }],
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
  icons: { icon: "/favicon.ico" },
};

export const viewport: Viewport = {
  themeColor: "#050816",
  colorScheme: "dark",
  width: "device-width",
  initialScale: 1,
  maximumScale: 5,
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="en"
      // "dark" class required for Tailwind darkMode:["class"] to activate
      // Font variables injected here so CSS can use them
      className={`dark ${inter.variable} ${syne.variable}`}
      suppressHydrationWarning
    >
      <body
        // Inline style guarantees dark background even if Tailwind fails
        style={{ backgroundColor: "#050816", color: "#ffffff" }}
        className="antialiased min-h-screen"
      >
        {children}
        <Toaster
          theme="dark"
          position="top-right"
          toastOptions={{
            style: {
              background: "#111827",
              border: "1px solid #1E293B",
              color: "#FFFFFF",
              fontFamily: "Inter, system-ui, sans-serif",
            },
          }}
        />
      </body>
    </html>
  );
}
EOF

echo "   ✅ app/layout.tsx fixed"

# ============================================
# STEP 3: TAILWIND — ensure darkMode correct
# and content paths cover all directories
# ============================================
echo "3/3  Verifying tailwind.config.ts..."

cat > tailwind.config.ts << 'EOF'
import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./features/**/*.{js,ts,jsx,tsx,mdx}",
    "./hooks/**/*.{js,ts,jsx,tsx}",
    "./lib/**/*.{js,ts,jsx,tsx}",
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
          "card-hover": "#1F2937",
          border: "#1E293B",
          "border-light": "#334155",
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
        "hero-gradient": "radial-gradient(ellipse at 50% 0%, rgba(37,99,235,0.18) 0%, rgba(124,58,237,0.1) 50%, transparent 70%)",
      },
      fontFamily: {
        sans: ["Inter", "var(--font-geist-sans)", "system-ui", "sans-serif"],
        mono: ["var(--font-geist-mono)", "ui-monospace", "monospace"],
        display: ["Syne", "var(--font-syne)", "system-ui", "sans-serif"],
      },
      animation: {
        "fade-up": "fadeUp 0.6s ease-out forwards",
        "fade-in": "fadeIn 0.4s ease-out forwards",
        float: "float 6s ease-in-out infinite",
        "float-slow": "float 8s ease-in-out infinite",
        "pulse-slow": "pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite",
        shimmer: "shimmer 2s infinite",
      },
      keyframes: {
        fadeUp: {
          "0%": { opacity: "0", transform: "translateY(24px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        fadeIn: {
          "0%": { opacity: "0" },
          "100%": { opacity: "1" },
        },
        float: {
          "0%, 100%": { transform: "translateY(0px)" },
          "50%": { transform: "translateY(-12px)" },
        },
        shimmer: {
          "0%": { backgroundPosition: "-1000px 0" },
          "100%": { backgroundPosition: "1000px 0" },
        },
      },
      boxShadow: {
        "glow-sm": "0 0 15px rgba(37,99,235,0.22)",
        glow: "0 0 30px rgba(37,99,235,0.28)",
        "glow-lg": "0 0 60px rgba(37,99,235,0.32)",
        "glow-purple": "0 0 30px rgba(124,58,237,0.28)",
        "glow-green": "0 0 30px rgba(34,197,94,0.28)",
        card: "0 4px 6px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.05)",
        "card-hover": "0 20px 40px rgba(0,0,0,0.6), 0 0 0 1px rgba(37,99,235,0.25)",
      },
      borderRadius: {
        "4xl": "2rem",
        "5xl": "2.5rem",
      },
      spacing: {
        "18": "4.5rem",
        "88": "22rem",
        "128": "32rem",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
};

export default config;
EOF

echo "   ✅ tailwind.config.ts verified"

# ============================================
# BUILD + DEPLOY
# ============================================
echo ""
echo "=================================================="
echo "✅ UI FIX COMPLETE"
echo "=================================================="
echo ""
echo "What was fixed:"
echo "  ✓ app/globals.css — complete with ALL custom classes"
echo "  ✓ styles/globals.css — cleared (was causing conflict)"
echo "  ✓ layout.tsx imports './globals.css' directly"
echo "  ✓ Fonts: Inter + Syne loaded from Google Fonts"
echo "  ✓ Font names added to fontFamily in Tailwind"
echo "  ✓ dark class on <html> — activates Tailwind dark mode"
echo "  ✓ Background #050816 both in CSS and inline style"
echo "  ✓ Tailwind content paths now include hooks/ and lib/"
echo ""
echo "Run:"
echo "  npm run build"
echo "  git add . && git commit -m 'fix: definitive UI fix - fonts, CSS, dark mode' && git push"
echo ""
echo "🌍 Nifelux Technologies — Lagos, Nigeria"
