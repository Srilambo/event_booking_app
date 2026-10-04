import app from '../event-booking-api/src/app.js';
import { connectDB } from '../event-booking-api/src/config/db.js';

export default async function handler(req, res) {
  try {
    // Preserve original path if rewritten to /api
    const realPath = req.headers['x-forwarded-uri'] || req.headers['x-matched-path'];
    if (realPath && realPath !== '/api' && !req.url.startsWith('/api/v1') && req.url !== '/health') {
      req.url = realPath;
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
