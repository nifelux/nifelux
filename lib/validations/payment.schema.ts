import { z } from "zod";
export const contributionSchema = z.object({ amount: z.number().min(100, "Min ₦100"), name: z.string().optional(), email: z.string().email().optional().or(z.literal("")), message: z.string().max(200).optional(), anonymous: z.boolean().default(false) });
export type ContributionForm = z.infer<typeof contributionSchema>;
