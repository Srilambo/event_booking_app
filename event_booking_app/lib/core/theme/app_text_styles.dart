import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Unified Design System Typography matching Poppins (Headings) and Inter (Body)
class AppTextStyles {
  static bool isTestMode = false;

  static TextStyle _safeStyle({
    required String fontFamily,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double height = 1.25,
  }) {
    if (isTestMode) {
      return TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color, height: height);
    }
    if (fontFamily == 'Poppins') {
      return GoogleFonts.poppins(fontSize: fontSize, fontWeight: fontWeight, color: color, height: height);
    } else {
      return GoogleFonts.inter(fontSize: fontSize, fontWeight: fontWeight, color: color, height: height);
    }
  }

  static TextStyle displayLarge(Color color) => _safeStyle(
        fontFamily: 'Poppins',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.15,
      );

  static TextStyle displayMedium(Color color) => _safeStyle(
        fontFamily: 'Poppins',
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: color,
        height: 1.2,
      );

  static TextStyle title(Color color) => _safeStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle subtitle(Color color) => _safeStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle body(Color color) => _safeStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.4,
      );

  static TextStyle caption(Color color) => _safeStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle button(Color color) => _safeStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      );
}
