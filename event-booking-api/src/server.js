import app from './app.js';
import { connectDB } from './config/db.js';
import { config } from './config/env.js';

const startServer = async () => {
  await connectDB();
  const server = app.listen(config.port, () => {
    console.log(`🚀 [Server] Event Booking API running on port ${config.port} in ${config.env} mode`);
  });

  process.on('unhandledRejection', (err) => {
    console.error('Unhandled Promise Rejection:', err);
    server.close(() => process.exit(1));
  });
};

startServer();
