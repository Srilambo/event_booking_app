import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme_controller.dart';
import 'app_colors.dart';

/// Floating theme toggle button supporting free 2D dragging, 4-edge snapping & drag-off hiding,
/// 4-edge restore handle, SafeArea clamping, and SharedPreferences position persistence.
class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key});

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  double? _dragX;
  double? _dragY;
  Offset _startGlobalPos = Offset.zero;
  bool _isDragging = false;
  bool _nearEdge = false;

  AnimationController? _animController;
  Animation<Offset>? _snapAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  void _snapTo(Offset targetPos, VoidCallback onComplete) {
    if (_animController == null) return;
    final startPos = Offset(_dragX!, _dragY!);

    _snapAnimation = Tween<Offset>(begin: startPos, end: targetPos).animate(
      CurvedAnimation(parent: _animController!, curve: Curves.easeOutCubic),
    );

    _animController!.reset();
    void listener() {
      if (_snapAnimation != null) {
        setState(() {
          _dragX = _snapAnimation!.value.dx;
          _dragY = _snapAnimation!.value.dy;
        });
      }
    }

    _animController!.addListener(listener);
    _animController!.forward().then((_) {
      _animController!.removeListener(listener);
      onComplete();
    });
  }

  String _determineEdge(double cX, double cY, double sWidth, double sHeight) {
    if (cY < 0) return 'top';
    if (cY > sHeight) return 'bottom';
    if (cX < 0) return 'left';
    if (cX > sWidth) return 'right';
    return cX < sWidth / 2 ? 'left' : 'right';
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    final isDark = themeController.isDarkMode(context);
    final customColors = context.customColors;

    return Obx(() {
      final currentRoute = themeController.currentRoute;
      final isHidden = themeController.isFloatingButtonHidden;
      final lastEdge = themeController.lastEdge;

      debugPrint('ThemeToggleButton render: route="$currentRoute", hidden=$isHidden, xFrac=${themeController.positionXFraction}, yFrac=${themeController.positionYFraction}');

      // 1. Hide ONLY on Login and Register screens
      final isAuthRoute = currentRoute == '/login' ||
          currentRoute == '/register' ||
          currentRoute.endsWith('LoginView') ||
          currentRoute.endsWith('RegisterView');

      if (isAuthRoute) {
        return const SizedBox.shrink();
      }

      // 2. Hide when virtual keyboard is open (threshold prevents subpixel false positives)
      final keyboardOpen = mediaQuery.viewInsets.bottom > 50;
      if (keyboardOpen) {
        return const SizedBox.shrink();
      }

      // RESTORE HANDLE: When hidden, show edge handle on the exact edge
      if (isHidden) {
        final handleY = (themeController.positionYFraction * screenHeight)
            .clamp(topPadding + 20.0, screenHeight - bottomPadding - 60.0);
        final handleX = (themeController.positionXFraction * screenWidth)
            .clamp(20.0, screenWidth - 60.0);

        Widget handlePill;
        double? pLeft, pRight, pTop, pBottom;

        if (lastEdge == 'top') {
          pTop = topPadding;
          pLeft = handleX;
          handlePill = Container(
            width: 40,
            height: 10,
            decoration: BoxDecoration(
              color: customColors.accentPurple.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                ),
              ],
            ),
          );
        } else if (lastEdge == 'bottom') {
          pBottom = bottomPadding;
          pLeft = handleX;
          handlePill = Container(
            width: 40,
            height: 10,
            decoration: BoxDecoration(
              color: customColors.accentPurple.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                ),
              ],
            ),
          );
        } else if (lastEdge == 'left') {
          pLeft = 0;
          pTop = handleY;
          handlePill = Container(
            width: 10,
            height: 40,
            decoration: BoxDecoration(
              color: customColors.accentPurple.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                ),
              ],
            ),
          );
        } else {
          // 'right'
          pRight = 0;
          pTop = handleY;
          handlePill = Container(
            width: 10,
            height: 40,
            decoration: BoxDecoration(
              color: customColors.accentPurple.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                ),
              ],
            ),
          );
        }

        return Positioned(
          left: pLeft,
          right: pRight,
          top: pTop,
          bottom: pBottom,
          child: Material(
            type: MaterialType.transparency,
            child: Semantics(
              label: 'Show floating theme button',
              button: true,
              child: GestureDetector(
                onTap: () => themeController.setFloatingButtonHidden(false),
                child: handlePill,
              ),
            ),
          ),
        );
      }

      // Clamping coordinates strictly within SafeArea boundaries
      final minX = 16.0;
      final maxX = (screenWidth - 68.0).clamp(minX, screenWidth);
      final minY = topPadding + 16.0;
      final maxY = (screenHeight - bottomPadding - 68.0).clamp(minY, screenHeight);

      final rawX = _dragX ?? (themeController.positionXFraction * screenWidth);
      final rawY = _dragY ?? (themeController.positionYFraction * screenHeight);

      final currentX = rawX.clamp(minX, maxX);
      final currentY = rawY.clamp(minY, maxY);

      final buttonBg = _nearEdge
          ? Colors.red.withValues(alpha: 0.4)
          : customColors.surface;
      final borderColor = _nearEdge
          ? Colors.redAccent
          : (isDark ? customColors.accentLime : customColors.accentPurple);
      final iconColor = isDark ? AppColors.accentLime : customColors.accentPurple;

      return Positioned(
        left: currentX,
        top: currentY,
        child: Material(
          type: MaterialType.transparency,
          child: Semantics(
            label: 'Toggle dark/light mode (drag to move, drag off-screen to hide)',
            button: true,
            child: GestureDetector(
                onPanStart: (details) {
                  _startGlobalPos = details.globalPosition;
                  _dragX = currentX;
                  _dragY = currentY;
                  _isDragging = false;
                  _nearEdge = false;
                },
                onPanUpdate: (details) {
                  final dist = (details.globalPosition - _startGlobalPos).distance;
                  if (dist > 6.0) {
                    _isDragging = true;
                  }

                  setState(() {
                    _dragX = (_dragX ?? currentX) + details.delta.dx;
                    _dragY = (_dragY ?? currentY) + details.delta.dy;

                    final cX = _dragX! + 26.0;
                    final cY = _dragY! + 26.0;
                    _nearEdge = cX < 40 ||
                        cX > screenWidth - 40 ||
                        cY < topPadding + 40 ||
                        cY > screenHeight - bottomPadding - 40;
                  });
                },
                onPanEnd: (details) {
                  if (!_isDragging) {
                    themeController.toggleTheme(context);
                    setState(() {
                      _dragX = null;
                      _dragY = null;
                      _isDragging = false;
                      _nearEdge = false;
                    });
                    return;
                  }

                  final cX = _dragX! + 26.0;
                  final cY = _dragY! + 26.0;

                  // Hide if center is dragged outside screen bounds
                  final isDraggedOut = cX < 0 ||
                      cX > screenWidth ||
                      cY < 0 ||
                      cY > screenHeight;

                  final edge = _determineEdge(cX, cY, screenWidth, screenHeight);

                  if (isDraggedOut) {
                    themeController.updatePositionFractions(
                      (cX / screenWidth).clamp(0.0, 1.0),
                      (cY / screenHeight).clamp(0.0, 1.0),
                      edge,
                    );
                    themeController.setFloatingButtonHidden(true);
                    setState(() {
                      _dragX = null;
                      _dragY = null;
                      _isDragging = false;
                      _nearEdge = false;
                    });
                  } else {
                    final targetX = cX < screenWidth / 2 ? 16.0 : (screenWidth - 68.0);
                    final targetY = (cY - 26.0).clamp(minY, maxY);
                    final targetPos = Offset(targetX, targetY);

                    _snapTo(targetPos, () {
                      themeController.updatePositionFractions(
                        targetX / screenWidth,
                        targetY / screenHeight,
                        edge,
                      );
                      setState(() {
                        _dragX = null;
                        _dragY = null;
                        _isDragging = false;
                        _nearEdge = false;
                      });
                    });
                  }
                },
                child: AnimatedScale(
                  scale: _isDragging ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: buttonBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: _isDragging ? 0.45 : (isDark ? 0.5 : 0.2)),
                          blurRadius: _isDragging ? 24 : 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) {
                          return RotationTransition(
                            turns: anim,
                            child: FadeTransition(opacity: anim, child: child),
                          );
                        },
                        child: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          key: ValueKey<bool>(isDark),
                          color: iconColor,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ),
        ),
      );
    });
  }
}
