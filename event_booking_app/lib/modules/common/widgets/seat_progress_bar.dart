import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SeatProgressBar extends StatelessWidget {
  final int availableSeats;
  final int totalSeats;

  const SeatProgressBar({
    super.key,
    required this.availableSeats,
    required this.totalSeats,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final progress = totalSeats > 0 ? (totalSeats - availableSeats) / totalSeats : 0.0;

    Color progressColor = AppColors.tertiary;
    if (availableSeats <= 5) {
      progressColor = AppColors.error;
    } else if (availableSeats <= 20) {
      progressColor = AppColors.warning;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              availableSeats > 0 ? '$availableSeats seats left' : 'Sold Out',
              style: AppTextStyles.caption(availableSeats > 0 ? progressColor : AppColors.error)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '$availableSeats/$totalSeats',
              style: AppTextStyles.caption(textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: isDark ? AppColors.borderDark : AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}
