#!/bin/bash

# Fix: app/(auth)/verify/page.tsx is empty — not a valid module
# This only breaks `npm run build`, not `npm run dev`

cat > "app/(auth)/verify/page.tsx" << 'EOF'
import { Metadata } from "next";
import Link from "next/link";
import { Mail, ArrowLeft } from "lucide-react";
import GlassCard from "@/components/common/GlassCard";

export const metadata: Metadata = { title: "Verify Email" };

export default function VerifyEmailPage() {
  return (
    <GlassCard variant="gradient" className="p-8 border border-white/[0.06] text-center">
      <div className="w-14 h-14 rounded-2xl bg-brand-blue/10 border border-brand-blue/20 flex items-center justify-center mx-auto mb-5">
        <Mail className="w-7 h-7 text-brand-blue-light" />
      </div>
      <h1 className="font-display text-xl font-bold text-white mb-2">Check Your Email</h1>
      <p className="text-text-muted text-sm leading-relaxed mb-6">
        We sent a verification link to your email address.
        Click the link to activate your Nifelux account.
      </p>
      <p className="text-text-muted text-xs mb-6">
        Didn&apos;t receive it? Check your spam folder or contact{" "}
        <a href="mailto:hello@nifelux.com" className="text-brand-blue-light hover:text-white transition-colors">
          hello@nifelux.com
        </a>
      </p>
      <Link
        href="/login"
        className="inline-flex items-center gap-1.5 text-sm text-text-muted hover:text-white transition-colors"
      >
        <ArrowLeft className="w-3.5 h-3.5" /> Back to sign in
      </Link>
    </GlassCard>
  );
}
EOF

echo "✅ app/(auth)/verify/page.tsx fixed"
echo ""
echo "Now run: npm run build"
