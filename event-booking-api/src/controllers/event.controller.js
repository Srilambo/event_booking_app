import { Event } from '../models/Event.js';
import { ApiError } from '../utils/ApiError.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { escapeRegex } from '../utils/escapeRegex.js';
import { isOwnerOrAdmin } from '../middleware/role.js';

export const getEvents = asyncHandler(async (req, res) => {
  const page = parseInt(req.query.page || '1', 10);
  const limit = parseInt(req.query.limit || '10', 10);
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
  // Admin sees all statuses (no status filter constraint unless requested)

  // Search filter (text / regex on title, description, city)
  if (req.query.search) {
    const safeSearch = escapeRegex(req.query.search);
    filter.$or = [
      { title: { $regex: safeSearch, $options: 'i' } },
      { description: { $regex: safeSearch, $options: 'i' } },
      { city: { $regex: safeSearch, $options: 'i' } }
    ];
  }

  if (req.query.category) {
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

  // Access check
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
  const eventData = {
    ...req.body,
    availableSeats: req.body.totalSeats,
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

  // Handle totalSeats change logic
  if (req.body.totalSeats !== undefined) {
    const seatDifference = req.body.totalSeats - event.totalSeats;
    req.body.availableSeats = Math.max(0, event.availableSeats + seatDifference);
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
