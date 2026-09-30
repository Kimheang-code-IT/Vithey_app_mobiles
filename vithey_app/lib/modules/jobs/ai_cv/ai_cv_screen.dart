import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/vithey_field.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/ai_cv_controller.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/templates/cv_template_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class AiCvScreen extends GetView<AiCvController> {
  const AiCvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.cancelToApply();
      },
      child: Scaffold(
        backgroundColor: context.appColors.bodyBackground,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          backgroundColor: context.appColors.cardSurface,
          foregroundColor: context.appColors.heading,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Edit template',
            style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          leading: BackButton(onPressed: controller.cancelToApply),
          actions: [
            Obx(() {
              if (controller.phase.value != AiCvPhase.preview) {
                return const SizedBox.shrink();
              }
              if (controller.isBlank) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Regenerate summary',
                onPressed: controller.isRegeneratingSummary.value
                    ? null
                    : controller.regenerateSummary,
                icon: controller.isRegeneratingSummary.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : VitheyIcon(
                        LucideIcons.refreshCw,
                        color: context.appColors.heading,
                      ),
              );
            }),
          ],
        ),
        body: SafeArea(
          child: Obx(() {
            switch (controller.phase.value) {
              case AiCvPhase.generating:
              case AiCvPhase.saving:
                return _StatusPane(
                  title: controller.phase.value == AiCvPhase.saving
                      ? 'Saving your CV…'
                      : 'Building your CV from your profile…',
                  subtitle: controller.phase.value == AiCvPhase.saving
                      ? (controller.hasJobContext
                          ? 'Attaching it to ${controller.jobTitle}'
                          : 'Saving it to your profile')
                      : 'Using only your Vithey profile data',
                );
              case AiCvPhase.error:
                return _ErrorPane(
                  message: controller.errorMessage.value,
                  onRetry: controller.retryGenerate,
                  onBack: controller.cancelToApply,
                );
              case AiCvPhase.preview:
                return _PreviewEditorPane(controller: controller);
            }
          }),
        ),
      ),
    );
  }
}

class _StatusPane extends StatelessWidget {
  const _StatusPane({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoadingWidget(),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: context.text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            VitheyIcon(LucideIcons.info,
                size: 40, color: context.appColors.muted),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w400, height: 1.4),
            ),
            const SizedBox(height: 20),
            CustomButton(label: 'Try again', onPressed: onRetry),
            const SizedBox(height: 10),
            CustomButton(
              label: 'Go back',
              variant: CustomButtonVariant.outline,
              onPressed: onBack,
            ),
          ],
        ),
      ),
    );
  }
}

/// Canva-style: live template preview; tap any block to edit.
class _PreviewEditorPane extends StatelessWidget {
  const _PreviewEditorPane({required this.controller});

  final AiCvController controller;

  Future<void> _editSection(
    BuildContext context,
    CvEditSection section,
  ) async {
    controller.activeSection.value = section;
    final field = TextEditingController(text: controller.sectionValue(section));
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ctx.appColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                section.title,
                style: ctx.text.titleLarge?.copyWith(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Changes update the template preview instantly.',
                style: ctx.text.bodySmall?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 14),
              VitheyField(
                controller: field,
                label: section.hint,
                maxLines: section.maxLines,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Done',
                onPressed: () {
                  controller.updateSection(section, field.text);
                  Navigator.of(ctx).pop(true);
                },
              ),
              const SizedBox(height: 8),
              CustomButton(
                label: 'Cancel',
                variant: CustomButtonVariant.ghost,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
            ],
          ),
        );
      },
    );
    field.dispose();
    controller.activeSection.value = null;
    if (saved == true) {
      // Already applied in Done; keep for clarity.
    }
  }

  @override
  Widget build(BuildContext context) {
    final template = controller.selectedTemplate;

    return Column(
      children: [
        Expanded(
          child: Obx(() {
            final draft = controller.draft.value;
            if (draft == null) return const SizedBox.shrink();
            final active = controller.activeSection.value;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                Text(
                  'Tap any text on the CV to edit it',
                  style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Template · ${template.name}',
                  style: context.text.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: 0.707,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(VitheyRadii.card),
                      border: Border.all(color: context.appColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: context.appColors.subtleShadow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(VitheyRadii.card),
                      child: CvTemplatePreview(
                        draft: draft,
                        template: template,
                        editable: true,
                        activeSection: active,
                        onEditSection: (section) =>
                            _editSection(context, section),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: context.appColors.cardSurface,
            border: Border(
              top: BorderSide(color: context.appColors.border),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomButton(
                label: controller.hasJobContext
                    ? 'Use for this job & continue'
                    : 'Save CV',
                onPressed: controller.isSaving.value
                    ? null
                    : controller.confirmUseForJob,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Save only',
                      variant: CustomButtonVariant.outline,
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.saveOnly,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(
                      () => CustomButton(
                        label: 'Download',
                        variant: CustomButtonVariant.outline,
                        icon: LucideIcons.download,
                        isLoading: controller.isDownloading.value,
                        onPressed: controller.isDownloading.value
                            ? null
                            : controller.downloadPdf,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
