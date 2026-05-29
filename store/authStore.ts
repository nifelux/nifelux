import { create } from "zustand";
import type { User } from "@/types/user.types";
interface AuthState { user: User | null; isLoading: boolean; setUser: (u: User | null) => void; setLoading: (l: boolean) => void; reset: () => void; }
export const useAuthStore = create<AuthState>((set) => ({
  user: null, isLoading: true,
  setUser: (user) => set({ user }),
  setLoading: (isLoading) => set({ isLoading }),
  reset: () => set({ user: null, isLoading: false }),
}));
