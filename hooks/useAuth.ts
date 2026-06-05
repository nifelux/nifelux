"use client";
import { useEffect } from "react";
import { createClient } from "@/lib/supabase/client";
import { useAuthStore } from "@/store/authStore";
import { userService } from "@/services/user.service";

export function useAuth() {
  const { user, isLoading, setUser, setLoading } = useAuthStore();
  useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const s = createClient() as any;
    s.auth.getSession().then(async ({ data: { session } }: { data: { session: { user: { id: string } } | null } }) => {
      if (session?.user) { const p = await userService.getProfile(session.user.id); setUser(p); }
      setLoading(false);
    });
    const { data: { subscription } } = s.auth.onAuthStateChange(async (_: string, session: { user: { id: string } } | null) => {
      if (session?.user) { const p = await userService.getProfile(session.user.id); setUser(p); }
      else { setUser(null); }
    });
    return () => subscription.unsubscribe();
  }, [setUser, setLoading]);
  return { user, isLoading };
}
