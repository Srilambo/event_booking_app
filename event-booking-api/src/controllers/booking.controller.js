import { BookingService } from '../services/booking.service.js';
import { Booking } from '../models/Booking.js';
import { Event } from '../models/Event.js';
import { ApiError } from '../utils/ApiError.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { isOwnerOrAdmin } from '../middleware/role.js';

export const createBooking = asyncHandler(async (req, res) => {
  const { eventId, quantity } = req.body;
  const idempotencyKey = req.headers['idempotency-key'];

  const booking = await BookingService.createBooking({
    userId: req.user._id,
    eventId,
    quantity,
    idempotencyKey
  });

  const populatedBooking = await Booking.findById(booking._id).populate('event');

  res.status(201).json({
    success: true,
    message: 'Booking confirmed successfully',
    data: { booking: populatedBooking }
  });
});

export const getMyBookings = asyncHandler(async (req, res) => {
  const page = parseInt(req.query.page || '1', 10);
  const limit = parseInt(req.query.limit || '10', 10);
  const skip = (page - 1) * limit;

  const filter = { user: req.user._id };
  if (req.query.status) {
    filter.status = req.query.status;
  }

  const [bookings, total] = await Promise.all([
    Booking.find(filter)
      .populate('event')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit),
    Booking.countDocuments(filter)
  ]);

  res.status(200).json({
    success: true,
    data: { bookings },
    meta: {
      page,
      limit,
      total,
      pages: Math.ceil(total / limit)
    }
  });
});

export const cancelBooking = asyncHandler(async (req, res) => {
  const booking = await BookingService.cancelBooking({
    bookingId: req.params.id,
    user: req.user
  });

  res.status(200).json({
    success: true,
    message: 'Booking cancelled successfully',
    data: { booking }
  });
});

export const getEventBookings = asyncHandler(async (req, res) => {
  const event = await Event.findById(req.params.id);
  if (!event) {
    throw new ApiError(404, 'Event not found');
  }

  if (!isOwnerOrAdmin(req.user, event.createdBy)) {
    throw new ApiError(403, 'Forbidden: You can only view bookings for events you created');
  }

  const bookings = await Booking.find({ event: event._id }).populate('user', 'name email').sort({ createdAt: -1 });

  res.status(200).json({
    success: true,
    data: { bookings },
    meta: { total: bookings.length }
  });
});
