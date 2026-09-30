import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/booking_controller.dart';
import '../../../data/models/event_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../routes/app_routes.dart';
import '../../common/widgets/app_button.dart';

class BookingFlowView extends StatelessWidget {
  const BookingFlowView({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingController = Get.find<BookingController>();
    final args = Get.arguments as Map<String, dynamic>;
    final EventModel event = args['event'];
    final int quantity = args['quantity'];
    final double totalPrice = event.price * quantity;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.primaryDarkTheme : AppColors.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusCard)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking Summary', style: AppTextStyles.title(textPrimary)),
                      const SizedBox(height: 16),
                      Text(event.title, style: AppTextStyles.subtitle(primary)),
                      const SizedBox(height: 8),
                      Text('${event.venue}, ${event.city}', style: AppTextStyles.body(textSecondary)),
                      Text(Formatters.formatDate(event.startDate), style: AppTextStyles.body(textSecondary)),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Ticket Price', style: AppTextStyles.body(textSecondary)),
                          Text(Formatters.currency(event.price), style: AppTextStyles.body(textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Quantity', style: AppTextStyles.body(textSecondary)),
                          Text('$quantity ticket(s)', style: AppTextStyles.body(textPrimary)),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Payable', style: AppTextStyles.title(textPrimary)),
                          Text(Formatters.currency(totalPrice), style: AppTextStyles.displayMedium(primary)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Obx(
                        () => AppButton(
                          text: 'Confirm & Pay',
                          width: double.infinity,
                          isLoading: bookingController.isBookingInProcess.value,
                          onPressed: () {
                            bookingController.bookTickets(event.id, quantity);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BookingSuccessView extends StatelessWidget {
  const BookingSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingController = Get.find<BookingController>();
    final booking = bookingController.latestConfirmedBooking.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final primary = isDark ? AppColors.primaryDarkTheme : AppColors.primary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, size: 72, color: AppColors.success),
                  ),
                  const SizedBox(height: 20),
                  Text('Booking Confirmed!', style: AppTextStyles.displayMedium(textPrimary)),
                  const SizedBox(height: 8),
                  Text(
                    'Your tickets have been reserved successfully.',
                    style: AppTextStyles.body(Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (booking != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            QrImageView(
                              data: booking.bookingCode,
                              version: QrVersions.auto,
                              size: 180.0,
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text('BOOKING CODE', style: AppTextStyles.caption(Colors.grey)),
                            Text(booking.bookingCode, style: AppTextStyles.title(primary).copyWith(fontFamily: 'monospace')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  AppButton(
                    text: 'View My Bookings',
                    width: double.infinity,
                    onPressed: () => Get.offAllNamed(AppRoutes.myBookings),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.home),
                    child: Text('Back to Home', style: AppTextStyles.button(primary)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
