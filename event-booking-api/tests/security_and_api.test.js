import request from 'supertest';
import { MongoMemoryServer } from 'mongodb-memory-server';
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import app from '../src/app.js';
import { User } from '../src/models/User.js';
import { Event } from '../src/models/Event.js';
import { Booking } from '../src/models/Booking.js';
import { RefreshToken } from '../src/models/RefreshToken.js';
import { TokenService } from '../src/services/token.service.js';

let mongoServer;
let adminToken, organizerToken, userToken, secondOrganizerToken, secondUserToken;
let adminUser, organizerUser, regularUser, secondOrganizerUser, secondUser;
let testEvent, draftEvent;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  const mongoUri = mongoServer.getUri();
  await mongoose.connect(mongoUri);

  const passwordHash = await bcrypt.hash('Password123!', 12);

  // Seed Users
  adminUser = await User.create({ name: 'Admin', email: 'admin@test.com', passwordHash, role: 'admin' });
  organizerUser = await User.create({ name: 'Org1', email: 'org1@test.com', passwordHash, role: 'organizer' });
  secondOrganizerUser = await User.create({ name: 'Org2', email: 'org2@test.com', passwordHash, role: 'organizer' });
  regularUser = await User.create({ name: 'User1', email: 'user1@test.com', passwordHash, role: 'user' });
  secondUser = await User.create({ name: 'User2', email: 'user2@test.com', passwordHash, role: 'user' });

  adminToken = TokenService.generateAccessToken(adminUser);
  organizerToken = TokenService.generateAccessToken(organizerUser);
  secondOrganizerToken = TokenService.generateAccessToken(secondOrganizerUser);
  userToken = TokenService.generateAccessToken(regularUser);
  secondUserToken = TokenService.generateAccessToken(secondUser);

  // Seed Events
  testEvent = await Event.create({
    title: 'Security Test Event',
    description: 'Testing event security and seat allocation',
    category: 'Tech',
    venue: 'Test Hall',
    city: 'Test City',
    startDate: new Date(Date.now() + 5 * 24 * 3600 * 1000),
    endDate: new Date(Date.now() + 6 * 24 * 3600 * 1000),
    price: 100,
    totalSeats: 5,
    availableSeats: 5,
    status: 'published',
    createdBy: organizerUser._id
  });

  draftEvent = await Event.create({
    title: 'Draft Private Event',
    description: 'Draft event not yet public',
    category: 'Tech',
    venue: 'Secret Room',
    city: 'Secret City',
    startDate: new Date(Date.now() + 10 * 24 * 3600 * 1000),
    endDate: new Date(Date.now() + 11 * 24 * 3600 * 1000),
    price: 50,
    totalSeats: 10,
    availableSeats: 10,
    status: 'draft',
    createdBy: organizerUser._id
  });
});

afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
});

describe('Security & RBAC Test Suite', () => {
  // Test 1: Unauthenticated access returns 401
  test('1. Unauthenticated access to protected route /api/v1/auth/me returns 401', async () => {
    const res = await request(app).get('/api/v1/auth/me');
    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });

  // Test 2: User calling admin/organizer route returns 403
  test('2. Regular user calling POST /api/v1/events returns 403 Forbidden', async () => {
    const res = await request(app)
      .post('/api/v1/events')
      .set('Authorization', `Bearer ${userToken}`)
      .send({
        title: 'Unauthorized Event',
        description: 'Should fail',
        category: 'Tech',
        venue: 'Hall',
        city: 'City',
        startDate: new Date(Date.now() + 86400000).toISOString(),
        endDate: new Date(Date.now() + 172800000).toISOString(),
        price: 50,
        totalSeats: 10
      });
    expect(res.status).toBe(403);
  });

  // Test 3: Organizer editing another organizer's event returns 403
  test('3. Organizer editing another organizer event returns 403', async () => {
    const res = await request(app)
      .put(`/api/v1/events/${testEvent._id}`)
      .set('Authorization', `Bearer ${secondOrganizerToken}`)
      .send({ title: 'Hacked Title' });
    expect(res.status).toBe(403);
  });

  // Test 4: User cancelling another user's booking returns 403/404
  test('4. User cancelling another user booking returns 403 IDOR protection', async () => {
    // Create booking for regularUser
    const createRes = await request(app)
      .post('/api/v1/bookings')
      .set('Authorization', `Bearer ${userToken}`)
      .send({ eventId: testEvent._id.toString(), quantity: 1 });
    const bookingId = createRes.body.data.booking._id;

    // Attempt cancellation by secondUser
    const cancelRes = await request(app)
      .patch(`/api/v1/bookings/${bookingId}/cancel`)
      .set('Authorization', `Bearer ${secondUserToken}`);
    expect(cancelRes.status).toBe(403);
  });

  // Test 5: Register with role: "admin" in body is ignored (mass assignment protection)
  test('5. Mass assignment protection: signup with role "admin" defaults to "user"', async () => {
    const res = await request(app)
      .post('/api/v1/auth/register')
      .send({
        name: 'Hacker',
        email: 'hacker@test.com',
        password: 'Password123!',
        role: 'admin'
      });
    expect(res.status).toBe(201);
    expect(res.body.data.user.role).toBe('user');
  });

  // Test 6: NoSQL injection payload is rejected by mongoSanitize or Zod
  test('6. NoSQL injection payload in login body is rejected', async () => {
    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({
        email: { $gt: '' },
        password: 'Password123!'
      });
    expect(res.status).toBe(400);
  });

  // Test 7: Race Condition Overbooking Test (Parallel booking requests)
  test('7. Atomic Overbooking Prevention: 10 parallel booking requests for remaining 4 seats', async () => {
    // Current availableSeats on testEvent is 4 (since 1 was booked above)
    const requests = Array.from({ length: 10 }).map((_, i) =>
      request(app)
        .post('/api/v1/bookings')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ eventId: testEvent._id.toString(), quantity: 1 })
    );

    const responses = await Promise.all(requests);
    const successfulBookings = responses.filter(r => r.status === 201);
    const failedBookings = responses.filter(r => r.status === 409);

    expect(successfulBookings.length).toBe(4);
    expect(failedBookings.length).toBe(6);

    const updatedEvent = await Event.findById(testEvent._id);
    expect(updatedEvent.availableSeats).toBe(0);
  });

  // Test 8: Refresh Token Reuse Detection & Revocation
  test('8. Refresh token reuse detection revokes all user sessions', async () => {
    const rawToken = await TokenService.generateRefreshToken(regularUser._id);

    // First refresh (legitimate)
    const rotate1 = await TokenService.rotateRefreshToken(rawToken);
    expect(rotate1.newRefreshToken).toBeDefined();

    // Reusing old rawToken (stolen token replay attempt)
    await expect(TokenService.rotateRefreshToken(rawToken)).rejects.toThrow(/reuse detected/i);

    // Verify all user tokens are now revoked
    const userTokens = await RefreshToken.find({ user: regularUser._id });
    expect(userTokens.every(t => t.revokedAt !== null)).toBe(true);
  });

  // Test 9: Invalid ObjectId returns 400
  test('9. Invalid ObjectId returns 400 Bad Request', async () => {
    const res = await request(app)
      .get('/api/v1/events/invalid-object-id-123')
      .set('Authorization', `Bearer ${userToken}`);
    expect(res.status).toBe(400);
  });

  // Test 10: Admin Stats Route Access
  test('10. Admin can access /api/v1/admin/stats and retrieve aggregate revenue', async () => {
    const res = await request(app)
      .get('/api/v1/admin/stats')
      .set('Authorization', `Bearer ${adminToken}`);
    expect(res.status).toBe(200);
    expect(res.body.data.stats.totalEvents).toBeGreaterThan(0);
  });
});
