import { createClient } from "@/lib/supabase/client";
import type { User } from "@/types/user.types";

export const userService = {
  async getProfile(userId: string): Promise<User | null> {
    const s = createClient();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { data } = await (s as any).from("users").select("*").eq("id", userId).single();
    return (data as User) ?? null;
  },

  async updateProfile(userId: string, updates: Partial<User>): Promise<User> {
    const s = createClient();
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { data, error } = await (s as any)
      .from("users")
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq("id", userId)
      .select()
      .single();
    if (error) throw error;
    return data as User;
  },
};
