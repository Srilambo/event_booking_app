import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/event_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import 'seat_progress_bar.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primary = isDark ? AppColors.primaryDarkTheme : AppColors.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Category Badge & Price
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: event.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: isDark ? AppColors.surfaceDark : Colors.grey[200]),
                    errorWidget: (_, __, ___) => Container(
                      color: isDark ? AppColors.surfaceDark : Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(AppColors.radiusChip),
                    ),
                    child: Text(
                      event.category,
                      style: AppTextStyles.caption(Colors.white).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(AppColors.radiusInput),
                    ),
                    child: Text(
                      event.price > 0 ? Formatters.currency(event.price) : 'FREE',
                      style: AppTextStyles.button(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            // Event Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption(textSecondary),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption(textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SeatProgressBar(
                      availableSeats: event.availableSeats,
                      totalSeats: event.totalSeats,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
