import app from '../src/app.js';
import { connectDB } from '../src/config/db.js';

export default async function handler(req, res) {
  try {
    if (req.url && req.url.includes('/health')) {
      req.url = '/health';
    } else if (req.query && req.query['0']) {
      const subpath = req.query['0'];
      req.url = subpath.startsWith('/') ? subpath : `/api/${subpath}`;
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
