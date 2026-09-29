# PROMPT 3: Security and Role-Based Access Control

Copy everything below into your AI assistant. Use together with Prompt 1 and 2.

---

## Role
You are a senior application security engineer and backend developer. Implement and review security for the **Event Booking App** (Flutter client, Express.js API, MongoDB Atlas). Follow OWASP Top 10 and OWASP ASVS basics. Write code and explain each control in one or two lines.

## 1. Roles and Permissions (RBAC)
| Role | Description |
|---|---|
| `user` | Default on signup |
| `organizer` | Can create and manage **own** events only |
| `admin` | Full access, manages users and all events |

### Permission Matrix
| Action | Guest | User | Organizer | Admin |
|---|---|---|---|---|
| View published events | Yes | Yes | Yes | Yes |
| View draft/cancelled events | No | No | Own only | Yes |
| Register / login | Yes | n/a | n/a | n/a |
| Book / cancel own booking | No | Yes | Yes | Yes |
| View own bookings | No | Yes | Yes | Yes |
| Create event | No | No | Yes | Yes |
| Edit / delete event | No | No | Own only | Any |
| View bookings of an event | No | No | Own events | Any |
| View stats dashboard | No | No | Own events only | All |
| Manage users / change roles | No | No | No | Yes |

### Implementation
- `auth` middleware: verifies JWT, loads user from DB (check `isActive`), attaches `req.user`.
- `authorize(...roles)` middleware: `router.post('/events', auth, authorize('organizer','admin'), ...)`.
- **Ownership check** helper (`isOwnerOrAdmin`) in services for event edit/delete and booking cancel. This prevents **IDOR / broken object level authorization**.
- Role is stored server side only. Never trust a role sent from the client. Block role field in register body (mass assignment protection).
- Only an admin can promote users. Prevent an admin from demoting or deactivating themselves (avoid lockout) and keep at least one active admin.
- Flutter: route guards via `GetMiddleware` (in `routes/route_guards.dart`, using `redirect()`) check login + role, and hide UI for unauthorized actions. **This is UX only; the API is the real enforcement.**

## 2. Authentication
- Passwords: **bcrypt** (cost 12) or argon2. Min 8 chars, require letter + number, reject common passwords. Never log or return `passwordHash` (`select: false` in schema).
- **Access token**: JWT, 15 min expiry, signed with strong secret (`HS256`, 32+ random bytes) or RS256. Payload: `sub`, `role`, `iat`, `exp` only.
- **Refresh token**: random 64 bytes, store **hashed** (SHA-256) in DB with expiry, **rotate on every use**, revoke old one, detect reuse (if a revoked token is reused, revoke all sessions of that user).
- Logout revokes the refresh token. "Logout all devices" revokes all.
- Login errors are generic ("Invalid email or password"); same response time for unknown email (dummy hash compare) to avoid user enumeration.
- Account lockout / progressive delay: 5 failed attempts -> 15 min cooldown (per email + IP).
- Optional extras: email verification, password reset with single-use expiring token (hashed in DB, 15 min).

## 3. API Hardening (Express)
```
helmet()                              // secure headers
cors({ origin: allowedOrigins, credentials: true })  // strict allowlist, no '*'
express.json({ limit: '10kb' })       // body size limit
express-rate-limit                    // global 100 req / 15 min; auth routes 10 req / 15 min
express-mongo-sanitize                // block NoSQL injection ($ and . keys)
hpp                                   // HTTP parameter pollution
compression, morgan (no sensitive data in logs)
```
- **Input validation** on every route with **Zod** or **Joi** (body, params, query): types, lengths, enums, ObjectId format, date ranges, `quantity` integer 1 to 10, price >= 0. Use whitelist (strip unknown fields).
- Never build queries from raw user input; cast to types; escape regex for search (`escapeRegex`) or use text index.
- Central error handler: hide stack traces and internal messages in production; log details server side only.
- `app.disable('x-powered-by')`, `trust proxy` set correctly for Vercel/Render (needed for correct rate-limit IPs).
- Use HTTPS only; HSTS enabled via helmet.

## 4. Booking Integrity and Business Logic Security
- Atomic seat decrement (`$gte` condition) to prevent overbooking and race conditions.
- **Server calculates price** (`event.price * quantity`); never accept price or total from the client.
- Idempotency: accept an `Idempotency-Key` header on POST /bookings so double-taps or retries do not create duplicate bookings.
- Limits: max tickets per booking and per user per event; no booking for past, cancelled, or draft events.
- Cancellation only for own booking, only if status is `confirmed` and before cutoff (e.g. 24 h before start).
- Booking code: cryptographically random (`crypto.randomBytes`), not sequential or guessable. QR verification endpoint for organizers/admin only.
- Audit log collection (`AuditLog { actor, action, target, ip, at }`) for role changes, event delete, user deactivation, and booking cancellations.

## 5. File Upload Security (event images)
- Accept only `image/jpeg`, `image/png`, `image/webp`; verify by **magic bytes**, not only extension/MIME.
- Max 2 MB, random filenames, no user-controlled paths (prevent path traversal).
- Store on Cloudinary / S3 (not the server disk on serverless). Strip EXIF metadata.
- Only organizer/admin can upload; rate-limit the upload route.

## 6. Data Protection (MongoDB Atlas)
- Dedicated DB user with least privilege (readWrite on one database only), strong password, **no `0.0.0.0/0` in production** if possible (allowlist hosting IPs; Vercel needs broader access, so compensate with strong credentials and monitoring).
- Enable Atlas backups and alerts. TLS enforced (default).
- Secrets only in environment variables (Vercel dashboard / `.env`), `.env` in `.gitignore`, commit `.env.example` only. Rotate secrets if ever leaked.
- Minimal PII: name + email only. Provide "delete my account" endpoint (anonymize bookings).

## 7. Flutter Client Security
- Store tokens in **`flutter_secure_storage`** (Keychain/Keystore), never `SharedPreferences`. On web, prefer **httpOnly, Secure, SameSite cookies** for the refresh token (note limitations of secure storage on web).
- Dio interceptor: attach access token, on 401 try refresh once, then logout.
- Do not hardcode API keys/secrets in the app (anything in the client is public). Use `--dart-define` for the base URL only.
- Release builds: `--obfuscate --split-debug-info`; disable debug logs; certificate pinning optional for extra credit.
- Validate inputs client side for UX, but never rely on it.
- Don't put sensitive data (tokens, emails) in logs or crash reports.

## 8. Dependency and DevOps Security
- `npm audit` and Dependabot on GitHub; lock versions (`package-lock.json`, `pubspec.lock`).
- GitHub: enable secret scanning, branch protection, no secrets in commit history (use `git-secrets` or gitleaks).
- Separate dev and prod environments and databases.
- Basic monitoring: log failed logins, 401/403 spikes, rate-limit hits.

## 9. Testing Requirements
Write automated tests (Jest + Supertest) covering:
1. Unauthenticated access to protected routes returns 401
2. `user` calling admin/organizer routes returns 403
3. Organizer editing another organizer's event returns 403
4. User cancelling another user's booking returns 403/404
5. Register with `role: "admin"` in body is ignored
6. NoSQL injection payload (`{"email": {"$gt": ""}}`) is rejected
7. Overbooking test: 20 parallel requests for the last 5 seats -> only 5 succeed
8. Expired/tampered JWT rejected; reused refresh token revokes the session
9. Rate limit triggers after threshold on /auth/login
10. Oversized body and invalid ObjectId return 400/413

## Output Format
1. Show the middleware files first (`auth.js`, `role.js`, `validate.js`, `rateLimit.js`, `errorHandler.js`) with full code.
2. Then token service (access + refresh rotation), auth controller, and the schema changes.
3. Then apply the middleware to each route file, showing the final route definitions.
4. Then the Flutter secure storage (`core/storage`) + dio interceptor (`core/network`) code and role-based route guards.
5. Then the test suite.
6. End with a **security checklist** (pass/fail table) and a short "what to say in an interview about how this app is secured" summary.
