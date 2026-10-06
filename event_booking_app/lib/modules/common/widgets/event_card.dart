import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/event_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import 'seat_progress_bar.dart';

/// Event Card Widget with ThemeExtension context color lookups
class EventCard extends StatefulWidget {
  final EventModel event;
  final VoidCallback onTap;
  final double? width;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.width,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = context.customColors;
    final textPrimary = customColors.textPrimary;
    final textSecondary = customColors.textSecondary;
    final cardBg = customColors.surface;

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderCard,
          border: Border.all(
            color: customColors.fieldBorder.withValues(alpha: 0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.borderCard,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: CachedNetworkImage(
                          imageUrl: widget.event.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: customColors.fieldFill,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: customColors.fieldFill,
                            child: Icon(Icons.image_not_supported, color: textSecondary),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        height: 28,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: customColors.accentPurple.withValues(alpha: 0.9),
                          borderRadius: AppRadius.borderChip,
                        ),
                        child: Text(
                          widget.event.category,
                          style: AppTextStyles.caption(Colors.white).copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        height: 28,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: widget.event.price > 0 ? customColors.accentLime : AppColors.tertiary,
                          borderRadius: AppRadius.borderChip,
                        ),
                        child: Text(
                          widget.event.price > 0 ? Formatters.currency(widget.event.price) : 'FREE',
                          style: AppTextStyles.button(const Color(0xFF0F0D1A)).copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.subtitle(textPrimary).copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                Formatters.formatDate(widget.event.startDate),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption(textSecondary).copyWith(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.tertiary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${widget.event.venue}, ${widget.event.city}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption(textSecondary).copyWith(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        SeatProgressBar(
                          availableSeats: widget.event.availableSeats,
                          totalSeats: widget.event.totalSeats,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
