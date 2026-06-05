import { createClient } from "@/lib/supabase/client";
import type { Certification } from "@/types/user.types";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const db = () => createClient() as any;

export const certificationService = {
  async getMyCertifications(userId: string): Promise<Certification[]> {
    const { data } = await db().from("certifications").select("*").eq("user_id", userId).order("issued_at", { ascending: false });
    return (data ?? []) as Certification[];
  },
  async verify(code: string) {
    const { data } = await db().from("certifications").select("*, users(full_name)").eq("verification_code", code).single();
    return data;
  },
};
