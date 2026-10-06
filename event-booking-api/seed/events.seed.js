import { seedDatabase } from '../src/seed.js';

seedDatabase()
  .then(() => {
    console.log('✅ Seed process complete (events.seed.js).');
    process.exit(0);
  })
  .catch((err) => {
    console.error('❌ Seed error:', err);
    process.exit(1);
  });
