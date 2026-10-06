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

  console.log('🧹 Cleaning up old sample & demo data...');
  // Clear any existing sample events or US dummy data
  await Event.deleteMany({
    $or: [
      { isSample: true },
      { city: { $in: ['Seattle', 'Chicago', 'New York', 'Los Angeles', 'San Francisco', 'Austin', 'Boston', 'Denver', 'Portland', 'San Diego', 'Miami', 'Washington D.C.'] } }
    ]
  });

  const userCount = await User.countDocuments();
  let admin, organizer, user1;

  if (userCount === 0) {
    console.log('👤 Creating initial system users...');
    const passwordHash = await bcrypt.hash('Password123!', 12);

    admin = await User.create({
      name: 'System Admin',
      email: 'admin@eventbook.com',
      passwordHash,
      role: 'admin',
      isActive: true
    });

    organizer = await User.create({
      name: 'Ceylon Events (Organizer)',
      email: 'organizer@eventbook.com',
      passwordHash,
      role: 'organizer',
      isActive: true
    });

    user1 = await User.create({
      name: 'Kavindu Perera',
      email: 'user@eventbook.com',
      passwordHash,
      role: 'user',
      isActive: true
    });
  } else {
    admin = await User.findOne({ role: 'admin' }) || await User.findOne();
    organizer = await User.findOne({ role: 'organizer' }) || admin;
    user1 = await User.findOne({ role: 'user' }) || admin;
  }

  const sriLankaEvents = [
    {
      title: 'Colombo Tech Expo 2026',
      description: 'Sri Lanka’s premier technology summit featuring AI breakthroughs, Cloud innovations, and cybersecurity trends.',
      category: 'Tech',
      imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=800&q=80',
      venueName: 'BMICH Main Exhibition Center',
      venue: 'BMICH Main Exhibition Center',
      city: 'Colombo',
      address: 'Bauddhaloka Mawatha, Colombo 00700',
      latitude: 6.9011,
      longitude: 79.8735,
      startDate: new Date('2026-10-15T09:00:00Z'),
      endDate: new Date('2026-10-17T18:00:00Z'),
      price: 3500,
      currency: 'LKR',
      totalSeats: 300,
      availableSeats: 280,
      organizerName: 'TechLanka Community',
      status: 'published',
      isSample: true,
      createdBy: organizer._id
    },
    {
      title: 'Sri Lanka Symphony & Classical Night',
      description: 'An enchanting evening of classical masterpieces performed live by the Symphony Orchestra of Sri Lanka.',
      category: 'Music',
      imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=800&q=80',
      venueName: 'Nelum Pokuna Mahinda Rajapaksa Theatre',
      venue: 'Nelum Pokuna Mahinda Rajapaksa Theatre',
      city: 'Colombo',
      address: '110 Ananda Coomaraswamy Mawatha, Colombo 00700',
      latitude: 6.9103,
      longitude: 79.8607,
      startDate: new Date('2026-10-20T19:00:00Z'),
      endDate: new Date('2026-10-20T22:00:00Z'),
      price: 7500,
      currency: 'LKR',
      totalSeats: 450,
      availableSeats: 410,
      organizerName: 'Ceylon Philharmonic Society',
      status: 'published',
      isSample: true,
      createdBy: organizer._id
    },
    {
      title: 'Galle Face Sunset Music Festival',
      description: 'Open-air oceanfront live music festival featuring top local bands, acoustic sets, and electronic DJs.',
      category: 'Music',
      imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=800&q=80',
      venueName: 'Galle Face Green Amphitheatre',
      venue: 'Galle Face Green Amphitheatre',
      city: 'Colombo',
      address: 'Galle Main Road, Colombo 00300',
      latitude: 6.9275,
      longitude: 79.8445,
      startDate: new Date('2026-11-05T16:00:00Z'),
      endDate: new Date('2026-11-06T23:00:00Z'),
      price: 4500,
      currency: 'LKR',
      totalSeats: 1000,
      availableSeats: 920,
      organizerName: 'Island Rhythms Ltd',
      status: 'published',
      isSample: true,
      createdBy: organizer._id
    },
    {
      title: 'Island Culinary & Street Food Fair',
      description: 'Celebrate authentic Sri Lankan flavors, traditional spices, seafood delicacies, and gourmet dessert stalls.',
      category: 'Food',
      imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
      venueName: 'Viharamahadevi Open Air Theatre',
      venue: 'Viharamahadevi Open Air Theatre',
      city: 'Colombo',
      address: 'Circular Road, Colombo 00700',
      latitude: 6.9130,
      longitude: 79.8617,
      startDate: new Date('2026-10-25T11:00:00Z'),
      endDate: new Date('2026-10-26T22:00:00Z'),
      price: 1500,
      currency: 'LKR',
      totalSeats: 600,
      availableSeats: 580,
      organizerName: 'Culinary Heritage Association',
      status: 'published',
      isSample: true,
      createdBy: organizer._id
    },
    {
      title: 'Lanka International Cricket Cup T20',
      description: 'High-octane T20 cricket action under the floodlights at R. Premadasa Stadium.',
      category: 'Sports',
      imageUrl: 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?auto=format&fit=crop&w=800&q=80',
      venueName: 'R. Premadasa Stadium',
      venue: 'R. Premadasa Stadium',
      city: 'Colombo',
      address: 'Khettarama Road, Maligawatta, Colombo 01000',
      latitude: 6.9392,
      longitude: 79.8711,
      startDate: new Date('2026-11-12T14:30:00Z'),
      endDate: new Date('2026-11-12T22:00:00Z'),
      price: 5000,
      currency: 'LKR',
      totalSeats: 1500,
      availableSeats: 1420,
      organizerName: 'Sri Lanka Cricket Board',
      status: 'published',
      isSample: true,
      createdBy: admin._id
    },
    {
      title: 'Colombo Lotus Tower Light & Art Show',
      description: 'Immersive digital projection mapping, modern sculptures, and panoramic night views from South Asia’s tallest tower.',
      category: 'Arts',
      imageUrl: 'https://images.unsplash.com/photo-1561214115-f2f134cc4912?auto=format&fit=crop&w=800&q=80',
      venueName: 'Lotus Tower Observation Deck & Grounds',
      venue: 'Lotus Tower Observation Deck & Grounds',
      city: 'Colombo',
      address: 'AC6, D.R. Wijewardena Mawatha, Colombo 01000',
      latitude: 6.9271,
      longitude: 79.8578,
      startDate: new Date('2026-10-30T18:00:00Z'),
      endDate: new Date('2026-11-01T22:00:00Z'),
      price: 2500,
      currency: 'LKR',
      totalSeats: 500,
      availableSeats: 470,
      organizerName: 'Colombo Arts Council',
      status: 'published',
      isSample: true,
      createdBy: organizer._id
    },
    {
      title: 'Kandy Cultural Heritage & Dance Festival',
      description: 'Experience traditional Kandyan drumming, fire dancing, and intricate costumes in the sacred hill capital.',
      category: 'Arts',
      imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=800&q=80',
      venueName: 'Kandy City Centre Plaza',
      venue: 'Kandy City Centre Plaza',
      city: 'Kandy',
      address: '5 Dalada Veediya, Kandy 20000',
      latitude: 7.2936,
      longitude: 80.6382,
      startDate: new Date('2026-11-18T17:00:00Z'),
      endDate: new Date('2026-11-18T21:30:00Z'),
      price: 3000,
      currency: 'LKR',
      totalSeats: 350,
      availableSeats: 330,
      organizerName: 'Hill Country Heritage Guild',
      status: 'published',
      isSample: true,
      createdBy: organizer._id
    },
    {
      title: 'Galle Fort Literary & Art Gala',
      description: 'A historic celebration of literature, poetry readings, photography exhibits, and coastal heritage inside Galle Fort.',
      category: 'Arts',
      imageUrl: 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&w=800&q=80',
      venueName: 'Galle Fort Cultural Grounds',
      venue: 'Galle Fort Cultural Grounds',
      city: 'Galle',
      address: 'Church Street, Galle 80000',
      latitude: 6.0267,
      longitude: 80.2170,
      startDate: new Date('2026-11-25T10:00:00Z'),
      endDate: new Date('2026-11-27T18:00:00Z'),
      price: 6000,
      currency: 'LKR',
      totalSeats: 250,
      availableSeats: 235,
      organizerName: 'Southern Arts Foundation',
      status: 'published',
      isSample: true,
      createdBy: organizer._id
    },
    {
      title: 'National Athletics & Track Championship',
      description: 'Sri Lanka’s top track and field athletes compete for national honors and international championship spots.',
      category: 'Sports',
      imageUrl: 'https://images.unsplash.com/photo-1530549387789-4c1017266635?auto=format&fit=crop&w=800&q=80',
      venueName: 'Sugathadasa Outdoor Stadium',
      venue: 'Sugathadasa Outdoor Stadium',
      city: 'Colombo',
      address: 'Sugathadasa Sports Complex, Colombo 01300',
      latitude: 6.9442,
      longitude: 79.8660,
      startDate: new Date('2026-12-02T08:00:00Z'),
      endDate: new Date('2026-12-04T18:00:00Z'),
      price: 2000,
      currency: 'LKR',
      totalSeats: 800,
      availableSeats: 760,
      organizerName: 'Sri Lanka Athletics Association',
      status: 'published',
      isSample: true,
      createdBy: admin._id
    },
    {
      title: 'Lanka Startup & Venture Forum',
      description: 'Pitching gala connecting high-growth Sri Lankan startups with global venture capitalists and angel networks.',
      category: 'Business',
      imageUrl: 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=800&q=80',
      venueName: 'BMICH Lotus Hall',
      venue: 'BMICH Lotus Hall',
      city: 'Colombo',
      address: 'Bauddhaloka Mawatha, Colombo 00700',
      latitude: 6.9011,
      longitude: 79.8735,
      startDate: new Date('2026-12-08T09:00:00Z'),
      endDate: new Date('2026-12-08T17:00:00Z'),
      price: 12000,
      currency: 'LKR',
      totalSeats: 150,
      availableSeats: 140,
      organizerName: 'Lanka Venture Capital Network',
      status: 'published',
      isSample: true,
      createdBy: admin._id
    },
    {
      title: 'AI & Web Architecture Masterclass',
      description: 'Hands-on intensive workshop building resilient microservices and AI agent integrations in Colombo.',
      category: 'Tech',
      imageUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=800&q=80',
      venueName: 'Hatch Works Colombo',
      venue: 'Hatch Works Colombo',
      city: 'Colombo',
      address: '14 Baron Jayathilaka Mawatha, Colombo 00100',
      latitude: 6.9344,
      longitude: 79.8436,
      startDate: new Date('2026-12-12T09:30:00Z'),
      endDate: new Date('2026-12-13T16:30:00Z'),
      price: 8500,
      currency: 'LKR',
      totalSeats: 80,
      availableSeats: 72,
      organizerName: 'DevLanka Academy',
      status: 'published',
      isSample: true,
      createdBy: organizer._id
    },
    {
      title: 'Southern Coastal Beach Volleyball Open',
      description: 'Competitive beach volleyball tournament on the golden sands outside historic Galle Fort.',
      category: 'Sports',
      imageUrl: 'https://images.unsplash.com/photo-1565992441121-4367c2967103?auto=format&fit=crop&w=800&q=80',
      venueName: 'Galle Fort Beach Stadium',
      venue: 'Galle Fort Beach Stadium',
      city: 'Galle',
      address: 'Rampart Street, Galle 80000',
      latitude: 6.0280,
      longitude: 80.2155,
      startDate: new Date('2026-12-18T08:30:00Z'),
      endDate: new Date('2026-12-20T17:00:00Z'),
      price: 1800,
      currency: 'LKR',
      totalSeats: 400,
      availableSeats: 380,
      organizerName: 'Southern Sports Club',
      status: 'published',
      isSample: true,
      createdBy: organizer._id
    },
    {
      title: 'Kandy Hill Capital Tech Summit',
      description: 'Exploring remote work hubs, green technology, and digital transformation in Central Province.',
      category: 'Tech',
      imageUrl: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=800&q=80',
      venueName: 'Kandy City Centre Auditorium',
      venue: 'Kandy City Centre Auditorium',
      city: 'Kandy',
      address: 'Sri Dalada Veediya, Kandy 20000',
      latitude: 7.2940,
      longitude: 80.6375,
      startDate: new Date('2026-12-22T09:00:00Z'),
      endDate: new Date('2026-12-22T17:00:00Z'),
      price: 4000,
      currency: 'LKR',
      totalSeats: 200,
      availableSeats: 190,
      organizerName: 'Kandy Tech Hub',
      status: 'published',
      isSample: true,
      createdBy: organizer._id
    },
    {
      title: 'Ceylon Spice & Tea Gala Dinner',
      description: 'Exclusive 5-course gala dinner pairing Ceylon single-origin teas and organic spiced cuisine.',
      category: 'Food',
      imageUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?auto=format&fit=crop&w=800&q=80',
      venueName: 'Cinnamon Grand Colombo Ballroom',
      venue: 'Cinnamon Grand Colombo Ballroom',
      city: 'Colombo',
      address: '77 Galle Road, Colombo 00300',
      latitude: 6.9178,
      longitude: 79.8488,
      startDate: new Date('2026-12-28T19:00:00Z'),
      endDate: new Date('2026-12-28T23:00:00Z'),
      price: 15000,
      currency: 'LKR',
      totalSeats: 120,
      availableSeats: 110,
      organizerName: 'Ceylon Tea Exporters Guild',
      status: 'published',
      isSample: true,
      createdBy: organizer._id
    }
  ];

  console.log(`🎉 Seeding ${sriLankaEvents.length} Sri Lanka events...`);
  const createdEvents = await Event.insertMany(sriLankaEvents);

  if (!isAutoSeed) {
    const existingBookings = await Booking.countDocuments();
    if (existingBookings === 0 && createdEvents.length > 0) {
      console.log('🎟️ Creating sample booking for testing...');
      await Booking.create({
        user: user1._id,
        event: createdEvents[0]._id,
        quantity: 2,
        totalPrice: createdEvents[0].price * 2,
        bookingCode: generateBookingCode(),
        status: 'confirmed'
      });
    }
  }

  console.log('✅ Database seeded with Sri Lanka events successfully!');
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
