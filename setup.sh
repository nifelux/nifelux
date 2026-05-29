#!/bin/bash

# ============================================
# NIFELUX TECHNOLOGIES — PROJECT SETUP SCRIPT
# Run this from the ROOT of your Next.js project
# ============================================

echo "🚀 Setting up Nifelux Technologies project structure..."

# ============================================
# CREATE ALL DIRECTORIES
# ============================================

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

mkdir -p app/api/auth
mkdir -p app/api/users
mkdir -p app/api/certifications
mkdir -p app/api/payments
mkdir -p app/api/id
mkdir -p app/api/qr
mkdir -p app/api/notifications
mkdir -p app/api/webhooks

mkdir -p components/ui
mkdir -p components/layout
mkdir -p components/common
mkdir -p components/seo

mkdir -p features/auth/components
mkdir -p features/auth/hooks
mkdir -p features/auth/services
mkdir -p features/auth/types
mkdir -p features/digital-id/components
mkdir -p features/digital-id/hooks
mkdir -p features/digital-id/services
mkdir -p features/digital-id/types
mkdir -p features/certifications/components
mkdir -p features/certifications/hooks
mkdir -p features/certifications/services
mkdir -p features/certifications/types
mkdir -p features/payments/components
mkdir -p features/payments/hooks
mkdir -p features/payments/services
mkdir -p features/payments/types
mkdir -p features/admin/components
mkdir -p features/admin/hooks
mkdir -p features/admin/services
mkdir -p features/admin/types
mkdir -p features/qr-verification/components
mkdir -p features/qr-verification/services
mkdir -p features/notifications/components
mkdir -p features/notifications/services

mkdir -p lib/supabase
mkdir -p lib/ipayng
mkdir -p lib/qr
mkdir -p lib/validations

mkdir -p services
mkdir -p hooks
mkdir -p store
mkdir -p types
mkdir -p utils
mkdir -p styles
mkdir -p middleware

mkdir -p public/assets/images
mkdir -p public/assets/icons
mkdir -p public/assets/logos
mkdir -p public/og
mkdir -p public/icons
mkdir -p public/fonts

mkdir -p supabase/migrations
mkdir -p supabase/functions

# ============================================
# CREATE PLACEHOLDER FILES
# ============================================

# --- Pages ---
touch app/\(public\)/about/page.tsx
touch app/\(public\)/services/page.tsx
touch app/\(public\)/robotics/page.tsx
touch app/\(public\)/projects/page.tsx
touch app/\(public\)/certifications/page.tsx
touch app/\(public\)/support/page.tsx
touch app/\(public\)/contact/page.tsx

# --- Auth Pages ---
touch app/\(auth\)/login/page.tsx
touch app/\(auth\)/register/page.tsx
touch app/\(auth\)/verify/page.tsx
touch app/\(auth\)/layout.tsx

# --- Dashboard Pages ---
touch app/\(dashboard\)/dashboard/page.tsx
touch app/\(dashboard\)/id-card/page.tsx
touch app/\(dashboard\)/certifications/page.tsx
touch app/\(dashboard\)/layout.tsx

# --- Admin Pages ---
touch app/\(admin\)/admin/dashboard/page.tsx
touch app/\(admin\)/admin/users/page.tsx
touch app/\(admin\)/admin/certifications/page.tsx
touch app/\(admin\)/admin/id-management/page.tsx
touch app/\(admin\)/admin/payments/page.tsx
touch app/\(admin\)/admin/analytics/page.tsx
touch app/\(admin\)/admin/roles/page.tsx
touch app/\(admin\)/admin/activity-logs/page.tsx
touch app/\(admin\)/layout.tsx

# --- API Routes ---
touch app/api/auth/route.ts
touch app/api/users/route.ts
touch app/api/certifications/route.ts
touch app/api/payments/route.ts
touch app/api/id/route.ts
touch app/api/qr/route.ts
touch app/api/notifications/route.ts
touch app/api/webhooks/route.ts

# --- Layout Components ---
touch components/layout/Navbar.tsx
touch components/layout/Footer.tsx
touch components/layout/Sidebar.tsx
touch components/layout/MobileNav.tsx

# --- Common Components ---
touch components/common/GlassCard.tsx
touch components/common/GradientButton.tsx
touch components/common/SectionHeading.tsx
touch components/common/AnimatedSection.tsx
touch components/common/LoadingSpinner.tsx
touch components/common/PageWrapper.tsx

# --- SEO ---
touch components/seo/MetaTags.tsx

# --- Lib ---
touch lib/supabase/client.ts
touch lib/supabase/server.ts
touch lib/supabase/middleware.ts
touch lib/ipayng/client.ts
touch lib/qr/generator.ts
touch lib/validations/auth.schema.ts
touch lib/validations/payment.schema.ts
touch lib/validations/id.schema.ts

# --- Services ---
touch services/auth.service.ts
touch services/user.service.ts
touch services/id.service.ts
touch services/certification.service.ts
touch services/payment.service.ts
touch services/notification.service.ts
touch services/qr.service.ts
touch services/admin.service.ts

# --- Hooks ---
touch hooks/useAuth.ts
touch hooks/useUser.ts
touch hooks/usePayment.ts
touch hooks/useCertification.ts
touch hooks/useNotification.ts

# --- Store ---
touch store/authStore.ts
touch store/uiStore.ts
touch store/notificationStore.ts

# --- Types ---
touch types/database.types.ts
touch types/api.types.ts
touch types/user.types.ts
touch types/payment.types.ts
touch types/id.types.ts

# --- Utils ---
touch utils/cn.ts
touch utils/format.ts
touch utils/security.ts
touch utils/validators.ts

# --- Styles ---
touch styles/globals.css

# --- Middleware ---
touch middleware/index.ts

# --- Supabase ---
touch supabase/migrations/.gitkeep
touch supabase/functions/.gitkeep

# --- Env ---
touch .env.local
touch .env.example

# ============================================
# WRITE .env.example
# ============================================

cat > .env.example << 'EOF'
# ============================================
# NIFELUX TECHNOLOGIES — ENVIRONMENT VARIABLES
# Copy this to .env.local and fill in values
# NEVER commit .env.local to version control
# ============================================

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000

# Supabase (public)
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key

# Supabase (server only - never expose to client)
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# iPayNG (server only)
IPAYNG_SECRET_KEY=your_ipayng_secret_key
IPAYNG_PUBLIC_KEY=your_ipayng_public_key
IPAYNG_WEBHOOK_SECRET=your_ipayng_webhook_secret

# Email - Resend (server only)
RESEND_API_KEY=your_resend_api_key

# QR Signing (server only)
QR_JWT_SECRET=your_random_secret_min_32_chars

# Admin
ADMIN_EMAIL=admin@nifelux.com
EOF

# ============================================
# WRITE next.config.ts
# ============================================

cat > next.config.ts << 'EOF'
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "*.supabase.co",
        pathname: "/storage/v1/object/public/**",
      },
    ],
  },
  async headers() {
    return [
      {
        source: "/(.*)",
        headers: [
          { key: "X-Frame-Options", value: "DENY" },
          { key: "X-Content-Type-Options", value: "nosniff" },
          { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
          { key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=()" },
        ],
      },
    ];
  },
};

export default nextConfig;
EOF

# ============================================
# WRITE middleware
# ============================================

cat > middleware/index.ts << 'EOF'
// Nifelux Route Protection Middleware
// Phase 2 will wire this to Supabase session checks
export {};
EOF

cat > middleware.ts << 'EOF'
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

// Protected route prefixes
const DASHBOARD_PREFIX = "/dashboard";
const ADMIN_PREFIX = "/admin";

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // TODO Phase 2: Add Supabase session validation here
  // For now, allow all routes through
  if (pathname.startsWith(DASHBOARD_PREFIX) || pathname.startsWith(ADMIN_PREFIX)) {
    // Will redirect to /login if no valid session
    // return NextResponse.redirect(new URL("/login", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|icons|assets|og).*)",
  ],
};
EOF

# ============================================
# UPDATE .gitignore
# ============================================

cat >> .gitignore << 'EOF'

# Nifelux
.env.local
.env.*.local
supabase/.temp
EOF

# ============================================
# DONE
# ============================================

echo ""
echo "✅ Nifelux project structure created successfully!"
echo ""
echo "📁 Folders created: 60+"
echo "📄 Files created: 70+"
echo ""
echo "NEXT STEPS:"
echo "1. Copy your Phase 1 component files into the project root"
echo "2. Fill in .env.local with your actual keys"
echo "3. Run: npm run dev"
echo ""
echo "Built for Nifelux Technologies 🌍"
