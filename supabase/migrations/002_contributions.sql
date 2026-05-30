-- Support contributions table
CREATE TABLE IF NOT EXISTS public.support_contributions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  payment_id UUID REFERENCES public.payments(id) ON DELETE SET NULL,
  amount NUMERIC NOT NULL,
  message TEXT,
  anonymous BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contributions_user ON public.support_contributions(user_id);
CREATE INDEX IF NOT EXISTS idx_contributions_payment ON public.support_contributions(payment_id);

ALTER TABLE public.support_contributions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_view_contributions" ON public.support_contributions
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

CREATE POLICY "public_create_contribution" ON public.support_contributions
  FOR INSERT WITH CHECK (TRUE);
