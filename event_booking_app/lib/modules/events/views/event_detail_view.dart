import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/event_controller.dart';
import '../../common/widgets/seat_progress_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';

/// Redesigned Event Detail View matching the reference mockup layout
class EventDetailView extends StatefulWidget {
  const EventDetailView({super.key});

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  final EventController _eventController = Get.find<EventController>();
  int _ticketQuantity = 1;

  @override
  void initState() {
    super.initState();
    final String eventId = Get.arguments as String;
    _eventController.fetchEventDetails(eventId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.primaryDarkTheme : AppColors.primary;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Scaffold(
      body: Obx(() {
        if (_eventController.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final event = _eventController.selectedEvent.value;
        if (event == null) {
          return const Center(child: Text('Event details unavailable'));
        }

        // Booking Card Modal Content
        Widget bookingCard = Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderCard),
          child: Padding(
            padding: AppSpacing.paddingXl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ticket Price', style: AppTextStyles.caption(textSecondary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: event.price > 0 ? AppColors.accentLime : AppColors.tertiary,
                        borderRadius: AppRadius.borderChip,
                      ),
                      child: Text(
                        event.price > 0 ? Formatters.currency(event.price) : 'FREE',
                        style: AppTextStyles.button(const Color(0xFF0F172A)).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SeatProgressBar(availableSeats: event.availableSeats, totalSeats: event.totalSeats),
                const SizedBox(height: 20),

                // Quantity Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Quantity', style: AppTextStyles.body(textPrimary)),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        borderRadius: AppRadius.borderInput,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _ticketQuantity > 1
                                ? () => setState(() => _ticketQuantity--)
                                : null,
                          ),
                          Text('$_ticketQuantity', style: AppTextStyles.button(textPrimary)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _ticketQuantity < 10 && _ticketQuantity < event.availableSeats
                                ? () => setState(() => _ticketQuantity++)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppTextStyles.button(textPrimary)),
                    Text(Formatters.currency(event.price * _ticketQuantity), style: AppTextStyles.title(primary)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderChip),
                    ),
                    onPressed: event.isSoldOut
                        ? null
                        : () {
                            Get.toNamed(
                              AppRoutes.bookingFlow,
                              arguments: {
                                'event': event,
                                'quantity': _ticketQuantity,
                              },
                            );
                          },
                    child: Text(
                      event.isSoldOut ? 'Sold Out' : 'Book Tickets Now',
                      style: AppTextStyles.button(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        return ResponsiveBuilder(
          mobile: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Details'),
              actions: [
                IconButton(icon: const Icon(Icons.bookmark_outline), onPressed: () {}),
                IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Header + Lime Accent Price Badge (Matching Reference Right Screen)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: AppTextStyles.title(textPrimary).copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: AppColors.tertiary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${event.venue}, ${event.city}',
                                    style: AppTextStyles.caption(textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: event.price > 0 ? AppColors.accentLime : AppColors.tertiary,
                            borderRadius: AppRadius.borderChip,
                          ),
                          child: Text(
                            event.price > 0 ? Formatters.currency(event.price) : 'FREE',
                            style: AppTextStyles.button(const Color(0xFF0F172A)).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Big 16:10 Hero Image Showcase
                    ClipRRect(
                      borderRadius: AppRadius.borderCard,
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: CachedNetworkImage(
                          imageUrl: event.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: isDark ? AppColors.surfaceDark : Colors.grey[200]),
                          errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // INFO ROW WITH ICONS (Date | Seats | Category - Inspired by Reference 3 Beds | 2 Bath | 240m²)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: AppRadius.borderCard,
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SpecBadgeItem(
                            icon: Icons.calendar_month,
                            iconColor: AppColors.secondary,
                            label: Formatters.formatDate(event.startDate),
                          ),
                          Container(height: 24, width: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          _SpecBadgeItem(
                            icon: Icons.event_seat,
                            iconColor: primary,
                            label: '${event.availableSeats} Seats',
                          ),
                          Container(height: 24, width: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          _SpecBadgeItem(
                            icon: Icons.category_outlined,
                            iconColor: AppColors.tertiary,
                            label: event.category,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // About Event
                    Text('About Event', style: AppTextStyles.title(textPrimary)),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: AppTextStyles.body(textSecondary).copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 100), // Spacing for pinned bottom CTA
                  ],
                ),
              ),
            ),
            // Pinned Full-Width Black CTA Button at Bottom (Reference UI style)
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderChip),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (ctx) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                            top: 16,
                            left: 16,
                            right: 16,
                          ),
                          child: bookingCard,
                        ),
                      );
                    },
                    child: Text('Book Tickets Now', style: AppTextStyles.button(Colors.white)),
                  ),
                ),
              ),
            ),
          ),
          desktop: (context) => Scaffold(
            appBar: AppBar(title: Text(event.title)),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.borderCard,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: CachedNetworkImage(imageUrl: event.imageUrl, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(event.title, style: AppTextStyles.displayMedium(textPrimary)),
                        const SizedBox(height: 16),
                        Text('About Event', style: AppTextStyles.title(textPrimary)),
                        const SizedBox(height: 8),
                        Text(event.description, style: AppTextStyles.body(textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 2,
                    child: bookingCard,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SpecBadgeItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _SpecBadgeItem({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption(textPrimary).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
