import { createAdminClient } from "@/lib/supabase/server";

interface AdminCheckResult {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  supabase: any;
  userId: string | null;
  isAdmin: boolean;
}

export async function requireAdmin(): Promise<AdminCheckResult> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const supabase = await createAdminClient() as any;
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { supabase, userId: null, isAdmin: false };

  const { data } = await supabase.from("users").select("role").eq("id", user.id).single();
  const role = (data as { role: string } | null)?.role ?? "";
  const isAdmin = ["admin", "super_admin"].includes(role);
  return { supabase, userId: user.id as string, isAdmin };
}

export async function getCurrentUser() {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const supabase = await createAdminClient() as any;
  const { data: { user } } = await supabase.auth.getUser();
  return { supabase, user };
}
