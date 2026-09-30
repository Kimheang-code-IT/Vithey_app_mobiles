import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/dark_theme.dart';
import 'package:aub_connect_app/core/theme/light_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => buildLightTheme();
  static ThemeData dark() => buildDarkTheme();

  static ThemeMode fromStorage(String? value) {
    if (value == 'dark') return ThemeMode.dark;
    if (value == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  static String toStorage(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }
}
