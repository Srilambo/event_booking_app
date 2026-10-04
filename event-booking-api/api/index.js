import app from '../src/app.js';
import { connectDB } from '../src/config/db.js';

export default async function handler(req, res) {
  try {
    if (req.query && req.query.health) {
      req.url = '/health';
    } else if (req.query && req.query['0']) {
      req.url = req.query['0'].startsWith('/') ? req.query['0'] : `/api/${req.query['0']}`;
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
