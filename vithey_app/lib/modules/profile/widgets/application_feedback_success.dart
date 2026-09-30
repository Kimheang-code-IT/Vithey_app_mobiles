import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class ApplicationFeedbackSuccess {
  static Future<void> show() {
    return showDialog<void>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => const _ApplicationFeedbackSuccessDialog(),
    );
  }
}

class _ApplicationFeedbackSuccessDialog extends StatelessWidget {
  const _ApplicationFeedbackSuccessDialog();

  void _close() => Get.back<void>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: context.appColors.cardSurface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: CustomButton(
                label: AppStrings.back,
                variant: CustomButtonVariant.ghost,
                onPressed: _close,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 72,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _FeedbackSubmittedHero(),
                    const SizedBox(height: 18),
                    Text(
                      'Feedback Submitted!',
                      style: context.text.titleLarge?.copyWith(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 310),
                      child: Text(
                        'Your feedback has been submitted successfully to the candidate.',
                        style: context.text.bodyMedium?.copyWith(
                          color: context.appColors.muted,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          label: 'Done',
                          onPressed: _close,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackSubmittedHero extends StatelessWidget {
  const _FeedbackSubmittedHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 22,
            top: 30,
            child: Transform.rotate(
              angle: -0.08,
              child: VitheyIcon(
                LucideIcons.fileText,
                size: 76,
                color: AppColors.info.withValues(alpha: 0.2),
              ),
            ),
          ),
          const VitheyIcon(
            LucideIcons.fileText,
            size: 82,
            color: AppColors.info,
          ),
          Positioned(
            right: 12,
            top: 60,
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const VitheyIcon(
                LucideIcons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            child: Row(
              children: List.generate(
                3,
                (index) => Container(
                  width: 3,
                  height: 14 + (index * 6),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
