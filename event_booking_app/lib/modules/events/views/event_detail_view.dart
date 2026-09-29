import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/event_controller.dart';
import '../../common/widgets/seat_progress_bar.dart';
import '../../common/widgets/app_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';

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

    return Scaffold(
      body: Obx(() {
        if (_eventController.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final event = _eventController.selectedEvent.value;
        if (event == null) {
          return const Center(child: Text('Event details unavailable'));
        }

        Widget bookingCard = Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusCard)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ticket Price', style: AppTextStyles.caption(textSecondary)),
                    Text(Formatters.currency(event.price), style: AppTextStyles.title(primary)),
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
                        borderRadius: BorderRadius.circular(8),
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
                AppButton(
                  text: event.isSoldOut ? 'Sold Out' : 'Book Tickets Now',
                  width: double.infinity,
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
                ),
              ],
            ),
          ),
        );

        return ResponsiveBuilder(
          mobile: (context) => Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: CachedNetworkImage(
                      imageUrl: event.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(AppColors.radiusChip),
                          ),
                          child: Text(event.category, style: AppTextStyles.caption(Colors.white)),
                        ),
                        const SizedBox(height: 12),
                        Text(event.title, style: AppTextStyles.displayMedium(textPrimary)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, color: AppColors.secondary),
                            const SizedBox(width: 8),
                            Text(Formatters.formatDateRange(event.startDate, event.endDate), style: AppTextStyles.body(textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.tertiary),
                            const SizedBox(width: 8),
                            Text('${event.venue}, ${event.city}', style: AppTextStyles.body(textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('About Event', style: AppTextStyles.title(textPrimary)),
                        const SizedBox(height: 8),
                        Text(event.description, style: AppTextStyles.body(textSecondary)),
                        const SizedBox(height: 100), // Spacing for bottom sheet button
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomSheet: Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              child: AppButton(
                text: 'Select Seats & Book',
                width: double.infinity,
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
                          borderRadius: BorderRadius.circular(AppColors.radiusCard),
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
