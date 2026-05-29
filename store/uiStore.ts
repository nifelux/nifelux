import { create } from "zustand";
interface UiState { sidebarOpen: boolean; setSidebarOpen: (o: boolean) => void; toggleSidebar: () => void; }
export const useUiStore = create<UiState>((set) => ({
  sidebarOpen: false,
  setSidebarOpen: (sidebarOpen) => set({ sidebarOpen }),
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
}));
