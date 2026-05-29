import { createClient } from "@/lib/supabase/client";

export const authService = {
  async signIn(email: string, password: string) {
    const s = createClient();
    const { data, error } = await s.auth.signInWithPassword({ email, password });
    if (error) throw error;
    return data;
  },
  async signUp(email: string, password: string, metadata: { full_name: string; phone?: string }) {
    const s = createClient();
    const { data, error } = await s.auth.signUp({ email, password, options: { data: metadata } });
    if (error) throw error;
    return data;
  },
  async signOut() {
    const s = createClient();
    const { error } = await s.auth.signOut();
    if (error) throw error;
  },
  async getUser() {
    const s = createClient();
    const { data: { user } } = await s.auth.getUser();
    return user;
  },
  async resetPassword(email: string) {
    const s = createClient();
    const { error } = await s.auth.resetPasswordForEmail(email, {
      redirectTo: `${process.env.NEXT_PUBLIC_APP_URL}/reset-password`,
    });
    if (error) throw error;
  },
  async updatePassword(newPassword: string) {
    const s = createClient();
    const { error } = await s.auth.updateUser({ password: newPassword });
    if (error) throw error;
  },
};
