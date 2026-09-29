import { z } from 'zod';

export const createEventSchema = z.object({
  body: z.object({
    title: z.string().min(3).max(150),
    description: z.string().min(10),
    category: z.enum(['Music', 'Tech', 'Sports', 'Arts', 'Business', 'Food', 'General']),
    imageUrl: z.string().url().optional(),
    venue: z.string().min(2),
    city: z.string().min(2),
    startDate: z.string().datetime({ message: 'Invalid ISO date string' }),
    endDate: z.string().datetime({ message: 'Invalid ISO date string' }),
    price: z.number().min(0, 'Price must be non-negative'),
    totalSeats: z.number().int().min(1, 'Total seats must be at least 1'),
    status: z.enum(['draft', 'published', 'cancelled']).optional()
  }).strip().refine((data) => new Date(data.endDate) > new Date(data.startDate), {
    message: 'End date must be after start date',
    path: ['endDate']
  })
});

const eventBodyPartial = z.object({
  title: z.string().min(3).max(150).optional(),
  description: z.string().min(10).optional(),
  category: z.enum(['Music', 'Tech', 'Sports', 'Arts', 'Business', 'Food', 'General']).optional(),
  imageUrl: z.string().url().optional(),
  venue: z.string().min(2).optional(),
  city: z.string().min(2).optional(),
  startDate: z.string().datetime({ message: 'Invalid ISO date string' }).optional(),
  endDate: z.string().datetime({ message: 'Invalid ISO date string' }).optional(),
  price: z.number().min(0, 'Price must be non-negative').optional(),
  totalSeats: z.number().int().min(1, 'Total seats must be at least 1').optional(),
  status: z.enum(['draft', 'published', 'cancelled']).optional()
}).strip();

export const updateEventSchema = z.object({
  params: z.object({
    id: z.string().regex(/^[0-9a-fA-F]{24}$/, 'Invalid MongoDB ObjectId')
  }),
  body: eventBodyPartial
});

export const getEventsQuerySchema = z.object({
  query: z.object({
    search: z.string().optional(),
    category: z.string().optional(),
    city: z.string().optional(),
    from: z.string().optional(),
    to: z.string().optional(),
    page: z.string().transform(val => parseInt(val, 10)).optional(),
    limit: z.string().transform(val => parseInt(val, 10)).optional()
  })
});
