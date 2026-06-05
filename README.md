# Nifelux Technologies Platform

> Intelligent Systems for Africa's Future

Built by **Oluwanifemi Abdullahi Olude** — Lagos, Nigeria.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Next.js 15, TypeScript, Tailwind CSS, Framer Motion |
| UI Components | Shadcn UI + Custom Nifelux Design System |
| Backend | Supabase (PostgreSQL + Auth + Storage + Realtime) |
| Payments | iPayNG |
| Email | Resend |
| Deployment | Vercel |
| State | Zustand |
| Forms | React Hook Form + Zod |

---

## Project Structure

```
nifelux/
├── app/                    # Next.js App Router
│   ├── (public)/           # Public marketing pages
│   ├── (auth)/             # Login, register, reset
│   ├── (dashboard)/        # User portal
│   ├── (admin)/            # Admin panel
│   ├── api/                # API routes
│   └── verify/[token]/     # Public QR verification
├── components/             # Shared UI components
├── features/               # Domain feature modules
├── lib/                    # External service clients
├── services/               # Business logic
├── hooks/                  # React hooks
├── store/                  # Zustand state
├── types/                  # TypeScript types
├── utils/                  # Helper functions
└── supabase/               # DB migrations
```

---

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/nifelux/nifelux-platform.git
cd nifelux-platform

# 2. Install dependencies
npm install

# 3. Set environment variables
cp .env.example .env.local
# Fill in .env.local with your real keys

# 4. Apply database migrations
npx supabase login
npx supabase link --project-ref YOUR_PROJECT_ID
npx supabase db push

# 5. Start dev server
npm run dev
```

---

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `NEXT_PUBLIC_APP_URL` | ✅ | Your app URL |
| `NEXT_PUBLIC_SUPABASE_URL` | ✅ | Supabase project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | ✅ | Supabase anon key |
| `SUPABASE_SERVICE_ROLE_KEY` | ✅ | Supabase service key (server only) |
| `IPAYNG_SECRET_KEY` | ✅ | iPayNG secret (server only) |
| `IPAYNG_PUBLIC_KEY` | ✅ | iPayNG public key |
| `IPAYNG_WEBHOOK_SECRET` | ✅ | iPayNG webhook secret (server only) |
| `RESEND_API_KEY` | ✅ | Resend email API key (server only) |
| `QR_JWT_SECRET` | ✅ | Random secret min 32 chars (server only) |

---

## Supabase Setup

1. Create project at [supabase.com](https://supabase.com)
2. Run migrations: `npx supabase db push`
3. Enable Realtime on `notifications` table:
   - Dashboard → Database → Replication → Enable on `notifications`
4. Configure email templates in Auth settings
5. Add your domain to Auth → URL Configuration

---

## iPayNG Setup

1. Create account at [ipayng.com](https://ipayng.com)
2. Get API keys from Dashboard → API Keys
3. Set webhook URL in iPayNG dashboard:
   `https://nifelux.com/api/webhooks`
4. Copy webhook secret to `.env.local`

---

## Deployment (Vercel)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Set environment variables in Vercel dashboard
# Project → Settings → Environment Variables
# Add all variables from .env.example

# Production deploy
vercel --prod
```

---

## Pages

| Route | Description |
|---|---|
| `/` | Home |
| `/about` | Company info + founder |
| `/services` | All 6 service areas |
| `/robotics` | Robotics division |
| `/projects` | Portfolio |
| `/certifications` | Certificate verification |
| `/support` | Contributions via iPayNG |
| `/contact` | Contact form |
| `/login` | Sign in |
| `/register` | Sign up |
| `/dashboard` | User portal |
| `/id-card` | Digital ID card |
| `/verify/[token]` | Public QR verification |
| `/admin/dashboard` | Admin overview |
| `/admin/users` | User management |
| `/admin/id-management` | Issue/revoke IDs |
| `/admin/certifications` | Issue/revoke certs |
| `/admin/payments` | Payment history |
| `/admin/analytics` | Platform analytics |
| `/admin/notifications` | Broadcast notifications |
| `/admin/activity-logs` | Audit trail |
| `/admin/roles` | Role management |

---

## License

© 2025 Nifelux Technologies. All rights reserved.

Built in **Nigeria** 🇳🇬 for the world 🌍
