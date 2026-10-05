import app from '../event-booking-api/src/app.js';
import { connectDB } from '../event-booking-api/src/config/db.js';

export default async function handler(req, res) {
  try {
    let targetPath = '';

    if (req.url && req.url.includes('/health')) {
      targetPath = '/health';
    } else if (req.query && req.query.path) {
      targetPath = `/api/${req.query.path}`;
    } else if (req.headers && req.headers['x-forwarded-uri']) {
      targetPath = req.headers['x-forwarded-uri'];
    } else if (req.headers && req.headers['x-matched-path']) {
      targetPath = req.headers['x-matched-path'];
    } else {
      targetPath = req.url || '';
    }

    targetPath = targetPath.split('?')[0];
    if (!targetPath.startsWith('/api') && targetPath !== '/health') {
      targetPath = `/api/${targetPath.replace(/^\/+/, '')}`;
    }

    req.url = targetPath;
    req.originalUrl = targetPath;
    delete req._parsedUrl;
    delete req._parsedUrlUrl;

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
