import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static bool isTestMode = false;

  static TextStyle _safeStyle({
    required String fontFamily,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
  }) {
    if (isTestMode) {
      return TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color);
    }
    if (fontFamily == 'Poppins') {
      return GoogleFonts.poppins(fontSize: fontSize, fontWeight: fontWeight, color: color);
    } else {
      return GoogleFonts.inter(fontSize: fontSize, fontWeight: fontWeight, color: color);
    }
  }

  static TextStyle displayLarge(Color color) => _safeStyle(
        fontFamily: 'Poppins',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle displayMedium(Color color) => _safeStyle(
        fontFamily: 'Poppins',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle title(Color color) => _safeStyle(
        fontFamily: 'Poppins',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle subtitle(Color color) => _safeStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle body(Color color) => _safeStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle caption(Color color) => _safeStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle button(Color color) => _safeStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      );
}
