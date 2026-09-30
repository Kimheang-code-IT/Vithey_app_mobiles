import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// One callback-style row in a [VitheyActionSheet].
///
/// The sheet closes first, then [onTap] fires. `onTap == null` renders the
/// row disabled (muted, non-interactive).
class VitheyActionSheetItem {
  const VitheyActionSheetItem({
    required this.label,
    this.icon,
    this.onTap,
    this.isDestructive = false,
    this.enabled = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool enabled;

  bool get _isEnabled => enabled && onTap != null;
}

/// One value-style row in a [VitheyActionSheet].
///
/// The sheet closes and resolves to [value]. [enabled] false renders the row
/// muted and non-interactive.
class VitheyActionSheetAction<T> {
  const VitheyActionSheetAction({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.destructive = false,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final bool destructive;
  final bool enabled;
}

/// Bottom action sheet (post menus, notification rows, search results).
///
/// Themed modal bottom sheet using the app semantic tokens — the shadcn
/// overlay stack needs ShadcnApp, which this GetX app does not use.
///
/// [actions] accepts a mix of [VitheyActionSheetItem] (callback style) and
/// [VitheyActionSheetAction<T>] (value style) rows. Value rows resolve the
/// returned future with their [VitheyActionSheetAction.value]; callback rows
/// run their [VitheyActionSheetItem.onTap] after the sheet closes.
Future<T?> showVitheyActionSheet<T>({
  required BuildContext context,
  required String title,
  String? message,
  required List<Object> actions,
  String? cancelLabel,
  Color? barrierColor,
}) {
  final colors = context.appColors;

  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: colors.cardSurface,
    barrierColor: barrierColor ?? Colors.black45,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
    ),
    builder: (sheetContext) => VitheyActionSheet(
      title: title,
      message: message,
      actions: actions,
      cancelLabel: cancelLabel,
    ),
  );
}

/// The sheet content. Usually shown via [showVitheyActionSheet].
class VitheyActionSheet extends StatelessWidget {
  const VitheyActionSheet({
    super.key,
    required this.title,
    this.message,
    required this.actions,
    this.cancelLabel,
  });

  final String title;
  final String? message;
  final List<Object> actions;
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: message == null ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelLarge?.copyWith(color: colors.muted),
            ),
            if (message != null) ...[
              const SizedBox(height: 4),
              Text(
                message!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall
                    ?.copyWith(color: colors.heading, height: 1.3),
              ),
            ],
            const SizedBox(height: 8),
            for (var i = 0; i < actions.length; i++) ...[
              _ActionRow(action: actions[i]),
              if (i < actions.length - 1) const SizedBox(height: 4),
            ],
            if (cancelLabel != null) ...[
              const SizedBox(height: 12),
              CustomButton(
                label: cancelLabel!,
                variant: CustomButtonVariant.ghost,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.action});

  /// Either [VitheyActionSheetItem] or [VitheyActionSheetAction].
  final Object action;

  String get _label => action is VitheyActionSheetItem
      ? (action as VitheyActionSheetItem).label
      : (action as VitheyActionSheetAction).label;

  IconData? get _icon => action is VitheyActionSheetItem
      ? (action as VitheyActionSheetItem).icon
      : (action as VitheyActionSheetAction).icon;

  String? get _subtitle => action is VitheyActionSheetAction
      ? (action as VitheyActionSheetAction).subtitle
      : null;

  bool get _destructive => action is VitheyActionSheetItem
      ? (action as VitheyActionSheetItem).isDestructive
      : (action as VitheyActionSheetAction).destructive;

  bool get _enabled => action is VitheyActionSheetItem
      ? (action as VitheyActionSheetItem)._isEnabled
      : (action as VitheyActionSheetAction).enabled;

  void _resolve(BuildContext context) {
    if (action is VitheyActionSheetItem) {
      final item = action as VitheyActionSheetItem;
      Navigator.of(context).pop();
      item.onTap?.call();
    } else {
      final valueAction = action as VitheyActionSheetAction;
      Navigator.of(context).pop(valueAction.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = !_enabled
        ? colors.muted
        : _destructive
            ? AppColors.error
            : colors.heading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _enabled ? () => _resolve(context) : null,
        borderRadius: BorderRadius.circular(VitheyRadii.pill),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                if (_icon != null) ...[
                  VitheyIcon(_icon!, size: 20, color: foreground),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _label,
                        style: context.text.titleSmall?.copyWith(
                          fontWeight: VitheyWeight.medium,
                          color: foreground,
                        ),
                      ),
                      if (_subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _subtitle!,
                          style: context.text.labelMedium
                              ?.copyWith(height: 1.3),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
