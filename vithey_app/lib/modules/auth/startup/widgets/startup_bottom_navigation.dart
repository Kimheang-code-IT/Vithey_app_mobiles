import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/modules/auth/startup/widgets/startup_step_indicator.dart';
import 'package:flutter/material.dart';

class StartupBottomNavigation extends StatelessWidget {
  const StartupBottomNavigation({
    super.key,
    required this.currentStep,
    required this.onBack,
    required this.onNext,
    this.nextLabel = AppStrings.next,
    this.showBack = true,
  });

  final int currentStep;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String nextLabel;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StartupStepIndicator(currentStep: currentStep),
          const SizedBox(height: 12),
          Row(
            children: [
              if (showBack)
                CustomButton(
                  label: AppStrings.back,
                  variant: CustomButtonVariant.ghost,
                  foregroundColor: context.appColors.heading,
                  onPressed: onBack,
                )
              else
                const SizedBox(width: 72),
              const Spacer(),
              CustomButton(
                label: nextLabel,
                onPressed: onNext,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
