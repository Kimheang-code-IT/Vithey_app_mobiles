import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/modules/jobs/models/apply_success_args.dart';
import 'package:aub_connect_app/modules/jobs/models/application_status_args.dart';
import 'package:aub_connect_app/modules/jobs/widgets/application_submitted_hero.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ApplySuccessScreen extends StatelessWidget {
  const ApplySuccessScreen({super.key});

  ApplySuccessArgs get _args => ApplySuccessArgs.from(Get.arguments);

  @override
  Widget build(BuildContext context) {
    final args = _args;
    final jobTitle = args.jobTitle.trim();
    final body = jobTitle.isEmpty
        ? AppStrings.applicationSubmittedBody
        : 'Your CV for $jobTitle has been submitted successfully. '
            'It will be reviewed soon. Please stay tuned for updates.';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Get.back(result: args.result);
      },
      child: Scaffold(
        backgroundColor: context.appColors.cardSurface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ApplicationSubmittedHero(),
                  const SizedBox(height: 18),
                  Text(
                    AppStrings.applicationSubmittedTitle,
                    textAlign: TextAlign.center,
                    style: context.text.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 330),
                    child: Text(
                      body,
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium?.copyWith(color: context.appColors.muted, height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 22),
                  CustomButton(
                    label: AppStrings.viewApplicationStatus,
                    variant: CustomButtonVariant.outline,
                    icon: LucideIcons.eye,
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.applicationStatus,
                        arguments: ApplicationStatusArgs(
                          applicationId: args.applicationId,
                          jobPostId: args.jobPostId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
