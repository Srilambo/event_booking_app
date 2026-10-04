import app from '../src/app.js';
import { connectDB } from '../src/config/db.js';

export default async function handler(req, res) {
  try {
    const originalPath = req.headers['x-forwarded-uri'] || req.headers['x-matched-path'];
    if (originalPath && originalPath !== '/api') {
      req.url = originalPath;
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
