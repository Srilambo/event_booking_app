import { spawn } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');

console.log('\x1b[36m%s\x1b[0m', '🚀 Launching Event Booking App (Backend API + Flutter Frontend)...');

// 1. Spawn Backend API Server
const backendProcess = spawn('npm', ['run', 'dev'], {
  cwd: path.join(rootDir, 'event-booking-api'),
  shell: true,
  stdio: 'inherit',
});

// 2. Spawn Flutter Web Frontend
const frontendProcess = spawn('flutter', ['run', '-d', 'chrome'], {
  cwd: path.join(rootDir, 'event_booking_app'),
  shell: true,
  stdio: 'inherit',
});

// Handle graceful termination on Ctrl+C
const cleanup = () => {
  console.log('\n\x1b[33m%s\x1b[0m', '🛑 Shutting down backend & frontend development servers...');
  backendProcess.kill('SIGINT');
  frontendProcess.kill('SIGINT');
  process.exit(0);
};

process.on('SIGINT', cleanup);
process.on('SIGTERM', cleanup);
