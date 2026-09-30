import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';

ThemeData buildDarkTheme() {
  const semantic = AppSemanticColors.dark;
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    textTheme: vitheyTextTheme(semantic),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      secondary: AppColors.secondary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.titleDark,
      onSurfaceVariant: semantic.muted,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkSurface,
    dividerColor: semantic.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        side: BorderSide(color: semantic.border),
      ),
    ),
    dividerTheme: DividerThemeData(color: semantic.border, thickness: 1),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: semantic.inputFill,
      hintStyle: TextStyle(color: semantic.muted, fontSize: VitheyType.title),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(VitheyRadii.field),
        borderSide: BorderSide(color: semantic.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(VitheyRadii.field),
        borderSide: BorderSide(color: semantic.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(VitheyRadii.field),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
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
