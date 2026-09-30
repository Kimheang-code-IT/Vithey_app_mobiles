import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_field.dart';

/// App-wide "report user" dialog with an optional reason field.
///
/// Returns the trimmed reason when submitted, `null` when cancelled or
/// dismissed. Shared by chat detail and chat profile so the pattern exists
/// exactly once.
Future<String?> showReportReasonDialog({
  required String title,
  String reasonHint = 'Reason for report',
  String submitLabel = 'Report',
}) {
  final context = Get.context;
  if (context == null) return Future.value(null);

  final reasonController = TextEditingController();
  return Get.dialog<String>(
    Dialog(
      backgroundColor: context.appColors.cardSurface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.text.titleLarge
                    ?.copyWith(color: context.appColors.heading),
              ),
              const SizedBox(height: 16),
              VitheyField(
                controller: reasonController,
                hint: reasonHint,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Cancel',
                      onPressed: () => Get.back<String>(),
                      variant: CustomButtonVariant.ghost,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: submitLabel,
                      onPressed: () =>
                          Get.back<String>(result: reasonController.text.trim()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
