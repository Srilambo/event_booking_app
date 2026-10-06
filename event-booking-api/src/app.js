import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import mongoSanitize from 'express-mongo-sanitize';
import hpp from 'hpp';
import compression from 'compression';
import morgan from 'morgan';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { config } from './config/env.js';
import { globalLimiter } from './middleware/rateLimit.js';
import { errorHandler } from './middleware/errorHandler.js';

import authRoutes from './routes/auth.routes.js';
import eventRoutes from './routes/event.routes.js';
import bookingRoutes from './routes/booking.routes.js';
import adminRoutes from './routes/admin.routes.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const publicPath = path.resolve(__dirname, '../../public');
const flutterBuildPath = path.resolve(__dirname, '../../event_booking_app/build/web');
const webBuildPath = fs.existsSync(publicPath) ? publicPath : flutterBuildPath;

const app = express();

// Serverless response compatibility middleware
app.use((req, res, next) => {
  if (res && !res._headers) res._headers = {};
  if (res && !res._headerNames) res._headerNames = {};
  if (!req.socket) req.socket = {};
  if (!req.socket.remoteAddress) req.socket.remoteAddress = (req.headers && req.headers['x-forwarded-for']) || '127.0.0.1';
  if (!req.connection) req.connection = req.socket;
  if (req.query && req.query.url) {
    req.url = req.query.url;
  } else if (req.query && req.query.path && !req.url.startsWith('/api/v1')) {
    req.url = `/api/${req.query.path}`;
  }
  next();
});

app.disable('x-powered-by');
app.set('trust proxy', 1);

// Security Middlewares
if (!process.env.VERCEL) {
  app.use(helmet({
    contentSecurityPolicy: false
  }));
}

app.use(cors({
  origin: (origin, callback) => {
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

// Static Web App Serving
if (fs.existsSync(webBuildPath)) {
  app.use(express.static(webBuildPath));
  app.get('*', (req, res, next) => {
    if (req.path.startsWith('/api') || req.path === '/health') {
      return next();
    }
    const indexPath = path.join(webBuildPath, 'index.html');
    if (fs.existsSync(indexPath)) {
      return res.sendFile(indexPath);
    }
    next();
  });
}

// 404 Handler
app.use((req, res, next) => {
  res.status(404).json({ success: false, message: `Route ${req.originalUrl} not found` });
});

// Centralized Error Handler
app.use(errorHandler);

export default app;
