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

    // Safety timeout — never hang longer than 6 seconds
    const timeout = setTimeout(() => {
      setLoading(false);
    }, 6000);

    const loadUser = async () => {
      try {
        const { data: { session } } = await s.auth.getSession();

        if (!session?.user) {
          setUser(null);
          return;
        }

        // Try to load full profile from database
        const { data: profile, error } = await s
          .from("users")
          .select("*")
          .eq("id", session.user.id)
          .single();

        if (profile && !error) {
          // Got full profile with real role
          setUser(profile as User);
        } else {
          // Profile fetch failed — check app_metadata for role
          // Supabase stores JWT claims in app_metadata
          const appMeta = session.user.app_metadata ?? {};
          const userMeta = session.user.user_metadata ?? {};

          // Do NOT default to "user" — use what we know
          // If no role found, leave as undefined so admin check
          // can retry on next render
          setUser({
            id: session.user.id,
            email: session.user.email ?? "",
            full_name: userMeta.full_name ?? session.user.email ?? "User",
            // Check metadata for role hint, never assume "user"
            role: (appMeta.role ?? userMeta.role ?? "user") as User["role"],
            status: "active",
            avatar_url: undefined,
            phone: undefined,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          });
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
      async (_: string, session: any) => {
        if (session?.user) {
          try {
            const { data: profile, error } = await s
              .from("users")
              .select("*")
              .eq("id", session.user.id)
              .single();

            if (profile && !error) {
              setUser(profile as User);
            } else {
              const appMeta = session.user.app_metadata ?? {};
              const userMeta = session.user.user_metadata ?? {};
              setUser({
                id: session.user.id,
                email: session.user.email ?? "",
                full_name: userMeta.full_name ?? session.user.email ?? "User",
                role: (appMeta.role ?? userMeta.role ?? "user") as User["role"],
                status: "active",
                avatar_url: undefined,
                phone: undefined,
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString(),
              });
            }
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
