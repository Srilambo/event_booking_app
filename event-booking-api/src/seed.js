import bcrypt from 'bcryptjs';
import { connectDB, disconnectDB } from './config/db.js';
import { User } from './models/User.js';
import { Event } from './models/Event.js';
import { Booking } from './models/Booking.js';
import { generateBookingCode } from './utils/generateCode.js';

export const seedDatabase = async ({ isAutoSeed = false } = {}) => {
  if (!isAutoSeed) {
    await connectDB();
  }
  const userCount = await User.countDocuments();
  if (isAutoSeed && userCount > 0) return;

  console.log('🧹 Clearing existing data...');
  await User.deleteMany({});
  await Event.deleteMany({});
  await Booking.deleteMany({});

  const passwordHash = await bcrypt.hash('Password123!', 12);

  console.log('👤 Creating users (Admin, Organizer, Regular User)...');
  const admin = await User.create({
    name: 'System Admin',
    email: 'admin@eventbook.com',
    passwordHash,
    role: 'admin',
    isActive: true
  });

  const organizer = await User.create({
    name: 'Sarah Jenkins (Organizer)',
    email: 'organizer@eventbook.com',
    passwordHash,
    role: 'organizer',
    isActive: true
  });

  const user1 = await User.create({
    name: 'Alex Johnson',
    email: 'user@eventbook.com',
    passwordHash,
    role: 'user',
    isActive: true
  });

  const sampleEvents = [
    {
      title: 'Global Tech Summit 2026',
      description: 'Join industry leaders and tech pioneers discussing AI, Cloud Computing, and the future of web architecture.',
      category: 'Tech',
      imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=800&q=80',
      venue: 'Metropolitan Convention Center',
      city: 'New York',
      startDate: new Date(Date.now() + 10 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 12 * 24 * 60 * 60 * 1000),
      price: 299,
      totalSeats: 200,
      availableSeats: 195,
      status: 'published',
      createdBy: organizer._id
    },
    {
      title: 'Neon Nights Music Festival',
      description: 'An extraordinary night of electronic music, visuals, live performances, and world-renowned DJs.',
      category: 'Music',
      imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=800&q=80',
      venue: 'Sunset Arena',
      city: 'Los Angeles',
      startDate: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 16 * 24 * 60 * 60 * 1000),
      price: 150,
      totalSeats: 500,
      availableSeats: 480,
      status: 'published',
      createdBy: organizer._id
    },
    {
      title: 'International Modern Art Expo',
      description: 'Explore contemporary digital artworks, sculptures, and interactive installations by top international artists.',
      category: 'Arts',
      imageUrl: 'https://images.unsplash.com/photo-1561214115-f2f134cc4912?auto=format&fit=crop&w=800&q=80',
      venue: 'Grand Gallery of Fine Arts',
      city: 'Chicago',
      startDate: new Date(Date.now() + 20 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 22 * 24 * 60 * 60 * 1000),
      price: 45,
      totalSeats: 150,
      availableSeats: 140,
      status: 'published',
      createdBy: organizer._id
    },
    {
      title: 'Startup Pitch & Venture Gala',
      description: 'Watch top 20 startups pitch live to venture capitalists, angel investors, and tech executives.',
      category: 'Business',
      imageUrl: 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&w=800&q=80',
      venue: 'Silicon Innovation Hub',
      city: 'San Francisco',
      startDate: new Date(Date.now() + 25 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 25 * 24 * 60 * 60 * 1000 + 8 * 3600 * 1000),
      price: 199,
      totalSeats: 100,
      availableSeats: 90,
      status: 'published',
      createdBy: admin._id
    },
    {
      title: 'Artisan Food & Wine Festival',
      description: 'Savor gourmet creations from award-winning chefs paired with premium wines from famous vineyards.',
      category: 'Food',
      imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
      venue: 'Waterfront Pavilion',
      city: 'Seattle',
      startDate: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      price: 85,
      totalSeats: 300,
      availableSeats: 290,
      status: 'published',
      createdBy: organizer._id
    },
    {
      title: 'National Marathon & Fitness Expo',
      description: 'Annual city marathon featuring runners from across the globe, fitness workshops, and health expos.',
      category: 'Sports',
      imageUrl: 'https://images.unsplash.com/photo-1530549387789-4c1017266635?auto=format&fit=crop&w=800&q=80',
      venue: 'Central Park Stadium',
      city: 'Austin',
      startDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 31 * 24 * 60 * 60 * 1000),
      price: 60,
      totalSeats: 1000,
      availableSeats: 950,
      status: 'published',
      createdBy: admin._id
    },
    {
      title: 'AI & Machine Learning Deep Dive',
      description: 'Hands-on workshop covering Large Language Models, PyTorch, Transformers, and scalable MLOps.',
      category: 'Tech',
      imageUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=800&q=80',
      venue: 'TechWorks Auditorium',
      city: 'Boston',
      startDate: new Date(Date.now() + 18 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 19 * 24 * 60 * 60 * 1000),
      price: 350,
      totalSeats: 80,
      availableSeats: 75,
      status: 'published',
      createdBy: organizer._id
    },
    {
      title: 'Symphony Orchestra under the Stars',
      description: 'An enchanting evening of classical masterpieces performed live by the Philharmonic Orchestra in an open amphitheater.',
      category: 'Music',
      imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=800&q=80',
      venue: 'Open Air Amphitheater',
      city: 'Denver',
      startDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000 + 4 * 3600 * 1000),
      price: 120,
      totalSeats: 400,
      availableSeats: 380,
      status: 'published',
      createdBy: organizer._id
    },
    {
      title: 'Indie Film & VR Showcase',
      description: 'Screenings of ground-breaking independent feature films, documentaries, and immersive virtual reality experiences.',
      category: 'Arts',
      imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=800&q=80',
      venue: 'Starlight Cinema House',
      city: 'Portland',
      startDate: new Date(Date.now() + 22 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 24 * 24 * 60 * 60 * 1000),
      price: 50,
      totalSeats: 120,
      availableSeats: 110,
      status: 'published',
      createdBy: organizer._id
    },
    {
      title: 'Leadership & Executive Masterclass',
      description: 'Intensive one-day executive retreat focusing on modern management strategy, scaling teams, and corporate culture.',
      category: 'Business',
      imageUrl: 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=800&q=80',
      venue: 'Grand Plaza Hotel',
      city: 'Chicago',
      startDate: new Date(Date.now() + 28 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 28 * 24 * 60 * 60 * 1000 + 9 * 3600 * 1000),
      price: 499,
      totalSeats: 50,
      availableSeats: 45,
      status: 'published',
      createdBy: admin._id
    },
    {
      title: 'Craft Beer & Food Truck Fest',
      description: 'Over 50 local microbreweries and top street food vendors gather for a weekend of live music and tasting.',
      category: 'Food',
      imageUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?auto=format&fit=crop&w=800&q=80',
      venue: 'Riverside Park Grounds',
      city: 'San Diego',
      startDate: new Date(Date.now() + 8 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 9 * 24 * 60 * 60 * 1000),
      price: 35,
      totalSeats: 600,
      availableSeats: 580,
      status: 'published',
      createdBy: organizer._id
    },
    {
      title: 'Extreme Sports & BMX Championship',
      description: 'Witness thrilling BMX stunts, skateboarding tricks, and motocross high-flying action in a packed stadium.',
      category: 'Sports',
      imageUrl: 'https://images.unsplash.com/photo-1565992441121-4367c2967103?auto=format&fit=crop&w=800&q=80',
      venue: 'X-Arena Stadium',
      city: 'Miami',
      startDate: new Date(Date.now() + 35 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 36 * 24 * 60 * 60 * 1000),
      price: 75,
      totalSeats: 800,
      availableSeats: 760,
      status: 'published',
      createdBy: admin._id
    },
    {
      title: 'Cybersecurity & Ethical Hacking Summit',
      description: 'Deep dive into zero-day exploits, cloud security, penetration testing, and defense strategies.',
      category: 'Tech',
      imageUrl: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=800&q=80',
      venue: 'Cyber Security Institute',
      city: 'Washington D.C.',
      startDate: new Date(Date.now() + 40 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 41 * 24 * 60 * 60 * 1000),
      price: 250,
      totalSeats: 150,
      availableSeats: 145,
      status: 'published',
      createdBy: organizer._id
    },
    {
      title: 'Jazz & Blues Autumn Session',
      description: 'Smooth jazz melodies, soul rhythms, and acoustic blues performed by legendary artists in an intimate hall.',
      category: 'Music',
      imageUrl: 'https://images.unsplash.com/photo-1511192336575-5a79af67a629?auto=format&fit=crop&w=800&q=80',
      venue: 'Blue Note Lounge',
      city: 'New Orleans',
      startDate: new Date(Date.now() + 12 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 12 * 24 * 60 * 60 * 1000 + 5 * 3600 * 1000),
      price: 90,
      totalSeats: 100,
      availableSeats: 95,
      status: 'published',
      createdBy: organizer._id
    },
    {
      title: 'Exclusive Organizer Conference (Draft)',
      description: 'Internal planning session for upcoming summer festival line-up and venue logistics.',
      category: 'General',
      imageUrl: 'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?auto=format&fit=crop&w=800&q=80',
      venue: 'Organizer HQ Room 3B',
      city: 'New York',
      startDate: new Date(Date.now() + 45 * 24 * 60 * 60 * 1000),
      endDate: new Date(Date.now() + 45 * 24 * 60 * 60 * 1000 + 3 * 3600 * 1000),
      price: 0,
      totalSeats: 30,
      availableSeats: 30,
      status: 'draft',
      createdBy: organizer._id
    }
  ];

  console.log('🎉 Seeding 15 sample events...');
  const createdEvents = await Event.insertMany(sampleEvents);

  console.log('🎟️ Creating sample booking...');
  await Booking.create({
    user: user1._id,
    event: createdEvents[0]._id,
    quantity: 2,
    totalPrice: createdEvents[0].price * 2,
    bookingCode: generateBookingCode(),
    status: 'confirmed'
  });

  console.log('✅ Database seeded successfully!');
  console.log('\n--- Test Credentials ---');
  console.log('Admin User:      admin@eventbook.com / Password123!');
  console.log('Organizer User:  organizer@eventbook.com / Password123!');
  console.log('Regular User:    user@eventbook.com / Password123!');
  console.log('-------------------------\n');

  if (!isAutoSeed) {
    await disconnectDB();
  }
};

if (process.argv[1] && import.meta.url === `file:///${process.argv[1].replace(/\\/g, '/')}`) {
  seedDatabase().catch((err) => {
    console.error('Failed to seed database:', err);
    process.exit(1);
  });
}
