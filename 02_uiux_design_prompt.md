# PROMPT 2: UI/UX Design, Colors, Responsive Layouts (Flutter)

Copy everything below into your AI assistant. Use together with Prompt 1.

---

## Role
You are a senior Flutter UI/UX engineer. Design and implement the UI of the **Event Booking App** so it looks modern, is accessible, and **never shows overflow errors** (no yellow/black striped "RIGHT OVERFLOWED BY X PIXELS") on any phone, tablet, or desktop/web screen size.

## Design Direction
Modern, clean, energetic. Card-based, rounded corners (16 px), soft shadows, generous whitespace, large event imagery.

## Color Palette
### Light theme
| Role | Hex |
|---|---|
| Primary | `#6C4DFF` (violet) |
| Primary Dark | `#4B2FD6` |
| Secondary / Accent | `#FF6B6B` (coral) |
| Tertiary | `#00C2A8` (teal, for success and "available") |
| Background | `#F7F7FB` |
| Surface (cards) | `#FFFFFF` |
| Text Primary | `#1B1B2F` |
| Text Secondary | `#6B6B80` |
| Border / Divider | `#E4E4EE` |
| Success | `#22C55E` |
| Warning | `#F59E0B` |
| Error | `#EF4444` |

### Dark theme
| Role | Hex |
|---|---|
| Primary | `#8B74FF` |
| Background | `#0F0F1A` |
| Surface | `#1A1A2E` |
| Text Primary | `#F2F2FA` |
| Text Secondary | `#A0A0B8` |
| Border | `#2A2A40` |

Rules: define everything in one `AppColors` class + `ThemeData` (Material 3, `ColorScheme.fromSeed` overridden with the values above). Never hardcode colors in widgets. Minimum contrast ratio 4.5:1 for text. Support light/dark/system toggle.

## Typography
- Font: **Poppins** for headings, **Inter** for body (via `google_fonts`)
- Scale: Display 32/28, Title 22, Subtitle 18, Body 16, Caption 13, Button 15 (semi-bold)
- Respect system text scale but clamp it: `MediaQuery.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3)` at the app root.

## Spacing and Shape Tokens
Spacing: 4, 8, 12, 16, 24, 32, 48. Radius: 8 (inputs), 16 (cards), 24 (sheets), 999 (chips). Put in `AppSpacing` and `AppRadius` classes.

## Responsive System
### Breakpoints (create `Responsive` helper in `core/utils/responsive.dart`)
| Name | Width | Layout |
|---|---|---|
| Mobile | < 600 | 1 column, bottom navigation bar |
| Tablet | 600 to 1024 | 2 columns, navigation rail |
| Desktop | > 1024 | 3 to 4 columns, side drawer / permanent sidebar, content max width 1200 |

Use `LayoutBuilder` / `MediaQuery.sizeOf(context)` (not device type checks). Provide `ResponsiveBuilder(mobile:, tablet:, desktop:)` widget.

### Anti-overflow rules (MUST follow in every screen)
1. Every screen body is wrapped: `SafeArea` -> `LayoutBuilder` -> scrollable (`SingleChildScrollView` / `CustomScrollView` / `ListView`). No fixed-height Column without scroll.
2. Wrap page content in `Center` + `ConstrainedBox(maxWidth: 1200)` so desktop never stretches.
3. Inside `Row`, any Text or flexible child must be in `Expanded` / `Flexible`. Every long Text gets `maxLines` + `overflow: TextOverflow.ellipsis`.
4. Use `Wrap` instead of `Row` for chips, tags, and button groups.
5. Grids: use `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 320, childAspectRatio: adaptive)` instead of a fixed `crossAxisCount`. Avoid fixed aspect ratios that clip text; prefer card content that sizes itself.
6. Never use hardcoded widths/heights larger than a small phone (360 px wide). Use `FractionallySizedBox`, `AspectRatio` (e.g. 16:9 for event images), and `Flexible`.
7. Forms: wrap in `SingleChildScrollView` and set `resizeToAvoidBottomInset: true` so the keyboard never causes overflow. Use `keyboardDismissBehavior`.
8. Images: `CachedNetworkImage` with `fit: BoxFit.cover`, placeholder + error widget, inside a sized/AspectRatio parent.
9. Dialogs / bottom sheets: `isScrollControlled: true`, `constraints: BoxConstraints(maxWidth: 560)`, content scrollable.
10. Tables (admin): wrap `DataTable` in horizontal `SingleChildScrollView`; on mobile switch to card list.
11. Avoid `Expanded` directly inside a scrollable Column without bounded height. Use `shrinkWrap` + `NeverScrollableScrollPhysics` only for small nested lists.
12. Test at these sizes: 320x568, 360x640, 390x844, 412x915, 768x1024, 1024x768, 1366x768, 1920x1080, plus landscape and 1.5x text scale. Zero overflow warnings in the debug console is the acceptance criterion.

### Adaptive navigation
- Mobile: `NavigationBar` (Home, Explore, My Bookings, Profile). Admin gets an extra "Admin" tab.
- Tablet: `NavigationRail`.
- Desktop/Web: permanent left sidebar + top app bar with search and profile menu.

## Screens and Layout Details
1. **Splash / Onboarding** (3 slides, skip button)
2. **Login / Register**: mobile = full screen form; desktop = split screen (left illustration + brand, right form card max 440 wide).
3. **Home**: greeting, search bar, category chips (horizontal scroll), "Featured" carousel (PageView, `viewportFraction` 0.9 on mobile), "Upcoming events" responsive grid.
4. **Explore / Search**: filters in bottom sheet (mobile) or left filter panel (desktop): category, date range, price slider, city. Sort dropdown.
5. **Event Details**: hero image with SliverAppBar (mobile); on desktop a two-column layout (image + description left, sticky booking card right). Show date, venue, seats left (progress bar), price, "Book Now" button (sticky at bottom on mobile).
6. **Booking Flow**: quantity stepper, price summary, confirm. Success screen with animated check + QR code + booking code.
7. **My Bookings**: tabs Upcoming / Past / Cancelled; ticket-style cards; tap opens QR.
8. **Profile / Settings**: edit info, theme toggle, logout.
9. **Admin Dashboard**: stat cards (responsive `Wrap`), bar/line chart (`fl_chart`) of bookings, recent bookings list.
10. **Admin: Manage Events**: searchable table (desktop) / cards (mobile), create/edit form with image picker and date-time pickers.
11. **Admin: Manage Users**: list with role dropdown and active toggle.

## Components (build reusable widgets in `lib/modules/common/widgets`; module-specific widgets go in that module's `widgets/` folder)
`AppButton` (primary, secondary, outline, loading state), `AppTextField` (label, error, obscure toggle), `EventCard` (vertical) and `EventTile` (horizontal), `CategoryChip`, `StatCard`, `SeatProgressBar`, `EmptyState`, `ErrorState` (with retry), `LoadingSkeleton` (shimmer), `TicketCard`, `ResponsiveScaffold`.

## UX Requirements
- Every async screen has **4 states**: loading (shimmer), success, empty, error with retry.
- Pull-to-refresh on lists; infinite scroll pagination.
- Inline form validation with clear messages; disable submit while loading; prevent double taps.
- Snackbars/toasts for feedback; confirm dialog for destructive actions (cancel booking, delete event).
- Micro-animations: 200 to 300 ms (Hero image transition, AnimatedSwitcher, button press scale).
- Accessibility: min tap target 48x48, `Semantics` labels on icons/images, don't rely on color alone.
- Web: set page title, favicon, URL strategy path-based, keyboard focus and hover states on desktop.

## Output Format
1. Provide `core/theme/*`, `core/utils/responsive.dart` first (full code). Follow the project structure from Prompt 1 (GetX, `modules/<feature>/views|widgets|controllers`); all screens live in `views/`, use `Obx` for reactive UI and `GetMaterialApp` with `Get.width`/`LayoutBuilder` for responsiveness.
2. Then shared widgets, then screens one by one with full code.
3. After each screen, list which overflow rules it applies and any widths where the layout changes.
4. Finish with a QA checklist I can run through at the sizes listed above.
