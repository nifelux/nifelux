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
