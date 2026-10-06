import app from './event-booking-api/src/app.js';
import { connectDB } from './event-booking-api/src/config/db.js';

let isConnected = false;

export default async function handler(req, res) {
  if (!isConnected) {
    try {
      await connectDB();
      isConnected = true;
    } catch (err) {
      console.error('[DB] Connection error:', err.message);
    }
  }
  return app(req, res);
}

export { app };
