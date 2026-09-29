import express from 'express';
import * as bookingController from '../controllers/booking.controller.js';
import { auth } from '../middleware/auth.js';
import { authorize } from '../middleware/role.js';
import { validate } from '../middleware/validate.js';
import { createBookingSchema, cancelBookingSchema } from '../validators/booking.schema.js';

const router = express.Router();

router.post('/', auth, validate(createBookingSchema), bookingController.createBooking);
router.get('/mine', auth, bookingController.getMyBookings);
router.patch('/:id/cancel', auth, validate(cancelBookingSchema), bookingController.cancelBooking);

// Event bookings list for organizer/admin
router.get('/events/:id/bookings', auth, authorize('organizer', 'admin'), bookingController.getEventBookings);

export default router;
