import app from '../event-booking-api/src/app.js';
import { connectDB } from '../event-booking-api/src/config/db.js';

export default async function handler(req, res) {
  try {
    const urlObj = new URL(req.url, 'http://localhost');
    const pathParam = urlObj.searchParams.get('path');
    if (pathParam) {
      req.url = pathParam;
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
