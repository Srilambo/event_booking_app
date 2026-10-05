import app from '../event-booking-api/src/app.js';
import { connectDB } from '../event-booking-api/src/config/db.js';

export default async function handler(req, res) {
  try {
    let rawUrl = req.url || '';
    if (rawUrl.includes('/health')) {
      req.url = '/health';
    } else if (!rawUrl.startsWith('/api')) {
      req.url = `/api${rawUrl.startsWith('/') ? '' : '/'}${rawUrl}`;
    }

    req.originalUrl = req.url;
    delete req._parsedUrl;
    delete req._parsedUrlUrl;
    delete req._parsedUrlOriginal;

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
