import { createClient } from "@/lib/supabase/client";
import type { Notification } from "@/types/user.types";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
const db = () => createClient() as any;

export const notificationService = {
  async getMyNotifications(userId: string): Promise<Notification[]> {
    const { data } = await db().from("notifications").select("*").eq("user_id", userId).order("created_at", { ascending: false }).limit(20);
    return (data ?? []) as Notification[];
  },
  async markAsRead(id: string): Promise<void> {
    await db().from("notifications").update({ read: true }).eq("id", id);
  },
  async markAllAsRead(userId: string): Promise<void> {
    await db().from("notifications").update({ read: true }).eq("user_id", userId).eq("read", false);
  },
  async getUnreadCount(userId: string): Promise<number> {
    const { count } = await db().from("notifications").select("*", { count: "exact", head: true }).eq("user_id", userId).eq("read", false);
    return count ?? 0;
  },
};
