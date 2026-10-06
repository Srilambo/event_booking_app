import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

/// Helper to get trendy Airbnb/Uber style category colors
Color getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'music':
      return const Color(0xFFEC4899); // Pink
    case 'tech':
      return const Color(0xFF3B82F6); // Blue
    case 'sports':
      return const Color(0xFFF97316); // Orange
    case 'arts':
      return const Color(0xFFA855F7); // Purple
    case 'food':
      return const Color(0xFFEF4444); // Red
    case 'business':
      return const Color(0xFF14B8A6); // Teal
    default:
      return const Color(0xFF8B5CF6); // Vibrant Purple fallback
  }
}

/// Helper to get category icons
IconData getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'music':
      return Icons.music_note_rounded;
    case 'tech':
      return Icons.laptop_mac_rounded;
    case 'sports':
      return Icons.sports_soccer_rounded;
    case 'arts':
      return Icons.palette_rounded;
    case 'food':
      return Icons.restaurant_rounded;
    case 'business':
      return Icons.business_center_rounded;
    default:
      return Icons.event_rounded;
  }
}

/// Downward pointing triangle painter for Pin tail
class _PinTailPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;

  _PinTailPainter({
    required this.color,
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round;

    final borderPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth;
}

/// Downward pointing small triangle painter for Price Bubble
class _BubbleTailPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _BubbleTailPainter({
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;

    final borderPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.borderColor != borderColor;
}

/// Reusable modern map pin widget with Airbnb/Uber aesthetics, category icons,
/// lime selected state, pulsing ring, and price bubble
class EventMapPin extends StatefulWidget {
  final String category;
  final bool isSelected;
  final double price;
  final bool showPriceLabel;
  final VoidCallback? onTap;

  const EventMapPin({
    super.key,
    required this.category,
    required this.isSelected,
    required this.price,
    this.showPriceLabel = false,
    this.onTap,
  });

  @override
  State<EventMapPin> createState() => _EventMapPinState();
}

class _EventMapPinState extends State<EventMapPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isSelected) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant EventMapPin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!widget.isSelected && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;
    final surfaceColor = customColors.surface;
    final textPrimary = customColors.textPrimary;

    final categoryColor = getCategoryColor(widget.category);
    final categoryIcon = getCategoryIcon(widget.category);

    final priceText = widget.price > 0
        ? 'LKR ${Formatters.compactCurrency(widget.price)}'
        : 'FREE';

    const limeAccent = Color(0xFF8BE232);
    final borderColor = widget.isSelected ? limeAccent : Colors.white;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: widget.isSelected ? 1.3 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. PRICE BUBBLE (Above selected pin only)
            if (widget.isSelected) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: limeAccent, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  priceText,
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    height: 1.1,
                  ),
                ),
              ),
              CustomPaint(
                size: const Size(8, 4),
                painter: _BubbleTailPainter(
                  color: surfaceColor,
                  borderColor: limeAccent,
                ),
              ),
              const SizedBox(height: 2),
            ],

            // 2. PIN HEAD & PULSING RING
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing ring behind selected pin
                if (widget.isSelected)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final val = _pulseController.value;
                      final scale = 1.0 + (val * 0.7);
                      final opacity = (1.0 - val).clamp(0.0, 1.0);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: limeAccent.withValues(alpha: opacity * 0.8),
                              width: 2.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Main Pin Body (40x40 circle + bottom tail)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: borderColor,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          categoryIcon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    // Small triangle tail pointing down to exact lat/lng
                    CustomPaint(
                      size: const Size(12, 7),
                      painter: _PinTailPainter(
                        color: categoryColor,
                        borderColor: borderColor,
                        borderWidth: 2.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 3. ZOOM PRICE LABEL (Unselected only, zoom >= 14)
            if (!widget.isSelected && widget.showPriceLabel) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: surfaceColor.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: customColors.fieldBorder.withValues(alpha: 0.7),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  priceText,
                  style: TextStyle(
                    color: textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Modern cluster marker with Purple to Pink gradient, bold count, 3px white border and shadow
class EventMapCluster extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const EventMapCluster({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double size = count < 5 ? 44.0 : (count < 10 ? 52.0 : 60.0);
    final double fontSize = count < 5 ? 14.0 : (count < 10 ? 16.0 : 18.0);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8B5CF6), // Purple
                Color(0xFFEC4899), // Pink
              ],
            ),
            border: Border.all(color: Colors.white, width: 3.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.45),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pulsing blue dot marker for the user's live position
class UserLocationDotMarker extends StatefulWidget {
  const UserLocationDotMarker({super.key});

  @override
  State<UserLocationDotMarker> createState() => _UserLocationDotMarkerState();
}

class _UserLocationDotMarkerState extends State<UserLocationDotMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final val = _pulseController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing translucent outer wave
            Container(
              width: 14 + (val * 24),
              height: 14 + (val * 24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3B82F6).withValues(alpha: (1.0 - val) * 0.4),
              ),
            ),
            // Solid blue GPS dot with white ring
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
