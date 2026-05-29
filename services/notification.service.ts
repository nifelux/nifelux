import { createClient } from "@/lib/supabase/client";
import type { Notification } from "@/types/user.types";

export const notificationService = {
  async getMyNotifications(userId: string): Promise<Notification[]> {
    const s = createClient();
    const { data } = await s
      .from("notifications")
      .select("*")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(20);
    return (data ?? []) as Notification[];
  },

  async markAsRead(notificationId: string): Promise<void> {
    const s = createClient();
    await s.from("notifications").update({ read: true }).eq("id", notificationId);
  },

  async markAllAsRead(userId: string): Promise<void> {
    const s = createClient();
    await s.from("notifications").update({ read: true }).eq("user_id", userId).eq("read", false);
  },

  async getUnreadCount(userId: string): Promise<number> {
    const s = createClient();
    const { count } = await s
      .from("notifications")
      .select("*", { count: "exact", head: true })
      .eq("user_id", userId)
      .eq("read", false);
    return count ?? 0;
  },
};
