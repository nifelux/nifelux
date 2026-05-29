"use client";
import { useAuthStore } from "@/store/authStore";
export function useUser() {
  const user = useAuthStore((s) => s.user);
  return { user, isAdmin: user?.role === "admin" || user?.role === "super_admin", isSuperAdmin: user?.role === "super_admin" };
}
