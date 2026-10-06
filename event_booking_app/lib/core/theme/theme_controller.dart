import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central ThemeController managing ThemeMode, Floating Toggle position, and persistence
class ThemeController extends GetxController {
  static const String _keyThemeMode = 'theme_mode_preference';
  static const String _keyVersion = 'theme_btn_v4_force_show';
  static const String _keyButtonHidden = 'floating_button_hidden_v4';
  static const String _keyXFrac = 'floating_button_x_frac_v4';
  static const String _keyYFrac = 'floating_button_y_frac_v4';
  static const String _keyLastEdge = 'floating_button_edge_v4';

  final Rx<ThemeMode> rxThemeMode = ThemeMode.system.obs;
  final RxBool rxIsFloatingButtonHidden = false.obs;
  final RxDouble rxPositionXFraction = 0.85.obs;
  final RxDouble rxPositionYFraction = 0.78.obs;
  final RxString rxLastEdge = 'right'.obs;
  final RxString rxCurrentRoute = '/home'.obs;

  ThemeMode get themeMode => rxThemeMode.value;
  bool get isFloatingButtonHidden => rxIsFloatingButtonHidden.value;
  double get positionXFraction => rxPositionXFraction.value;
  double get positionYFraction => rxPositionYFraction.value;
  String get lastEdge => rxLastEdge.value;
  String get currentRoute => rxCurrentRoute.value;

  @override
  void onInit() {
    super.onInit();
    _loadStateFromPrefs();
  }

  void updateCurrentRoute(String route) {
    if (route.isNotEmpty && rxCurrentRoute.value != route) {
      rxCurrentRoute.value = route;
      debugPrint('ThemeController route updated: $route');
    }
  }

  Future<void> _loadStateFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedString = prefs.getString(_keyThemeMode);
      if (savedString != null) {
        if (savedString == ThemeMode.light.name) {
          rxThemeMode.value = ThemeMode.light;
        } else if (savedString == ThemeMode.dark.name) {
          rxThemeMode.value = ThemeMode.dark;
        } else {
          rxThemeMode.value = ThemeMode.system;
        }
      }

      // Force button to be VISIBLE on v4 startup reset
      final isV4 = prefs.getBool(_keyVersion) ?? false;
      if (!isV4) {
        await prefs.setBool(_keyVersion, true);
        await prefs.setBool(_keyButtonHidden, false);
        await prefs.setDouble(_keyXFrac, 0.85);
        await prefs.setDouble(_keyYFrac, 0.78);
        await prefs.setString(_keyLastEdge, 'right');
      }

      final hidden = prefs.getBool(_keyButtonHidden) ?? false;
      final x = prefs.getDouble(_keyXFrac) ?? 0.85;
      final y = prefs.getDouble(_keyYFrac) ?? 0.78;
      final edge = prefs.getString(_keyLastEdge) ?? 'right';

      rxIsFloatingButtonHidden.value = hidden;
      rxPositionXFraction.value = (x.isNaN || x < 0.0 || x > 1.0) ? 0.85 : x;
      rxPositionYFraction.value = (y.isNaN || y < 0.0 || y > 1.0) ? 0.78 : y;
      rxLastEdge.value = (edge == 'left' || edge == 'right' || edge == 'top' || edge == 'bottom') ? edge : 'right';

      debugPrint('ThemeController initialized: hidden=${rxIsFloatingButtonHidden.value}, xFrac=${rxPositionXFraction.value}, yFrac=${rxPositionYFraction.value}');
    } catch (e) {
      debugPrint('ThemeController prefs error: $e');
    }
  }

  Future<void> toggleTheme(BuildContext context) async {
    final currentIsDark = isDarkMode(context);
    final nextMode = currentIsDark ? ThemeMode.light : ThemeMode.dark;

    rxThemeMode.value = nextMode;
    Get.changeThemeMode(nextMode);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyThemeMode, nextMode.name);
    } catch (_) {}
  }

  Future<void> setFloatingButtonHidden(bool hidden) async {
    rxIsFloatingButtonHidden.value = hidden;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyButtonHidden, hidden);
    } catch (_) {}
  }

  Future<void> updatePositionFractions(double xFrac, double yFrac, String edge) async {
    final safeX = xFrac.clamp(0.02, 0.98);
    final safeY = yFrac.clamp(0.05, 0.95);

    rxPositionXFraction.value = safeX;
    rxPositionYFraction.value = safeY;
    rxLastEdge.value = edge;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyXFrac, safeX);
      await prefs.setDouble(_keyYFrac, safeY);
      await prefs.setString(_keyLastEdge, edge);
    } catch (_) {}
  }

  bool isDarkMode(BuildContext context) {
    if (rxThemeMode.value == ThemeMode.dark) return true;
    if (rxThemeMode.value == ThemeMode.light) return false;
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }
}
