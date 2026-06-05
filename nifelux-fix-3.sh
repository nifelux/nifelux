#!/bin/bash

# ============================================
# NIFELUX — FIX FINAL 3 ERRORS
# ============================================

echo "🔧 Fixing last 3 TypeScript errors..."
echo ""

# ============================================
# FIX 1 & 2: support/page.tsx
# Problem 1: zodResolver type mismatch —
#   z.boolean().default(false) creates different
#   input vs output types, confusing zodResolver
# Problem 2: onSubmit not matching SubmitHandler
# Fix: remove .default() from schema, keep
#   default in useForm defaultValues only
#   + cast onSubmit explicitly
# ============================================
echo "1/2  Fixing support page form types..."

# Patch the schema — remove .default(false) from anonymous field
sed -i 's/anonymous: z\.boolean()\.default(false)/anonymous: z.boolean().optional()/g' "app/(public)/support/page.tsx"

# Patch the onSubmit signature to include explicit type cast
# Change:  const onSubmit = async (data: Form): Promise<void> => {
# To:      const onSubmit: SubmitHandler<Form> = async (data) => {
sed -i 's/const onSubmit = async (data: Form): Promise<void> => {/const onSubmit: import("react-hook-form").SubmitHandler<Form> = async (data) => {/g' "app/(public)/support/page.tsx"

# Verify anonymous field default is still in defaultValues (it already is from our rewrite)
# The form has: defaultValues: { anonymous: false }  — this is fine

echo "   ✅ Support page form fixed"

# ============================================
# FIX 3: payments/route.ts
# Problem: parsed.error.errors doesn't exist
#   in Zod v3 — it's parsed.error.issues
# Fix: replace .errors[0] with .issues[0]
# ============================================
echo "2/2  Fixing payments route Zod error..."

sed -i 's/parsed\.error\.errors\[0\]/parsed.error.issues[0]/g' app/api/payments/route.ts

echo "   ✅ Payments route Zod fix applied"

# ============================================
# VERIFY — run type check
# ============================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Running type check..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

npx tsc --noEmit 2>&1 | grep "error TS" | sort -u

COUNT=$(npx tsc --noEmit 2>&1 | grep -c "error TS" 2>/dev/null || echo "0")
echo ""
if [ "$COUNT" = "0" ]; then
  echo "✅ ZERO TypeScript errors"
  echo ""
  echo "Run: npm run build"
else
  echo "⚠️  $COUNT error(s) remaining — see above"
fi
echo ""
echo "🌍 Nifelux Technologies — Lagos, Nigeria"
