import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';

ThemeData buildLightTheme() {
  const semantic = AppSemanticColors.light;
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    textTheme: vitheyTextTheme(semantic),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.accentLight,
      onSurface: AppColors.titleLight,
      onSurfaceVariant: AppColors.bodyLight,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.accentLight,
    canvasColor: AppColors.accentLight,
    cardColor: AppColors.accentLight,
    dividerColor: AppColors.borderLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.accentLight,
      foregroundColor: AppColors.lightText,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: AppColors.accentLight,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: AppColors.accentLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        side: const BorderSide(color: AppColors.borderLight),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.borderLight, thickness: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.accentLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: semantic.inputFill,
      hintStyle: const TextStyle(color: AppColors.bodyLight, fontSize: VitheyType.title),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(VitheyRadii.field),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(VitheyRadii.field),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(VitheyRadii.field),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.accentLight,
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VitheyRadii.pill),
        ),
      ),
    ),
    extensions: const [semantic],
  );
}
