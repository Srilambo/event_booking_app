import mongoose from 'mongoose';

const bookingSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true
    },
    event: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Event',
      required: true,
      index: true
    },
    quantity: {
      type: Number,
      required: true,
      min: [1, 'Quantity must be at least 1'],
      max: [10, 'Maximum 10 tickets per booking']
    },
    totalPrice: {
      type: Number,
      required: true,
      min: 0
    },
    bookingCode: {
      type: String,
      required: true,
      unique: true,
      index: true
    },
    status: {
      type: String,
      enum: ['confirmed', 'cancelled'],
      default: 'confirmed'
    },
    idempotencyKey: {
      type: String,
      index: true
    }
  },
  {
    timestamps: true
  }
);

bookingSchema.index({ user: 1, event: 1 });

export const Booking = mongoose.model('Booking', bookingSchema);
