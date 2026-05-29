import { z } from "zod";
export const loginSchema = z.object({ email: z.string().email("Invalid email"), password: z.string().min(6, "Min 6 characters") });
export const registerSchema = z.object({ full_name: z.string().min(2, "Min 2 characters"), email: z.string().email("Invalid email"), password: z.string().min(8, "Min 8 characters").regex(/[A-Z]/, "Need uppercase").regex(/[0-9]/, "Need number"), phone: z.string().optional() });
export const contactSchema = z.object({ name: z.string().min(2), email: z.string().email(), subject: z.string().min(5), message: z.string().min(20) });
export type LoginForm = z.infer<typeof loginSchema>;
export type RegisterForm = z.infer<typeof registerSchema>;
export type ContactForm = z.infer<typeof contactSchema>;
