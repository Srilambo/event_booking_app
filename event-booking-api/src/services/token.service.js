import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { config } from '../config/env.js';
import { RefreshToken } from '../models/RefreshToken.js';
import { ApiError } from '../utils/ApiError.js';

export class TokenService {
  static hashToken(rawToken) {
    return crypto.createHash('sha256').update(rawToken).digest('hex');
  }

  static generateAccessToken(user) {
    const payload = {
      sub: user._id.toString(),
      role: user.role
    };
    return jwt.sign(payload, config.jwtSecret, {
      expiresIn: config.jwtExpiresIn
    });
  }

  static verifyAccessToken(token) {
    try {
      return jwt.verify(token, config.jwtSecret);
    } catch (err) {
      throw new ApiError(401, 'Invalid or expired access token');
    }
  }

  static async generateRefreshToken(userId) {
    const rawToken = crypto.randomBytes(40).toString('hex');
    const tokenHash = this.hashToken(rawToken);
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + config.refreshTokenExpiresInDays);

    await RefreshToken.create({
      user: userId,
      tokenHash,
      expiresAt
    });

    return rawToken;
  }

  static async rotateRefreshToken(rawToken) {
    const tokenHash = this.hashToken(rawToken);
    const storedToken = await RefreshToken.findOne({ tokenHash });

    if (!storedToken) {
      throw new ApiError(401, 'Invalid refresh token');
    }

    // Check if token was already revoked (Reuse Detection)
    if (storedToken.revokedAt) {
      // SECURITY: Stolen token reuse detected! Revoke ALL tokens for this user immediately!
      await RefreshToken.updateMany(
        { user: storedToken.user },
        { $set: { revokedAt: new Date() } }
      );
      throw new ApiError(401, 'Refresh token reuse detected. All sessions revoked for security.');
    }

    // Check if expired
    if (new Date() > storedToken.expiresAt) {
      storedToken.revokedAt = new Date();
      await storedToken.save();
      throw new ApiError(401, 'Refresh token has expired');
    }

    // Revoke current token and generate new pair
    const newRawRefreshToken = crypto.randomBytes(40).toString('hex');
    const newTokenHash = this.hashToken(newRawRefreshToken);
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + config.refreshTokenExpiresInDays);

    storedToken.revokedAt = new Date();
    storedToken.replacedByTokenHash = newTokenHash;
    await storedToken.save();

    await RefreshToken.create({
      user: storedToken.user,
      tokenHash: newTokenHash,
      expiresAt
    });

    return {
      userId: storedToken.user,
      newRefreshToken: newRawRefreshToken
    };
  }

  static async revokeToken(rawToken) {
    const tokenHash = this.hashToken(rawToken);
    const storedToken = await RefreshToken.findOne({ tokenHash });
    if (storedToken) {
      storedToken.revokedAt = new Date();
      await storedToken.save();
    }
  }

  static async revokeAllUserTokens(userId) {
    await RefreshToken.updateMany(
      { user: userId },
      { $set: { revokedAt: new Date() } }
    );
  }
}
