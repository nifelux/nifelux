#!/bin/bash

# ============================================
# NIFELUX — FIX ALL TYPESCRIPT ERRORS AT ONCE
# Root cause: database.types.ts is a placeholder
# This gives Supabase full schema types so all
# .update() .select() .insert() calls type-check
# ============================================

echo "🔧 Fixing all Supabase TypeScript errors..."

cat > types/database.types.ts << 'EOF'
export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];

export type UserRole = "user" | "staff" | "admin" | "super_admin";
export type UserStatus = "active" | "suspended" | "pending";
export type IdStatus = "active" | "expired" | "revoked";
export type CertStatus = "active" | "expired" | "revoked";
export type PaymentStatus = "pending" | "success" | "failed" | "refunded";
export type NotificationType = "info" | "success" | "warning" | "alert";

export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          id: string;
          email: string;
          full_name: string;
          phone: string | null;
          role: UserRole;
          status: UserStatus;
          avatar_url: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          email: string;
          full_name: string;
          phone?: string | null;
          role?: UserRole;
          status?: UserStatus;
          avatar_url?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          email?: string;
          full_name?: string;
          phone?: string | null;
          role?: UserRole;
          status?: UserStatus;
          avatar_url?: string | null;
          updated_at?: string;
        };
      };
      digital_ids: {
        Row: {
          id: string;
          user_id: string;
          id_number: string;
          qr_code_url: string | null;
          issued_at: string;
          expires_at: string;
          status: IdStatus;
          metadata: Json | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          id_number: string;
          qr_code_url?: string | null;
          issued_at?: string;
          expires_at: string;
          status?: IdStatus;
          metadata?: Json | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          id_number?: string;
          qr_code_url?: string | null;
          issued_at?: string;
          expires_at?: string;
          status?: IdStatus;
          metadata?: Json | null;
        };
      };
      certifications: {
        Row: {
          id: string;
          user_id: string;
          title: string;
          description: string | null;
          certificate_url: string | null;
          issued_by: string;
          issued_at: string;
          expires_at: string | null;
          verification_code: string;
          status: CertStatus;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          title: string;
          description?: string | null;
          certificate_url?: string | null;
          issued_by: string;
          issued_at?: string;
          expires_at?: string | null;
          verification_code: string;
          status?: CertStatus;
          created_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          title?: string;
          description?: string | null;
          certificate_url?: string | null;
          issued_by?: string;
          issued_at?: string;
          expires_at?: string | null;
          verification_code?: string;
          status?: CertStatus;
        };
      };
      payments: {
        Row: {
          id: string;
          user_id: string | null;
          reference: string;
          amount: number;
          currency: string;
          status: PaymentStatus;
          purpose: string;
          metadata: Json | null;
          paid_at: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id?: string | null;
          reference: string;
          amount: number;
          currency?: string;
          status?: PaymentStatus;
          purpose: string;
          metadata?: Json | null;
          paid_at?: string | null;
          created_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string | null;
          reference?: string;
          amount?: number;
          currency?: string;
          status?: PaymentStatus;
          purpose?: string;
          metadata?: Json | null;
          paid_at?: string | null;
        };
      };
      notifications: {
        Row: {
          id: string;
          user_id: string;
          title: string;
          body: string;
          type: NotificationType;
          read: boolean;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          title: string;
          body: string;
          type?: NotificationType;
          read?: boolean;
          created_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          title?: string;
          body?: string;
          type?: NotificationType;
          read?: boolean;
        };
      };
      activity_logs: {
        Row: {
          id: string;
          actor_id: string | null;
          action: string;
          target_type: string | null;
          target_id: string | null;
          metadata: Json | null;
          ip_address: string | null;
          created_at: string;
        };
        Insert: {
          id?: string;
          actor_id?: string | null;
          action: string;
          target_type?: string | null;
          target_id?: string | null;
          metadata?: Json | null;
          ip_address?: string | null;
          created_at?: string;
        };
        Update: {
          action?: string;
          target_type?: string | null;
          target_id?: string | null;
          metadata?: Json | null;
          ip_address?: string | null;
        };
      };
      support_contributions: {
        Row: {
          id: string;
          user_id: string | null;
          payment_id: string | null;
          amount: number;
          message: string | null;
          anonymous: boolean;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id?: string | null;
          payment_id?: string | null;
          amount: number;
          message?: string | null;
          anonymous?: boolean;
          created_at?: string;
        };
        Update: {
          amount?: number;
          message?: string | null;
          anonymous?: boolean;
        };
      };
      qr_verifications: {
        Row: {
          id: string;
          digital_id_id: string | null;
          scanned_by_ip: string | null;
          scan_result: "valid" | "expired" | "revoked";
          scanned_at: string;
        };
        Insert: {
          id?: string;
          digital_id_id?: string | null;
          scanned_by_ip?: string | null;
          scan_result: "valid" | "expired" | "revoked";
          scanned_at?: string;
        };
        Update: {
          scan_result?: "valid" | "expired" | "revoked";
        };
      };
    };
    Views: Record<string, never>;
    Functions: Record<string, never>;
    Enums: {
      user_role: UserRole;
      user_status: UserStatus;
      id_status: IdStatus;
      cert_status: CertStatus;
      payment_status: PaymentStatus;
      notification_type: NotificationType;
    };
  };
}
EOF

echo "✅ database.types.ts written with full schema"
echo ""
echo "Running type check to find any remaining errors..."
echo ""
npx tsc --noEmit 2>&1 | grep "error TS" | sort -u | head -30
echo ""
echo "If no errors above — run: npm run build"
