"use client";
import { useEffect } from "react";
import { createClient } from "@/lib/supabase/client";
import { useAuthStore } from "@/store/authStore";
import type { User } from "@/types/user.types";

export function useAuth() {
  const { user, isLoading, setUser, setLoading } = useAuthStore();

  useEffect(() => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const s = createClient() as any;

    // Safety timeout — never hang longer than 5 seconds
    const timeout = setTimeout(() => {
      setLoading(false);
    }, 5000);

    const loadUser = async () => {
      try {
        const { data: { session } } = await s.auth.getSession();
        if (session?.user) {
          const { data: profile } = await s
            .from("users")
            .select("*")
            .eq("id", session.user.id)
            .single();

          setUser(profile as User ?? {
            id: session.user.id,
            email: session.user.email ?? "",
            full_name: session.user.user_metadata?.full_name ?? "User",
            role: "user",
            status: "active",
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          } as User);
        } else {
          setUser(null);
        }
      } catch {
        setUser(null);
      } finally {
        clearTimeout(timeout);
        setLoading(false);
      }
    };

    loadUser();

    const { data: { subscription } } = s.auth.onAuthStateChange(
      async (_: string, session: { user: { id: string; email?: string; user_metadata?: { full_name?: string } } } | null) => {
        if (session?.user) {
          try {
            const { data: profile } = await s
              .from("users")
              .select("*")
              .eq("id", session.user.id)
              .single();
            setUser(profile as User ?? {
              id: session.user.id,
              email: session.user.email ?? "",
              full_name: session.user.user_metadata?.full_name ?? "User",
              role: "user",
              status: "active",
              created_at: new Date().toISOString(),
              updated_at: new Date().toISOString(),
            } as User);
          } catch {
            setUser(null);
          }
        } else {
          setUser(null);
        }
        setLoading(false);
      }
    );

    return () => {
      clearTimeout(timeout);
      subscription.unsubscribe();
    };
  }, [setUser, setLoading]);

  return { user, isLoading };
}
