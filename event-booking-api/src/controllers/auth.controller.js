import bcrypt from 'bcryptjs';
import { User } from '../models/User.js';
import { TokenService } from '../services/token.service.js';
import { ApiError } from '../utils/ApiError.js';
import { asyncHandler } from '../utils/asyncHandler.js';

export const register = asyncHandler(async (req, res) => {
  const { name, email, password } = req.body;

  const existingUser = await User.findOne({ email });
  if (existingUser) {
    throw new ApiError(409, 'User with this email already exists');
  }

  // Cost factor 12 as specified in Prompt 3
  const passwordHash = await bcrypt.hash(password, 12);

  // Explicitly ignore any role provided during signup (Mass Assignment protection)
  const user = await User.create({
    name,
    email,
    passwordHash,
    role: 'user'
  });

  const accessToken = TokenService.generateAccessToken(user);
  const refreshToken = await TokenService.generateRefreshToken(user._id);

  res.status(201).json({
    success: true,
    message: 'User registered successfully',
    data: {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role
      },
      tokens: {
        accessToken,
        refreshToken
      }
    }
  });
});

export const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email }).select('+passwordHash');

  // Dummy hash compare to prevent timing-based user enumeration if user doesn't exist
  const dummyHash = '$2a$12$e868c/.2Q3E8b0Y0T9D8eO9d9l7Z7u/.5M2fG8Q0y7U7i7K7O7U7i';

  if (!user) {
    await bcrypt.compare(password, dummyHash);
    throw new ApiError(401, 'Invalid email or password');
  }

  // Check Account Lockout
  if (user.lockoutUntil && user.lockoutUntil > new Date()) {
    const minutesLeft = Math.ceil((user.lockoutUntil - new Date()) / (1000 * 60));
    throw new ApiError(429, `Account is locked due to multiple failed login attempts. Try again in ${minutesLeft} minutes.`);
  }

  const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

  if (!isPasswordValid) {
    user.failedLoginAttempts += 1;
    if (user.failedLoginAttempts >= 5) {
      user.lockoutUntil = new Date(Date.now() + 15 * 60 * 1000); // 15 min cooldown
    }
    await user.save();
    throw new ApiError(401, 'Invalid email or password');
  }

  if (!user.isActive) {
    throw new ApiError(403, 'Account is deactivated');
  }

  // Reset failed login attempts on successful login
  user.failedLoginAttempts = 0;
  user.lockoutUntil = null;
  await user.save();

  const accessToken = TokenService.generateAccessToken(user);
  const refreshToken = await TokenService.generateRefreshToken(user._id);

  res.status(200).json({
    success: true,
    message: 'Login successful',
    data: {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role
      },
      tokens: {
        accessToken,
        refreshToken
      }
    }
  });
});

export const refresh = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;
  const { userId, newRefreshToken } = await TokenService.rotateRefreshToken(refreshToken);

  const user = await User.findById(userId);
  if (!user || !user.isActive) {
    throw new ApiError(401, 'User account is invalid or inactive');
  }

  const newAccessToken = TokenService.generateAccessToken(user);

  res.status(200).json({
    success: true,
    message: 'Tokens refreshed successfully',
    data: {
      tokens: {
        accessToken: newAccessToken,
        refreshToken: newRefreshToken
      }
    }
  });
});

export const logout = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;
  if (refreshToken) {
    await TokenService.revokeToken(refreshToken);
  }
  res.status(200).json({
    success: true,
    message: 'Logged out successfully'
  });
});

export const getMe = asyncHandler(async (req, res) => {
  res.status(200).json({
    success: true,
    data: {
      user: req.user
    }
  });
});
