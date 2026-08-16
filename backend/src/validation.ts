import { z } from "zod";

export const sendNumberSchema = z.object({
  recipient: z.string().regex(/^\+[1-9]\d{7,14}$/, "Recipient must be a valid E.164 phone number."),
  value: z.string().regex(/^\d{2}$/, "Value must contain exactly two numeric characters.")
});

export type SendNumberRequest = z.infer<typeof sendNumberSchema>;
