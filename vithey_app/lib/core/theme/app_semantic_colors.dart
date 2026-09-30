import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';

/// App [TextTheme] wired from [VitheyType] / [VitheyWeight] + semantic colors.
///
/// Shared by the light and dark themes so call sites can use
/// `context.text.titleSmall` etc. instead of inline `TextStyle` blobs.
TextTheme vitheyTextTheme(AppSemanticColors semantic) {
  return TextTheme(
    headlineSmall: TextStyle(
        fontSize: VitheyType.display,
        fontWeight: VitheyWeight.bold,
        color: semantic.heading),
    titleLarge: TextStyle(
        fontSize: VitheyType.titleLg,
        fontWeight: VitheyWeight.bold,
        color: semantic.heading),
    titleMedium: TextStyle(
        fontSize: VitheyType.title,
        fontWeight: VitheyWeight.semibold,
        color: semantic.heading),
    titleSmall: TextStyle(
        fontSize: VitheyType.titleSm,
        fontWeight: VitheyWeight.semibold,
        color: semantic.heading),
    bodyLarge: TextStyle(
        fontSize: VitheyType.title,
        fontWeight: VitheyWeight.regular,
        color: semantic.heading),
    bodyMedium: TextStyle(
        fontSize: VitheyType.body,
        fontWeight: VitheyWeight.regular,
        color: semantic.heading),
    bodySmall: TextStyle(
        fontSize: VitheyType.subtitle,
        fontWeight: VitheyWeight.regular,
        color: semantic.muted),
    labelLarge: TextStyle(
        fontSize: VitheyType.body,
        fontWeight: VitheyWeight.semibold,
        color: semantic.heading),
    labelMedium: TextStyle(
        fontSize: VitheyType.meta,
        fontWeight: VitheyWeight.medium,
        color: semantic.muted),
    labelSmall: TextStyle(
        fontSize: VitheyType.caption,
        fontWeight: VitheyWeight.medium,
        color: semantic.muted),
  );
}

/// Semantic colors that adapt to light/dark mode.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.bodyBackground,
    required this.cardSurface,
    required this.heading,
    required this.muted,
    required this.inputFill,
    required this.border,
    required this.subtleShadow,
    required this.dangerSurface,
  });

  final Color bodyBackground;
  final Color cardSurface;
  final Color heading;
  final Color muted;
  final Color inputFill;
  final Color border;
  final Color subtleShadow;
  final Color dangerSurface;

  static const light = AppSemanticColors(
    bodyBackground: AppColors.accentLight,
    cardSurface: AppColors.accentLight,
    heading: AppColors.titleLight,
    muted: AppColors.bodyLight,
    inputFill: AppColors.inputFillLight,
    border: AppColors.borderLight,
    subtleShadow: Color(0x0A000000),
    dangerSurface: Color(0xFFFFEBEE),
  );

  static const dark = AppSemanticColors(
    bodyBackground: AppColors.darkBackground,
    cardSurface: AppColors.darkSurface,
    heading: AppColors.titleDark,
    muted: AppColors.bodyDark,
    inputFill: AppColors.inputFillDark,
    border: AppColors.borderDark,
    subtleShadow: Color(0x33000000),
    dangerSurface: Color(0xFF3D2024),
  );

  static AppSemanticColors of(BuildContext context) {
    return Theme.of(context).extension<AppSemanticColors>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  @override
  AppSemanticColors copyWith({
    Color? bodyBackground,
    Color? cardSurface,
    Color? heading,
    Color? muted,
    Color? inputFill,
    Color? border,
    Color? subtleShadow,
    Color? dangerSurface,
  }) {
    return AppSemanticColors(
      bodyBackground: bodyBackground ?? this.bodyBackground,
      cardSurface: cardSurface ?? this.cardSurface,
      heading: heading ?? this.heading,
      muted: muted ?? this.muted,
      inputFill: inputFill ?? this.inputFill,
      border: border ?? this.border,
      subtleShadow: subtleShadow ?? this.subtleShadow,
      dangerSurface: dangerSurface ?? this.dangerSurface,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      bodyBackground: Color.lerp(bodyBackground, other.bodyBackground, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      heading: Color.lerp(heading, other.heading, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      border: Color.lerp(border, other.border, t)!,
      subtleShadow: Color.lerp(subtleShadow, other.subtleShadow, t)!,
      dangerSurface: Color.lerp(dangerSurface, other.dangerSurface, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppSemanticColors get appColors => AppSemanticColors.of(this);
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
