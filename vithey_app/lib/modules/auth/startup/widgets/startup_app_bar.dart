import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';

class StartupAppBar extends StatelessWidget {
  const StartupAppBar({super.key, required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.scheme.surface,
        border: Border(bottom: BorderSide(color: context.appColors.border)),
      ),
      child: Row(
        children: [
          const AppLogo(size: 30),
          const Spacer(),
          CustomButton(
            label: AppStrings.skip,
            onPressed: onSkip,
            variant: CustomButtonVariant.ghost,
          ),
        ],
      ),
    );
  }
}
