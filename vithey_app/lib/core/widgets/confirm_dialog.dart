import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Color presets for the confirm button.
enum ConfirmDialogVariant {
  /// Generic confirmations (save, continue, clear) — primary teal.
  neutral,

  /// Irreversible actions (logout, delete, sign out everywhere) — red.
  destructive,
}

/// Shows the app-wide confirmation dialog.
///
/// Uses a Material [Dialog] (not shadcn AlertDialog) so action buttons get
/// bounded width constraints — shadcn's action row is unconstrained and
/// freezes the UI when paired with [CustomButton].
///
/// Returns `true` when confirmed, `false` when cancelled, and `null` when
/// dismissed via the scrim or back button.
Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = AppStrings.confirm,
  String cancelLabel = AppStrings.cancel,
  ConfirmDialogVariant variant = ConfirmDialogVariant.neutral,
  Color? confirmColor,
  Color? confirmForegroundColor,
  Color? cancelColor,
  Color? cancelForegroundColor,
  bool barrierDismissible = true,
}) {
  return Get.dialog<bool>(
    ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      variant: variant,
      confirmColor: confirmColor,
      confirmForegroundColor: confirmForegroundColor,
      cancelColor: cancelColor,
      cancelForegroundColor: cancelForegroundColor,
    ),
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black45,
  );
}

/// App-wide confirmation dialog.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = AppStrings.confirm,
    this.cancelLabel = AppStrings.cancel,
    this.variant = ConfirmDialogVariant.neutral,
    this.confirmColor,
    this.confirmForegroundColor,
    this.cancelColor,
    this.cancelForegroundColor,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final ConfirmDialogVariant variant;

  /// Kept for API compatibility; styling is driven by [variant].
  final Color? confirmColor;
  final Color? confirmForegroundColor;
  final Color? cancelColor;
  final Color? cancelForegroundColor;

  void _pop(BuildContext context, bool result) {
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDestructive = variant == ConfirmDialogVariant.destructive;
    final dialogWidth =
        (MediaQuery.sizeOf(context).width - 48).clamp(280.0, 420.0);

    return Dialog(
      backgroundColor: colors.cardSurface,
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: dialogWidth,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.start,
                style: context.text.titleLarge?.copyWith(color: colors.heading),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.start,
                style: context.text.bodyMedium
                    ?.copyWith(color: colors.muted, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: cancelLabel,
                      variant: CustomButtonVariant.ghost,
                      onPressed: () => _pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: confirmLabel,
                      variant: isDestructive
                          ? CustomButtonVariant.destructive
                          : CustomButtonVariant.primary,
                      onPressed: () => _pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
