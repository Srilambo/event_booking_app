import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import mongoSanitize from 'express-mongo-sanitize';
import hpp from 'hpp';
import compression from 'compression';
import morgan from 'morgan';
import { config } from './config/env.js';
import { globalLimiter } from './middleware/rateLimit.js';
import { errorHandler } from './middleware/errorHandler.js';

import authRoutes from './routes/auth.routes.js';
import eventRoutes from './routes/event.routes.js';
import bookingRoutes from './routes/booking.routes.js';
import adminRoutes from './routes/admin.routes.js';

const app = express();

// Serverless response compatibility and path normalization middleware
app.use((req, res, next) => {
  if (res && !res._headers) res._headers = {};
  if (res && !res._headerNames) res._headerNames = {};
  const forwardedUri = req.headers['x-forwarded-uri'] || req.headers['x-matched-path'];
  if (forwardedUri && forwardedUri !== '/event-booking-api/api/index.js' && !forwardedUri.includes('/api/index.js')) {
    req.url = forwardedUri;
  }
  next();
});

app.disable('x-powered-by');
app.set('trust proxy', 1);

// Security Middlewares
if (!process.env.VERCEL) {
  app.use(helmet({
    contentSecurityPolicy: false // Disable CSP for API backend
  }));
}

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (mobile apps, curl)
    if (!origin) return callback(null, true);
    if (
      config.allowedOrigins.includes(origin) ||
      config.env === 'development' ||
      origin.endsWith('.vercel.app') ||
      process.env.VERCEL
    ) {
      return callback(null, true);
    }
    return callback(new Error('Not allowed by CORS'));
  },
  credentials: true
}));

app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true, limit: '10kb' }));

// NoSQL Injection & Parameter Pollution Protection
app.use(mongoSanitize());
app.use(hpp());
app.use(compression());

if (config.env === 'development') {
  app.use(morgan('dev'));
}

// Global Rate Limiter
app.use('/api', globalLimiter);

// Health Check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/events', eventRoutes);
app.use('/api/v1/bookings', bookingRoutes);
app.use('/api/v1/admin', adminRoutes);

// 404 Handler
app.use((req, res, next) => {
  res.status(404).json({ success: false, message: `Route ${req.originalUrl} not found` });
});

// Centralized Error Handler
app.use(errorHandler);

export default app;
