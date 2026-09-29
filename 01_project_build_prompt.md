# PROMPT 1: Project Build (Event Booking App)

Copy everything below into your AI coding assistant (Claude, Claude Code, etc.).

---

## Role
You are a senior full-stack engineer. Build a complete, production-style **Event Booking App** as a portfolio project. Write clean, commented, beginner-readable code. Do not skip files or leave "TODO" placeholders.

## Tech Stack
- **Mobile/Web client:** Flutter (Dart, null-safety), state management + routing + dependency injection with **GetX** (controllers, `GetPage`, bindings, `GetMiddleware`), HTTP with **dio**
- **Backend:** Node.js + **Express.js** (REST API, ES modules or CommonJS, be consistent)
- **Database:** **MongoDB Atlas** with **Mongoose**
- **Auth:** JWT (access + refresh tokens), bcrypt
- **Hosting:** Backend on Vercel (serverless) or Render; Flutter Web build on Vercel; code on GitHub

## Core Features
### User
- Register / login / logout
- Browse events (list + grid), search, filter by category, date, price
- Event details page (image, description, venue, date/time, price, seats left)
- Book tickets (choose quantity, see total price)
- My Bookings (upcoming/past), cancel booking (only before a cutoff)
- Profile edit

### Admin
- Dashboard: total events, bookings, revenue, users
- Create / edit / delete events (with image upload)
- View all bookings per event, export CSV
- Manage users (change role, deactivate)

### System
- Seat availability must be **race-condition safe** (no overbooking)
- Booking confirmation with a unique booking code (QR code shown in app)
- Pagination, loading, empty and error states everywhere

## Data Models (Mongoose)
```
User    { name, email(unique), passwordHash, role: 'user'|'organizer'|'admin', isActive, createdAt }
Event   { title, description, category, imageUrl, venue, city, startDate, endDate,
          price, totalSeats, availableSeats, status: 'draft'|'published'|'cancelled', createdBy, createdAt }
Booking { user(ref), event(ref), quantity, totalPrice, bookingCode(unique),
          status: 'confirmed'|'cancelled', createdAt }
RefreshToken { user, tokenHash, expiresAt, revokedAt }
```
Add indexes: `Event(startDate, category, status)`, `Booking(user, event)`, `User(email)`.

## REST API Endpoints
```
AUTH
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
GET    /api/v1/auth/me

EVENTS
GET    /api/v1/events            ?search=&category=&city=&from=&to=&page=&limit=
GET    /api/v1/events/:id
POST   /api/v1/events            (admin/organizer)
PUT    /api/v1/events/:id        (admin or owner)
DELETE /api/v1/events/:id        (admin or owner)

BOOKINGS
POST   /api/v1/bookings          (user)
GET    /api/v1/bookings/mine     (user)
PATCH  /api/v1/bookings/:id/cancel (owner)
GET    /api/v1/events/:id/bookings (admin/organizer)

ADMIN
GET    /api/v1/admin/stats
GET    /api/v1/admin/users
PATCH  /api/v1/admin/users/:id/role
PATCH  /api/v1/admin/users/:id/status
```
Response format for all endpoints:
```json
{ "success": true, "data": {}, "message": "", "meta": { "page": 1, "limit": 10, "total": 0 } }
```
Errors: `{ "success": false, "message": "...", "errors": [ ... ] }` with correct HTTP codes.

## Folder Structure
### Backend
```
event-booking-api/
├── src/
│   ├── config/         (db.js, env.js)
│   ├── models/         (User.js, Event.js, Booking.js, RefreshToken.js)
│   ├── controllers/    (auth, event, booking, admin)
│   ├── routes/         (auth.routes.js, event.routes.js, booking.routes.js, admin.routes.js)
│   ├── middleware/     (auth.js, role.js, validate.js, errorHandler.js, rateLimit.js)
│   ├── validators/     (auth.schema.js, event.schema.js, booking.schema.js)
│   ├── services/       (booking.service.js, token.service.js)
│   ├── utils/          (ApiError.js, asyncHandler.js, generateCode.js)
│   ├── app.js
│   └── server.js
├── api/index.js        (Vercel serverless entry: exports app)
├── vercel.json
├── .env.example
├── package.json
└── README.md
```
### Flutter (Clean architecture, GetX, module-based) - USE THIS EXACT STRUCTURE
Layers: **Presentation (UI)** -> **State Management (GetX controllers, business rules)** -> **Domain (entities, use cases, repository interfaces)** -> **Data / External (APIs, local storage)**.
```
event_booking_app/
├── lib/
│   ├── core/
│   │   ├── constants/      (api_endpoints.dart, app_strings.dart, app_constants.dart)
│   │   ├── theme/          (app_colors.dart, app_text_styles.dart, app_theme.dart)
│   │   ├── utils/          (responsive.dart, validators.dart, formatters.dart)
│   │   ├── network/        (dio_client.dart, auth_interceptor.dart, api_exception.dart)
│   │   └── storage/        (secure_storage_service.dart)
│   │
│   ├── data/
│   │   ├── models/         (user_model, event_model, booking_model: fromJson/toJson)
│   │   ├── repositories/   (auth_repository_impl, event_repository_impl, booking_repository_impl)
│   │   └── services/       (auth_service, event_service, booking_service: raw API calls via dio)
│   │
│   ├── domain/
│   │   ├── entities/       (user, event, booking)
│   │   ├── repositories/   (abstract repository interfaces)
│   │   └── usecases/       (login, register, get_events, book_event, cancel_booking ...)
│   │
│   ├── modules/
│   │   ├── authentication/
│   │   │   ├── controllers/   (auth_controller.dart)
│   │   │   ├── views/         (login_view, register_view, splash_view)
│   │   │   ├── widgets/
│   │   │   └── bindings/      (auth_binding.dart)
│   │   ├── home/              (controllers, views, widgets, bindings)
│   │   ├── events/            (list, search/filter, event_details)
│   │   ├── bookings/          (booking flow, my_bookings, ticket/QR)
│   │   ├── profile/
│   │   ├── admin/             (dashboard, manage_events, manage_users)
│   │   └── common/
│   │       └── widgets/       (app_button, app_text_field, event_card, empty_state, error_state, loading_skeleton ...)
│   │
│   ├── routes/
│   │   ├── app_routes.dart    (route name constants)
│   │   ├── app_pages.dart     (GetPage list + bindings)
│   │   └── route_guards.dart  (GetMiddleware: auth + role checks)
│   │
│   └── main.dart              (GetMaterialApp, theme, initial binding, initial route)
├── assets/ (images, icons)
├── test/
├── pubspec.yaml
└── README.md
```
Rules for this structure:
- Every module has `controllers/`, `views/`, `widgets/` (+ `bindings/`). Views never call APIs directly; they only talk to controllers (`Obx`, `GetBuilder`).
- Controllers call **use cases**; use cases call **repository interfaces** (domain); implementations live in `data/repositories` and call `data/services`.
- Data flow: `View -> Controller -> UseCase -> Repository -> Service (dio) -> API`.
- Register global dependencies (dio client, storage, repositories, AuthController) in an `InitialBinding`; module controllers via their own bindings (`Get.lazyPut`).
- Keep the layers independent: `domain` must not import Flutter UI or dio.

## Critical Implementation Notes
1. **Overbooking prevention:** use an atomic update:
   `Event.findOneAndUpdate({ _id, availableSeats: { $gte: qty }, status: 'published' }, { $inc: { availableSeats: -qty } })`
   If null, return 409 "Not enough seats". Create booking after; if booking creation fails, roll seats back (or use a MongoDB transaction).
2. On cancel, add seats back atomically.
3. Use a service layer for booking logic (not inside controllers).
4. Centralized error handler + `asyncHandler` wrapper.
5. Use environment variables only (never hardcode secrets).
6. Flutter: follow the module-based GetX structure above: models (fromJson/toJson), repository pattern, use cases, and GetX controllers with reactive state (`.obs`). Handle token refresh automatically in a dio interceptor.

## Build Order (deliver in this sequence)
1. Backend setup + DB connection + models
2. Auth (register, login, refresh, logout, me) + middleware
3. Events CRUD + search/filter/pagination
4. Bookings with atomic seat logic
5. Admin endpoints + stats aggregation
6. Seed script (admin user + 15 sample events)
7. Flutter core (constants, theme, utils, network/dio, storage) + routes (app_routes, app_pages, guards) + main.dart
8. Flutter data + domain layers, then authentication module (controller, views, widgets, binding)
9. Flutter events list/details
10. Flutter booking + My Bookings (with QR)
11. Flutter admin screens
12. Deployment configs (vercel.json, Flutter web build) + README with screenshots section, live demo link, setup steps

## Output Format
For each step: (a) list files created, (b) full code for every file in separate code blocks with the file path as a heading, (c) how to run and test it (sample curl / Postman request). Ask me before moving to the next step.

## Deployment Notes
- Backend `vercel.json`: route all requests to `api/index.js`. Use MongoDB Atlas with a cached connection (serverless-safe).
- Flutter web: `flutter build web --release`, deploy `build/web` to Vercel with a rewrite rule to `index.html` for SPA routing.
- Set CORS to allow only the deployed frontend origin + localhost for dev.
