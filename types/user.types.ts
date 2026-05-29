export type UserRole = "user" | "staff" | "admin" | "super_admin";
export type UserStatus = "active" | "suspended" | "pending";
export interface User { id: string; email: string; full_name: string; phone?: string; role: UserRole; status: UserStatus; avatar_url?: string; created_at: string; updated_at: string; }
export interface DigitalId { id: string; user_id: string; id_number: string; qr_code_url: string; issued_at: string; expires_at: string; status: "active" | "expired" | "revoked"; }
export interface Certification { id: string; user_id: string; title: string; description?: string; certificate_url?: string; issued_by: string; issued_at: string; expires_at?: string; verification_code: string; status: "active" | "expired" | "revoked"; }
export interface Payment { id: string; user_id?: string; reference: string; amount: number; currency: string; status: "pending" | "success" | "failed" | "refunded"; purpose: string; paid_at?: string; created_at: string; }
export interface Notification { id: string; user_id: string; title: string; body: string; type: "info" | "success" | "warning" | "alert"; read: boolean; created_at: string; }
