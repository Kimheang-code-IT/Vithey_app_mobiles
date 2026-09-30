import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';

/// Delete-message confirmation — left-aligned copy, Cancel + teal Delete (chat).
class DeleteMessageDialog {
  DeleteMessageDialog._();

  static Future<bool?> show() {
    final context = Get.context;
    if (context == null) return Future.value(null);

    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _DeleteMessageSheet(),
    );
  }
}

class _DeleteMessageSheet extends StatelessWidget {
  const _DeleteMessageSheet();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Material(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 22, 20, 16 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.deleteMessageTitle,
                style: context.text.headlineSmall?.copyWith(
                  fontSize: 20,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.deleteMessageBody,
                style: context.text.bodyMedium?.copyWith(
                  color: colors.muted,
                  height: 1.45,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton(
                      label: AppStrings.cancel,
                      onPressed: () => Navigator.of(context).pop(false),
                      variant: CustomButtonVariant.ghost,
                      foregroundColor: colors.heading,
                    ),
                    const SizedBox(width: 8),
                    CustomButton(
                      label: AppStrings.delete,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
