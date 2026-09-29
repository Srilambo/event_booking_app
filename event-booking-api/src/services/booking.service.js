import { Event } from '../models/Event.js';
import { Booking } from '../models/Booking.js';
import { ApiError } from '../utils/ApiError.js';
import { generateBookingCode } from '../utils/generateCode.js';

export class BookingService {
  static async createBooking({ userId, eventId, quantity, idempotencyKey }) {
    // 1. Idempotency Check
    if (idempotencyKey) {
      const existingBooking = await Booking.findOne({ user: userId, idempotencyKey });
      if (existingBooking) {
        return existingBooking;
      }
    }

    // 2. Fetch event to verify validity and calculate price
    const event = await Event.findById(eventId);
    if (!event) {
      throw new ApiError(404, 'Event not found');
    }
    if (event.status !== 'published') {
      throw new ApiError(400, 'Cannot book tickets for draft or cancelled events');
    }
    if (new Date(event.startDate) <= new Date()) {
      throw new ApiError(400, 'Cannot book tickets for past events');
    }

    // 3. Atomic Seat Decrement (Race-condition Safe)
    const updatedEvent = await Event.findOneAndUpdate(
      {
        _id: eventId,
        availableSeats: { $gte: quantity },
        status: 'published'
      },
      {
        $inc: { availableSeats: -quantity }
      },
      { new: true }
    );

    if (!updatedEvent) {
      throw new ApiError(409, 'Not enough seats available for this event');
    }

    // 4. Server-calculated total price (never trust client total)
    const totalPrice = updatedEvent.price * quantity;
    const bookingCode = generateBookingCode();

    try {
      // 5. Create Booking Document
      const booking = await Booking.create({
        user: userId,
        event: eventId,
        quantity,
        totalPrice,
        bookingCode,
        status: 'confirmed',
        idempotencyKey
      });

      return booking;
    } catch (err) {
      // Rollback seat count atomically if DB creation fails
      await Event.findByIdAndUpdate(eventId, {
        $inc: { availableSeats: quantity }
      });
      throw err;
    }
  }

  static async cancelBooking({ bookingId, user }) {
    const booking = await Booking.findById(bookingId).populate('event');
    if (!booking) {
      throw new ApiError(404, 'Booking not found');
    }

    // Ownership check (IDOR Protection)
    const isOwner = booking.user.toString() === user._id.toString();
    const isAdmin = user.role === 'admin';
    if (!isOwner && !isAdmin) {
      throw new ApiError(403, 'Forbidden: You do not own this booking');
    }

    if (booking.status === 'cancelled') {
      throw new ApiError(400, 'Booking is already cancelled');
    }

    // Cutoff check: 24 hours before event start
    const eventStart = new Date(booking.event.startDate).getTime();
    const now = Date.now();
    const hoursLeft = (eventStart - now) / (1000 * 60 * 60);

    if (hoursLeft < 24 && !isAdmin) {
      throw new ApiError(400, 'Bookings cannot be cancelled less than 24 hours before event start');
    }

    // Cancel booking and increment available seats back atomically
    booking.status = 'cancelled';
    await booking.save();

    await Event.findByIdAndUpdate(booking.event._id, {
      $inc: { availableSeats: booking.quantity }
    });

    return booking;
  }
}
