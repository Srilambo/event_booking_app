import 'package:flutter/material.dart';

/// Spacing (8/12/16/24/32) and Radius (12/16/24/999) Design Tokens
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
}

class AppRadius {
  static const double input = 12.0;
  static const double card = 16.0;
  static const double sheet = 24.0;
  static const double chip = 999.0;

  static final BorderRadius borderInput = BorderRadius.circular(input);
  static final BorderRadius borderCard = BorderRadius.circular(card);
  static final BorderRadius borderSheet = BorderRadius.circular(sheet);
  static final BorderRadius borderChip = BorderRadius.circular(chip);
}
