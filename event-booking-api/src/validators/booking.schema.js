import { z } from 'zod';

export const createBookingSchema = z.object({
  body: z.object({
    eventId: z.string().regex(/^[0-9a-fA-F]{24}$/, 'Invalid MongoDB ObjectId'),
    quantity: z.number().int().min(1, 'Quantity must be at least 1').max(10, 'Maximum 10 tickets per booking')
  }).strip()
});

export const cancelBookingSchema = z.object({
  params: z.object({
    id: z.string().regex(/^[0-9a-fA-F]{24}$/, 'Invalid MongoDB ObjectId')
  })
});
