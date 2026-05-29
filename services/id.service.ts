import { createClient } from "@/lib/supabase/client";
import type { DigitalId } from "@/types/user.types";
export const idService = {
  async getMyId(userId: string): Promise<DigitalId | null> { const s = createClient(); const { data } = await s.from("digital_ids").select("*").eq("user_id", userId).eq("status", "active").single(); return data as DigitalId | null; },
  async verifyId(idNumber: string) { const s = createClient(); const { data } = await s.from("digital_ids").select("*, users(full_name, email)").eq("id_number", idNumber).single(); return data; },
};
