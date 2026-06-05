import { createClient } from "@/lib/supabase/client";
import type { DigitalId } from "@/types/user.types";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const db = () => createClient() as any;

export const idService = {
  async getMyId(userId: string): Promise<DigitalId | null> {
    const { data } = await db().from("digital_ids").select("*").eq("user_id", userId).eq("status", "active").single();
    return (data as DigitalId) ?? null;
  },
  async verifyId(idNumber: string) {
    const { data } = await db().from("digital_ids").select("*, users(full_name, email)").eq("id_number", idNumber).single();
    return data;
  },
};
