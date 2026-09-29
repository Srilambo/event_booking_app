import { User } from '../models/User.js';
import { Event } from '../models/Event.js';
import { Booking } from '../models/Booking.js';
import { AuditLog } from '../models/AuditLog.js';
import { ApiError } from '../utils/ApiError.js';
import { asyncHandler } from '../utils/asyncHandler.js';

export const getStats = asyncHandler(async (req, res) => {
  const [totalEvents, totalBookings, totalUsers, revenueResult] = await Promise.all([
    Event.countDocuments(),
    Booking.countDocuments({ status: 'confirmed' }),
    User.countDocuments(),
    Booking.aggregate([
      { $match: { status: 'confirmed' } },
      { $group: { _id: null, totalRevenue: { $sum: '$totalPrice' } } }
    ])
  ]);

  const totalRevenue = revenueResult.length > 0 ? revenueResult[0].totalRevenue : 0;

  // Monthly revenue breakdown for charts
  const monthlyRevenue = await Booking.aggregate([
    { $match: { status: 'confirmed' } },
    {
      $group: {
        _id: { $month: '$createdAt' },
        revenue: { $sum: '$totalPrice' },
        bookings: { $sum: 1 }
      }
    },
    { $sort: { _id: 1 } }
  ]);

  res.status(200).json({
    success: true,
    data: {
      stats: {
        totalEvents,
        totalBookings,
        totalRevenue,
        totalUsers,
        monthlyRevenue
      }
    }
  });
});

export const getUsers = asyncHandler(async (req, res) => {
  const page = parseInt(req.query.page || '1', 10);
  const limit = parseInt(req.query.limit || '10', 10);
  const skip = (page - 1) * limit;

  const [users, total] = await Promise.all([
    User.find().select('-passwordHash').sort({ createdAt: -1 }).skip(skip).limit(limit),
    User.countDocuments()
  ]);

  res.status(200).json({
    success: true,
    data: { users },
    meta: {
      page,
      limit,
      total,
      pages: Math.ceil(total / limit)
    }
  });
});

export const updateUserRole = asyncHandler(async (req, res) => {
  const { role } = req.body;
  if (!['user', 'organizer', 'admin'].includes(role)) {
    throw new ApiError(400, 'Invalid role specified');
  }

  // Prevent admin self-demotion
  if (req.user._id.toString() === req.params.id && role !== 'admin') {
    throw new ApiError(400, 'You cannot demote yourself from admin role');
  }

  const targetUser = await User.findById(req.params.id);
  if (!targetUser) {
    throw new ApiError(404, 'User not found');
  }

  const previousRole = targetUser.role;
  targetUser.role = role;
  await targetUser.save();

  // Audit Log
  await AuditLog.create({
    actor: req.user._id,
    action: 'CHANGE_USER_ROLE',
    target: targetUser._id.toString(),
    ip: req.ip,
    details: { previousRole, newRole: role }
  });

  res.status(200).json({
    success: true,
    message: `User role updated to ${role}`,
    data: { user: targetUser }
  });
});

export const updateUserStatus = asyncHandler(async (req, res) => {
  const { isActive } = req.body;
  if (typeof isActive !== 'boolean') {
    throw new ApiError(400, 'isActive must be a boolean');
  }

  // Prevent admin self-deactivation
  if (req.user._id.toString() === req.params.id && !isActive) {
    throw new ApiError(400, 'You cannot deactivate your own admin account');
  }

  const targetUser = await User.findById(req.params.id);
  if (!targetUser) {
    throw new ApiError(404, 'User not found');
  }

  targetUser.isActive = isActive;
  await targetUser.save();

  // Audit Log
  await AuditLog.create({
    actor: req.user._id,
    action: 'CHANGE_USER_STATUS',
    target: targetUser._id.toString(),
    ip: req.ip,
    details: { isActive }
  });

  res.status(200).json({
    success: true,
    message: `User status updated to ${isActive ? 'active' : 'inactive'}`,
    data: { user: targetUser }
  });
});
