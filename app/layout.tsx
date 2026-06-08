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
