import 'package:flutter/material.dart';

/// Centralized Color Tokens and ThemeExtension for Light and Dark Modes
class AppColors {
  // Dark Palette (Default Dark Theme)
  static const Color backgroundDark = Color(0xFF0F0D1A);
  static const Color surfaceDark = Color(0xFF1B1830);
  static const Color fieldFillDark = Color(0xFF25213F);
  static const Color borderDark = Color(0xFF2F2A4D);
  static const Color textPrimaryDark = Color(0xFFF2F2FA);
  static const Color textSecondaryDark = Color(0xFFA0A0B8);
  static const Color primaryDarkTheme = Color(0xFF8B5CF6);  // Purple Accent

  // Light Palette (AI Property Finder Style)
  static const Color backgroundLight = Color(0xFFF6F6F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color fieldFillLight = Color(0xFFF0EFF5);
  static const Color borderLight = Color(0xFFE4E2EE);
  static const Color textPrimaryLight = Color(0xFF0F0D1A);
  static const Color textSecondaryLight = Color(0xFF6B6B80);
  static const Color primaryLightTheme = Color(0xFF7C3AED); // Deep Purple Accent

  // Shared Brand & Accent Tokens
  static const Color accentLime = Color(0xFF8BE232);        // Reference Lime CTA
  static const Color primary = Color(0xFF6C4DFF);           // Violet Base
  static const Color secondary = Color(0xFFFF6B6B);         // Coral
  static const Color tertiary = Color(0xFF00C2A8);          // Teal

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Radius Tokens
  static const double radiusInput = 14.0;
  static const double radiusCard = 16.0;
  static const double radiusSheet = 24.0;
  static const double radiusChip = 999.0;
}

/// ThemeExtension allowing type-safe context-aware color lookups across both themes
@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color background;
  final Color surface;
  final Color fieldFill;
  final Color fieldBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentPurple;
  final Color accentLime;

  const AppCustomColors({
    required this.background,
    required this.surface,
    required this.fieldFill,
    required this.fieldBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentPurple,
    required this.accentLime,
  });

  static const dark = AppCustomColors(
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    fieldFill: AppColors.fieldFillDark,
    fieldBorder: AppColors.borderDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    accentPurple: AppColors.primaryDarkTheme,
    accentLime: AppColors.accentLime,
  );

  static const light = AppCustomColors(
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    fieldFill: AppColors.fieldFillLight,
    fieldBorder: AppColors.borderLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
    accentPurple: AppColors.primaryLightTheme,
    accentLime: AppColors.accentLime,
  );

  @override
  AppCustomColors copyWith({
    Color? background,
    Color? surface,
    Color? fieldFill,
    Color? fieldBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? accentPurple,
    Color? accentLime,
  }) {
    return AppCustomColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      fieldFill: fieldFill ?? this.fieldFill,
      fieldBorder: fieldBorder ?? this.fieldBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accentPurple: accentPurple ?? this.accentPurple,
      accentLime: accentLime ?? this.accentLime,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      fieldFill: Color.lerp(fieldFill, other.fieldFill, t)!,
      fieldBorder: Color.lerp(fieldBorder, other.fieldBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accentPurple: Color.lerp(accentPurple, other.accentPurple, t)!,
      accentLime: Color.lerp(accentLime, other.accentLime, t)!,
    );
  }
}

extension AppCustomColorsExtension on BuildContext {
  AppCustomColors get customColors =>
      Theme.of(this).extension<AppCustomColors>() ?? AppCustomColors.dark;
}
