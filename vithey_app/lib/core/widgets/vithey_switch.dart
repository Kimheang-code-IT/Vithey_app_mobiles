import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// App-wide toggle switch wrapping [shad.Switch].
///
/// On = brand primary. Off = accent grey (never black).
/// The whole 48px-tall area is tappable, not just the track.
class VitheySwitch extends StatelessWidget {
  const VitheySwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final bool value;

  /// Called when the user toggles the switch. Ignored when [enabled] is false.
  final ValueChanged<bool>? onChanged;

  final bool enabled;

  void _handleTap() {
    if (enabled && onChanged != null) onChanged!(!value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Off track: brand accent grey — avoid black/near-black defaults.
    final inactiveColor =
        isDark ? AppColors.accentDark : AppColors.accent;
    final inactiveThumb = isDark ? AppColors.accentLight : Colors.white;

    final switchWidget = shad.Switch(
      value: value,
      onChanged: enabled ? onChanged : null,
      enabled: enabled,
      activeColor: context.scheme.primary,
      inactiveColor: inactiveColor,
      inactiveThumbColor: inactiveThumb,
      activeThumbColor: Colors.white,
      borderRadius: BorderRadius.circular(999),
    );

    if (!enabled) return switchWidget;

    // Surround the track with an opaque 48px tap target.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: SizedBox(
        width: 56,
        height: 48,
        child: Center(child: switchWidget),
      ),
    );
  }
}
