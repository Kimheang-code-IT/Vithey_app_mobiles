import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Rounded pill search field used on Map / Search GenZ chrome (shadcn).
class VitheySearchPill extends StatelessWidget {
  const VitheySearchPill({
    super.key,
    required this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.trailing,
    this.autofocus = false,
    this.focusNode,
    this.compact = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final List<Widget>? trailing;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fontSize = compact ? 13.0 : 14.5;
    final iconSize = compact ? 16.0 : 18.0;
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 8);

    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(VitheyRadii.pill),
      color: colors.cardSurface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.inputFill,
          borderRadius: BorderRadius.circular(VitheyRadii.pill),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.45),
          ),
        ),
        child: shad.TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          border: const Border.fromBorderSide(BorderSide.none),
          filled: false,
          borderRadius: BorderRadius.circular(VitheyRadii.pill),
          padding: padding,
          style: context.text.labelLarge?.copyWith(
            fontSize: fontSize,
            fontWeight: VitheyWeight.medium,
            height: 1.2,
            color: colors.heading,
          ),
          placeholder: Text(
            hintText,
            style: context.text.bodyMedium?.copyWith(
              fontSize: fontSize,
              height: 1.2,
              color: colors.muted,
            ),
          ),
          features: [
            shad.InputFeature.leading(
              VitheyIcon(
                LucideIcons.search,
                size: iconSize,
                color: AppColors.primary,
              ),
            ),
            if (controller.text.isNotEmpty && onClear != null)
              shad.InputFeature.trailing(
                shad.IconButton.text(
                  icon: VitheyIcon(LucideIcons.x, size: 18, color: colors.muted),
                  onPressed: onClear,
                  density: shad.ButtonDensity.compact,
                ),
              ),
            if (trailing != null)
              for (final widget in trailing!)
                shad.InputFeature.trailing(widget),
          ],
        ),
      ),
    );
  }
}
