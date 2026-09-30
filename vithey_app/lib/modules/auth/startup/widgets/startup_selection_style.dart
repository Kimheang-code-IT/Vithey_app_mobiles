import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// Shared selected/unselected chrome used by all Startup option widgets.
/// Layout/shape stay per-page; only active/inactive colors are shared.
class StartupSelectionStyle {
  const StartupSelectionStyle._();

  static Color fill(BuildContext context, {required bool selected}) {
    if (!selected) return context.appColors.inputFill;
    // Slightly stronger wash in dark mode so selection reads clearly.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.12);
  }

  static Color border(BuildContext context, {required bool selected}) {
    return selected ? AppColors.primary : context.appColors.border;
  }

  static Color icon(BuildContext context, {required bool selected}) {
    return selected ? AppColors.primary : context.appColors.muted;
  }

  static Color label(BuildContext context, {required bool selected}) {
    return selected ? AppColors.primary : context.appColors.heading;
  }
}
