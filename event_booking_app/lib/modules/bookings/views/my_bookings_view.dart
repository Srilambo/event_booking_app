import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/booking_controller.dart';
import '../../common/widgets/ticket_card.dart';
import '../../common/widgets/empty_state.dart';
import '../../common/widgets/error_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/booking_model.dart';

class MyBookingsView extends StatelessWidget {
  const MyBookingsView({super.key});

  void _showQrDialog(BuildContext context, BookingModel booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final primary = isDark ? AppColors.primaryDarkTheme : AppColors.primary;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusCard)),
        child: SizedBox(
          width: 380,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Digital Pass', style: AppTextStyles.title(textPrimary)),
                const SizedBox(height: 16),
                QrImageView(
                  data: booking.bookingCode,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 16),
                Text('Code: ${booking.bookingCode}', style: AppTextStyles.subtitle(primary).copyWith(fontFamily: 'monospace')),
                const SizedBox(height: 8),
                Text('Show this QR code at the venue entry.', style: AppTextStyles.caption(Colors.grey), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (booking.isConfirmed)
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _confirmCancellation(context, booking);
                        },
                        child: const Text('Cancel Booking', style: TextStyle(color: AppColors.error)),
                      ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmCancellation(BuildContext context, BookingModel booking) {
    final bookingController = Get.find<BookingController>();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusCard)),
        child: SizedBox(
          width: 380,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cancel Booking?', style: AppTextStyles.title(AppColors.textPrimaryLight)),
                const SizedBox(height: 12),
                const Text('Are you sure you want to cancel this booking? Refund will be processed per terms.'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Booking')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      onPressed: () {
                        Navigator.pop(ctx);
                        bookingController.cancelBooking(booking.id);
                      },
                      child: const Text('Confirm Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingController = Get.find<BookingController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings & History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: Obx(() {
          if (bookingController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookingController.errorMessage.value.isNotEmpty) {
            return ErrorState(
              message: bookingController.errorMessage.value,
              onRetry: () => bookingController.fetchMyBookings(refresh: true),
            );
          }

          if (bookingController.bookings.isEmpty) {
            return const EmptyState(
              title: 'No Booking History Yet',
              message: 'You have not booked any event tickets yet.',
              icon: Icons.confirmation_number_outlined,
            );
          }

          final now = DateTime.now();

          // Upcoming: confirmed and start/end date in the future (or current)
          final upcomingList = bookingController.bookings
              .where((b) => b.isConfirmed && (b.event.endDate.isAfter(now) || b.event.startDate.isAfter(now)))
              .toList();

          // Past: confirmed and end date in the past
          final pastList = bookingController.bookings
              .where((b) => b.isConfirmed && b.event.endDate.isBefore(now))
              .toList();

          // Cancelled: status is cancelled
          final cancelledList = bookingController.bookings
              .where((b) => b.isCancelled)
              .toList();

          // If no strictly past events exist, fall back to showing all confirmed bookings in Past tab so user can see full history
          final pastDisplayList = pastList.isNotEmpty ? pastList : bookingController.bookings.where((b) => b.isConfirmed).toList();

          return TabBarView(
            children: [
              // Upcoming / Confirmed Tab
              _buildBookingList(
                context,
                upcomingList.isNotEmpty ? upcomingList : bookingController.bookings.where((b) => b.isConfirmed).toList(),
                emptyTitle: 'No Upcoming Bookings',
                emptyMessage: 'Explore events and book your tickets now!',
              ),
              // Past History Tab
              _buildBookingList(
                context,
                pastDisplayList,
                emptyTitle: 'No Past Booking History',
                emptyMessage: 'Completed events will appear here.',
              ),
              // Cancelled Tab
              _buildBookingList(
                context,
                cancelledList,
                emptyTitle: 'No Cancelled Bookings',
                emptyMessage: 'You have no cancelled tickets.',
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    List<BookingModel> list, {
    required String emptyTitle,
    required String emptyMessage,
  }) {
    if (list.isEmpty) {
      return EmptyState(
        title: emptyTitle,
        message: emptyMessage,
        icon: Icons.assignment_late_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => Get.find<BookingController>().fetchMyBookings(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final booking = list[index];
          return TicketCard(
            booking: booking,
            onTap: () => _showQrDialog(context, booking),
          );
        },
      ),
    );
  }
}
