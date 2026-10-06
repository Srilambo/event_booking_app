import mongoose from 'mongoose';

const eventSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Event title is required'],
      trim: true,
      maxlength: [150, 'Title cannot exceed 150 characters']
    },
    description: {
      type: String,
      required: [true, 'Description is required'],
      trim: true
    },
    category: {
      type: String,
      required: [true, 'Category is required'],
      trim: true,
      enum: ['Music', 'Tech', 'Sports', 'Arts', 'Business', 'Food', 'General']
    },
    imageUrl: {
      type: String,
      default: 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?auto=format&fit=crop&w=800&q=80'
    },
    venueName: {
      type: String,
      required: [true, 'Venue name is required'],
      trim: true
    },
    venue: {
      type: String,
      trim: true
    },
    city: {
      type: String,
      required: [true, 'City is required'],
      trim: true
    },
    address: {
      type: String,
      trim: true,
      default: ''
    },
    latitude: {
      type: Number,
      required: true,
      default: 6.9271
    },
    longitude: {
      type: Number,
      required: true,
      default: 79.8612
    },
    location: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point'
      },
      coordinates: {
        type: [Number], // [longitude, latitude]
        default: [79.8612, 6.9271]
      }
    },
    startDate: {
      type: Date,
      required: [true, 'Start date is required']
    },
    endDate: {
      type: Date,
      required: [true, 'End date is required']
    },
    price: {
      type: Number,
      required: [true, 'Price is required'],
      min: [0, 'Price must be non-negative']
    },
    currency: {
      type: String,
      default: 'LKR'
    },
    totalSeats: {
      type: Number,
      required: [true, 'Total seats is required'],
      min: [1, 'Must have at least 1 seat']
    },
    availableSeats: {
      type: Number,
      required: [true, 'Available seats is required'],
      min: [0, 'Available seats cannot be negative']
    },
    organizerName: {
      type: String,
      trim: true,
      default: ''
    },
    status: {
      type: String,
      enum: ['draft', 'published', 'cancelled'],
      default: 'published'
    },
    isSample: {
      type: Boolean,
      default: false
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    }
  },
  {
    timestamps: true
  }
);

// Pre-save hook to sync venue/venueName and GeoJSON location
eventSchema.pre('save', function (next) {
  if (this.longitude != null && this.latitude != null) {
    this.location = {
      type: 'Point',
      coordinates: [this.longitude, this.latitude]
    };
  }
  if (!this.venueName && this.venue) {
    this.venueName = this.venue;
  }
  if (!this.venue && this.venueName) {
    this.venue = this.venueName;
  }
  next();
});

// Indexes
eventSchema.index({ location: '2dsphere' });
eventSchema.index({ startDate: 1, category: 1, status: 1 });
eventSchema.index({ title: 'text', description: 'text', city: 'text', venueName: 'text' });

export const Event = mongoose.model('Event', eventSchema);
