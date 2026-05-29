// Run: npx supabase gen types typescript --project-id YOUR_ID > types/database.types.ts
export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];
export interface Database {
  public: {
    Tables: {
      users: { Row: { id: string; email: string; full_name: string; role: string; status: string; created_at: string; updated_at: string; }; };
      digital_ids: { Row: { id: string; user_id: string; id_number: string; qr_code_url: string; status: string; issued_at: string; expires_at: string; }; };
      certifications: { Row: { id: string; user_id: string; title: string; verification_code: string; status: string; issued_at: string; issued_by: string; }; };
      payments: { Row: { id: string; reference: string; amount: number; status: string; created_at: string; }; };
      notifications: { Row: { id: string; user_id: string; title: string; body: string; read: boolean; created_at: string; }; };
    };
  };
}
