import { createClient } from "@/lib/supabase/client";
import type { Certification } from "@/types/user.types";
export const certificationService = {
  async getMyCertifications(userId: string): Promise<Certification[]> { const s = createClient(); const { data } = await s.from("certifications").select("*").eq("user_id", userId).order("issued_at", { ascending: false }); return (data ?? []) as Certification[]; },
  async verify(code: string) { const s = createClient(); const { data } = await s.from("certifications").select("*, users(full_name)").eq("verification_code", code).single(); return data; },
};
