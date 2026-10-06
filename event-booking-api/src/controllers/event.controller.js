import { Event } from '../models/Event.js';
import { ApiError } from '../utils/ApiError.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { escapeRegex } from '../utils/escapeRegex.js';
import { isOwnerOrAdmin } from '../middleware/role.js';

export const getEvents = asyncHandler(async (req, res) => {
  const page = parseInt(req.query.page || '1', 10);
  const limit = parseInt(req.query.limit || '100', 10);
  const skip = (page - 1) * limit;

  const filter = {};

  // Status visibility: unauthenticated or regular users can only see published events
  if (!req.user || req.user.role === 'user') {
    filter.status = 'published';
  } else if (req.user.role === 'organizer') {
    // Organizer sees published OR their own draft/cancelled
    filter.$or = [
      { status: 'published' },
      { createdBy: req.user._id }
    ];
  }

  // Search filter (text / regex on title, description, city, venueName)
  if (req.query.search) {
    const safeSearch = escapeRegex(req.query.search);
    filter.$or = [
      { title: { $regex: safeSearch, $options: 'i' } },
      { description: { $regex: safeSearch, $options: 'i' } },
      { city: { $regex: safeSearch, $options: 'i' } },
      { venueName: { $regex: safeSearch, $options: 'i' } }
    ];
  }

  if (req.query.category && req.query.category !== 'All') {
    filter.category = req.query.category;
  }

  if (req.query.city) {
    filter.city = { $regex: escapeRegex(req.query.city), $options: 'i' };
  }

  if (req.query.from || req.query.to) {
    filter.startDate = {};
    if (req.query.from) filter.startDate.$gte = new Date(req.query.from);
    if (req.query.to) filter.startDate.$lte = new Date(req.query.to);
  }

  const [events, total] = await Promise.all([
    Event.find(filter)
      .populate('createdBy', 'name email')
      .sort({ startDate: 1 })
      .skip(skip)
      .limit(limit),
    Event.countDocuments(filter)
  ]);

  res.status(200).json({
    success: true,
    data: { events },
    meta: {
      page,
      limit,
      total,
      pages: Math.ceil(total / limit)
    }
  });
});

export const getEventById = asyncHandler(async (req, res) => {
  const event = await Event.findById(req.params.id).populate('createdBy', 'name email');
  if (!event) {
    throw new ApiError(404, 'Event not found');
  }

  if (event.status !== 'published') {
    if (!req.user) {
      throw new ApiError(404, 'Event not found');
    }
    const canView = isOwnerOrAdmin(req.user, event.createdBy._id || event.createdBy);
    if (!canView) {
      throw new ApiError(403, 'Forbidden: You cannot view draft or cancelled events created by another user');
    }
  }

  res.status(200).json({
    success: true,
    data: { event }
  });
});

export const createEvent = asyncHandler(async (req, res) => {
  const venueName = req.body.venueName || req.body.venue || 'Colombo Venue';
  const latitude = req.body.latitude != null ? Number(req.body.latitude) : 6.9271;
  const longitude = req.body.longitude != null ? Number(req.body.longitude) : 79.8612;

  const eventData = {
    ...req.body,
    venueName,
    venue: venueName,
    latitude,
    longitude,
    location: {
      type: 'Point',
      coordinates: [longitude, latitude]
    },
    currency: req.body.currency || 'LKR',
    availableSeats: req.body.availableSeats ?? req.body.totalSeats,
    createdBy: req.user._id
  };

  const event = await Event.create(eventData);

  res.status(201).json({
    success: true,
    message: 'Event created successfully',
    data: { event }
  });
});

export const updateEvent = asyncHandler(async (req, res) => {
  const event = await Event.findById(req.params.id);
  if (!event) {
    throw new ApiError(404, 'Event not found');
  }

  if (!isOwnerOrAdmin(req.user, event.createdBy)) {
    throw new ApiError(403, 'Forbidden: You can only edit your own events');
  }

  if (req.body.totalSeats !== undefined) {
    const seatDifference = req.body.totalSeats - event.totalSeats;
    req.body.availableSeats = Math.max(0, event.availableSeats + seatDifference);
  }

  if (req.body.venueName || req.body.venue) {
    const venueStr = req.body.venueName || req.body.venue;
    req.body.venueName = venueStr;
    req.body.venue = venueStr;
  }

  if (req.body.latitude != null || req.body.longitude != null) {
    const lat = req.body.latitude != null ? Number(req.body.latitude) : event.latitude;
    const lng = req.body.longitude != null ? Number(req.body.longitude) : event.longitude;
    req.body.latitude = lat;
    req.body.longitude = lng;
    req.body.location = {
      type: 'Point',
      coordinates: [lng, lat]
    };
  }

  Object.assign(event, req.body);
  await event.save();

  res.status(200).json({
    success: true,
    message: 'Event updated successfully',
    data: { event }
  });
});

export const deleteEvent = asyncHandler(async (req, res) => {
  const event = await Event.findById(req.params.id);
  if (!event) {
    throw new ApiError(404, 'Event not found');
  }

  if (!isOwnerOrAdmin(req.user, event.createdBy)) {
    throw new ApiError(403, 'Forbidden: You can only delete your own events');
  }

  await Event.findByIdAndDelete(req.params.id);

  res.status(200).json({
    success: true,
    message: 'Event deleted successfully'
  });
});
