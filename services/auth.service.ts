import { createClient } from "@/lib/supabase/client";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const auth = () => (createClient() as any).auth;

export const authService = {
  async signIn(email: string, password: string) {
    const { data, error } = await auth().signInWithPassword({ email, password });
    if (error) throw error;
    return data;
  },
  async signUp(email: string, password: string, metadata: { full_name: string; phone?: string }) {
    const { data, error } = await auth().signUp({ email, password, options: { data: metadata } });
    if (error) throw error;
    return data;
  },
  async signOut() {
    const { error } = await auth().signOut();
    if (error) throw error;
  },
  async getUser() {
    const { data: { user } } = await auth().getUser();
    return user;
  },
  async resetPassword(email: string) {
    const { error } = await auth().resetPasswordForEmail(email, {
      redirectTo: `${process.env.NEXT_PUBLIC_APP_URL}/reset-password`,
    });
    if (error) throw error;
  },
  async updatePassword(newPassword: string) {
    const { error } = await auth().updateUser({ password: newPassword });
    if (error) throw error;
  },
};
