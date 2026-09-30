import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Family - Teal
  static const primary = Color(0xFF03B4AC);
  static const primaryLight = Color(0xFF33C7BF);
  static const primaryDark = Color(0xFF027F79);

  // Secondary Family - Green
  static const secondary = Color(0xFF03B03C);
  static const secondaryLight = Color(0xFF25CA2E);
  static const secondaryDark = Color(0xFF028B4A);

  // Accent Family - Grey
  static const accent = Color(0xFFC8CED4);
  static const accentLight = Color(0xFFFFFFFF);
  static const accentDark = Color(0xFF5A636E);

  // Other Colors
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFF9A825);
  static const error = Color(0xFFE42407);
  static const info = Color(0xFF0288D1);

  static const paid = Color(0xFF2E7D32);
  static const unpaid = Color(0xFFE42407);
  static const pending = Color(0xFFFE863F);
  static const overdue = Color(0xFFE42407);

  // Text & chrome — light / dark theme pairs
  static const titleLight = Color(0xFF303236);
  static const bodyLight = Color(0xFF78909C);
  static const borderLight = Color(0xFFE0E0E0);
  static const inputFillLight = Color(0xFFF5F5F5);

  static const titleDark = Color(0xFFF5F5F5);
  static const bodyDark = Color(0xFF9E9EB0);
  static const borderDark = Color(0xFF3A3A4E);
  static const inputFillDark = Color(0xFF2A2A3A);

  /// Light theme page/surface base (= solid white).
  static const lightBackground = accentLight;
  static const lightSurface = accentLight;
  static const lightText = Color(0xFF1A1A2E);

  static const darkBackground = Color(0xFF12121A);
  static const darkSurface = Color(0xFF1E1E2C);
  static const darkText = titleDark;

  /// Teal mid-layer = [primaryLight] at 50% over [background].
  static Color waveRearOn(Color background) {
    return Color.alphaBlend(
      primaryLight.withValues(alpha: 0.50),
      background,
    );
  }

  /// White mid-layer = [accentLight] at 50% over [background].
  static Color accentOn(Color background) {
    return Color.alphaBlend(
      accentLight.withValues(alpha: 0.50),
      background,
    );
  }
}
