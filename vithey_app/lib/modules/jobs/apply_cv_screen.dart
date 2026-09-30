import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/modules/jobs/apply_cv_controller.dart';
import 'package:aub_connect_app/modules/jobs/widgets/application_submitted_hero.dart';
import 'package:aub_connect_app/modules/jobs/widgets/apply_job_context.dart';
import 'package:aub_connect_app/modules/jobs/widgets/apply_job_stepper.dart';
import 'package:aub_connect_app/modules/jobs/widgets/cv_upload_zone.dart';
import 'package:aub_connect_app/modules/jobs/widgets/job_match_score_card.dart';
import 'package:aub_connect_app/modules/jobs/widgets/privacy_footer_note.dart';
import 'package:aub_connect_app/modules/jobs/widgets/position_selector.dart';
import 'package:aub_connect_app/modules/jobs/widgets/review_cv_card.dart';
import 'package:aub_connect_app/modules/jobs/widgets/selected_cv_card.dart';
import 'package:aub_connect_app/modules/jobs/widgets/what_happens_next_list.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ApplyCvScreen extends GetView<ApplyCvController> {
  const ApplyCvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await controller.handleBack();
        if (shouldPop) Get.back();
      },
      child: Scaffold(
        backgroundColor: context.appColors.cardSurface,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          backgroundColor: context.appColors.cardSurface,
          foregroundColor: context.appColors.heading,
          surfaceTintColor: Colors.transparent,
          title: Text(
            AppStrings.applyJobTitle,
            style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          leading: BackButton(
            onPressed: () async {
              final shouldPop = await controller.handleBack();
              if (shouldPop) Get.back();
            },
          ),
        ),
        body: SafeArea(
          child: Obx(() {
            if (controller.phase.value == ApplyCvPhase.loadingJob) {
              return const LoadingWidget();
            }
            if (controller.phase.value == ApplyCvPhase.error) {
              return AppErrorWidget(
                message: controller.submitError.value,
                onRetry: controller.retryLoad,
              );
            }
            if (controller.isAlreadyApplied) {
              return _AlreadyAppliedView(controller: controller);
            }

            final stepIndex =
                controller.currentStep.value == ApplyCvStep.upload ? 0 : 1;
            return Column(
              children: [
                ApplyJobStepper(currentStep: stepIndex),
                Expanded(
                  child: controller.currentStep.value == ApplyCvStep.upload
                      ? _UploadStep(controller: controller)
                      : _ReviewStep(controller: controller),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _AlreadyAppliedView extends StatelessWidget {
  const _AlreadyAppliedView({required this.controller});

  final ApplyCvController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ApplicationSubmittedHero(),
            const SizedBox(height: 18),
            Text(
              'Application Already Submitted!',
              textAlign: TextAlign.center,
              style: context.text.headlineSmall,
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 330),
              child: Text(
                'Your application for ${controller.jobTitle} has already been '
                'submitted. View its latest status and updates.',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(color: context.appColors.muted, height: 1.45),
              ),
            ),
            const SizedBox(height: 22),
            CustomButton(
              label: AppStrings.viewApplicationStatus,
              variant: CustomButtonVariant.outline,
              icon: LucideIcons.eye,
              onPressed: controller.viewApplicationStatus,
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadStep extends StatelessWidget {
  const _UploadStep({required this.controller});

  final ApplyCvController controller;

  @override
  Widget build(BuildContext context) {
    final eligible =
        controller.eligibility.value?.eligibility == JobEligibility.eligible;
    final enabled = eligible && !controller.isSubmitting.value;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: Text(
                    AppStrings.uploadYourCv,
                    style: context.text.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Text(
                    AppStrings.uploadCvSubtitle,
                    style: context.text.bodySmall,
                  ),
                ),
                if (!eligible)
                  ApplyJobContext(
                    job: controller.job.value,
                    eligibility: controller.eligibility.value,
                    isLoading: false,
                    onRetry: controller.retryLoad,
                    compact: true,
                  ),
                if (eligible) ...[
                  PositionSelector(
                    position: controller.positionLabel,
                  ),
                  _buildCvSection(context, enabled),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (controller.isAlreadyApplied)
                CustomButton(
                  label: AppStrings.viewApplicationStatus,
                  icon: LucideIcons.eye,
                  onPressed: controller.viewApplicationStatus,
                )
              else if (!eligible)
                CustomButton(
                  label: AppStrings.back,
                  variant: CustomButtonVariant.outline,
                  onPressed: () => Get.back(),
                )
              else
                CustomButton(
                  label: AppStrings.continueLabel,
                  onPressed:
                      controller.canContinue ? controller.goToReview : null,
                ),
              if (eligible) const PrivacyFooterNote(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCvSection(BuildContext context, bool enabled) {
    final saved = controller.savedCv.value;
    final local = controller.localCv.value;
    final mode = controller.selectionMode.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (local != null)
          LocalSelectedCvCard(
            file: local,
            errorText: controller.fileError.value,
            enabled: enabled,
            showSaveAsDefault: mode == CvSelectionMode.localApplicationOnly,
            saveAsDefault: controller.saveAsDefault.value,
            onReplace: () => controller.pickLocalCv(
                updateDefault: mode == CvSelectionMode.localUpdateDefault),
            onRemove: controller.removeLocalCv,
            onSaveAsDefaultChanged: controller.toggleSaveAsDefault,
          )
        else if (saved != null && mode == CvSelectionMode.saved)
          SavedSelectedCvCard(
            savedCv: saved,
            enabled: enabled,
            onReplace: () => controller.pickLocalCv(updateDefault: false),
            onRemove: controller.clearCvSelection,
          )
        else
          CvUploadZone(
            policyLabel: controller.acceptedPolicyLabel,
            enabled: enabled,
            onTap: () => controller.pickLocalCv(updateDefault: false),
          ),
        if (saved != null && mode != CvSelectionMode.saved && local == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: CustomButton(
              label: '${AppStrings.useSavedCv}: ${saved.fileName}',
              onPressed: enabled ? controller.useSavedCv : null,
              icon: LucideIcons.fileText,
              variant: CustomButtonVariant.outline,
            ),
          ),
        if (controller.savedCvs.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: CustomButton(
              label: 'Choose CV (${controller.savedCvs.length})',
              onPressed: enabled
                  ? () => controller.openChooseSavedCv(context)
                  : null,
              icon: LucideIcons.layoutTemplate,
              variant: CustomButtonVariant.outline,
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: CustomButton(
            label: 'Create CV with AI',
            icon: LucideIcons.sparkles,
            variant: CustomButtonVariant.outline,
            onPressed: enabled ? controller.openAiCvCreator : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Text(
            'Or upload / update a CV manually above.',
            textAlign: TextAlign.center,
            style: context.text.bodySmall?.copyWith(fontSize: 12),
          ),
        ),
        if (controller.fileError.value.isNotEmpty && local == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              controller.fileError.value,
              style: context.text.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.controller});

  final ApplyCvController controller;

  @override
  Widget build(BuildContext context) {
    final enabled = !controller.isSubmitting.value;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: Text(
                    AppStrings.reviewYourCv,
                    style: context.text.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Text(
                    AppStrings.reviewCvSubtitle,
                    style: context.text.bodySmall,
                  ),
                ),
                ReviewCvCard(
                  fileName: controller.selectedFileName,
                  sizeLabel: controller.selectedFileSizeLabel,
                  enabled: enabled,
                  onRemove: controller.removeCvAndGoBack,
                ),
                if (controller.hasDetectedPosition ||
                    controller.organizationName.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Applying for ${controller.positionLabel}'
                      '${controller.organizationName.isNotEmpty ? ' at ${controller.organizationName}' : ''}',
                      style: context.text.bodySmall,
                    ),
                  ),
                ],
                // Block 5 — AI match card, review step only (AI-JOB-07).
                if (controller.jobPostId != null &&
                    Get.find<FeatureFlags>().useAiJobMatch) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: JobMatchScoreCard(
                      jobPostId: controller.jobPostId!,
                      jobTitle: controller.jobTitle,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const WhatHappensNextList(),
                if (controller.submitError.value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      controller.submitError.value,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomButton(
                label: controller.submitLabel.value,
                isLoading: controller.isSubmitting.value,
                onPressed: controller.canSubmit ? controller.submit : null,
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: AppStrings.back,
                variant: CustomButtonVariant.outline,
                icon: LucideIcons.arrowLeft,
                onPressed: enabled ? controller.goToUpload : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
