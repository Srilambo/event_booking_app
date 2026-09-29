import mongoose from 'mongoose';
import { config } from './env.js';

let memServer = null;

export const connectDB = async () => {
  if (mongoose.connection.readyState >= 1) return;

  try {
    // Attempt connecting to the configured URI
    await mongoose.connect(config.mongoUri, {
      serverSelectionTimeoutMS: 3000
    });
    console.log(`[Database] Connected to MongoDB at ${config.mongoUri}`);
  } catch (err) {
    console.warn(`[Database] Native MongoDB connection failed (${err.message}). Starting MongoMemoryServer fallback...`);
    try {
      const { MongoMemoryServer } = await import('mongodb-memory-server');
      memServer = await MongoMemoryServer.create();
      const memUri = memServer.getUri();
      await mongoose.connect(memUri);
      console.log(`[Database] Connected to MongoMemoryServer at ${memUri}`);
    } catch (memErr) {
      console.error('[Database] Failed to start MongoMemoryServer:', memErr);
      process.exit(1);
    }
  }

  // Auto-seed initial sample data if the database is currently empty
  try {
    const { seedDatabase } = await import('../seed.js');
    await seedDatabase({ isAutoSeed: true });
  } catch (seedErr) {
    console.warn('[Database] Auto-seed skip / non-critical error:', seedErr.message);
  }
};

export const disconnectDB = async () => {
  if (mongoose.connection.readyState !== 0) {
    await mongoose.disconnect();
  }
  if (memServer) {
    await memServer.stop();
  }
};
