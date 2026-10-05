import app from '../src/app.js';
import { connectDB } from '../src/config/db.js';

export default async function handler(req, res) {
  try {
    let rawUrl = req.url || '';
    
    if (rawUrl.includes('/health')) {
      req.url = '/health';
    } else {
      let subPath = '';
      if (req.query && req.query['0']) {
        subPath = req.query['0'];
      } else if (req.headers && req.headers['x-forwarded-uri']) {
        subPath = req.headers['x-forwarded-uri'];
      } else if (req.headers && req.headers['x-matched-path']) {
        subPath = req.headers['x-matched-path'];
      } else {
        subPath = rawUrl;
      }

      const cleanSub = subPath.split('?')[0];
      if (cleanSub.startsWith('/api/')) {
        req.url = subPath;
      } else if (cleanSub.startsWith('api/')) {
        req.url = `/${subPath}`;
      } else {
        req.url = `/api/${cleanSub.replace(/^\/+/, '')}`;
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
