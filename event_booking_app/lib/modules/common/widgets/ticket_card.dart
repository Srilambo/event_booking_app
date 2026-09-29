import 'package:flutter/material.dart';
import '../../../data/models/booking_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';

class TicketCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const TicketCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final event = booking.event;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: booking.isConfirmed ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppColors.radiusChip),
                    ),
                    child: Text(
                      booking.status.toUpperCase(),
                      style: AppTextStyles.caption(booking.isConfirmed ? AppColors.success : AppColors.error)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'Code: ${booking.bookingCode}',
                    style: AppTextStyles.caption(textSecondary).copyWith(fontFamily: 'monospace'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.subtitle(textPrimary).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_month, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      Formatters.formatDate(event.startDate),
                      style: AppTextStyles.body(textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.tertiary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${event.venue}, ${event.city}',
                      style: AppTextStyles.body(textSecondary),
                    ),
                  ),
                ],
              ),
              const Divider(height: 28, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TICKETS', style: AppTextStyles.caption(textSecondary)),
                      Text('${booking.quantity} Ticket(s)', style: AppTextStyles.button(textPrimary)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('TOTAL PRICE', style: AppTextStyles.caption(textSecondary)),
                      Text(Formatters.currency(booking.totalPrice), style: AppTextStyles.button(AppColors.primary)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_2, size: 32, color: AppColors.primary),
                    onPressed: onTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
