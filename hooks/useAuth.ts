"use client";
import { useEffect } from "react";
import { createClient } from "@/lib/supabase/client";
import { useAuthStore } from "@/store/authStore";
import { userService } from "@/services/user.service";
export function useAuth() {
  const { user, isLoading, setUser, setLoading } = useAuthStore();
  useEffect(() => {
    const s = createClient();
    s.auth.getSession().then(async ({ data: { session } }) => {
      if (session?.user) { const p = await userService.getProfile(session.user.id); setUser(p); }
      setLoading(false);
    });
    const { data: { subscription } } = s.auth.onAuthStateChange(async (_, session) => {
      if (session?.user) { const p = await userService.getProfile(session.user.id); setUser(p); } else { setUser(null); }
    });
    return () => subscription.unsubscribe();
  }, [setUser, setLoading]);
  return { user, isLoading };
}
