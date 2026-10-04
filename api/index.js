import app from '../event-booking-api/src/app.js';
import { connectDB } from '../event-booking-api/src/config/db.js';

export default async function handler(req, res) {
  try {
    if (req.url && req.url.includes('/health')) {
      req.url = '/health';
    } else if (req.query && req.query['0']) {
      const sub = req.query['0'];
      req.url = sub.startsWith('/') ? sub : `/api/${sub}`;
    } else if (req.headers && (req.headers['x-matched-path'] || req.headers['x-forwarded-uri'])) {
      const target = req.headers['x-matched-path'] || req.headers['x-forwarded-uri'];
      if (target && target.startsWith('/api')) {
        req.url = target;
      }
    }

    await connectDB();
    return app(req, res);
  } catch (error) {
    console.error('[Vercel Serverless Handler] Error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: error.message
    });
  }
}
