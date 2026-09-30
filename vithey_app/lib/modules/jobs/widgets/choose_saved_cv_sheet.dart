import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/data/fixtures/cv_template_fixtures.dart';
import 'package:aub_connect_app/data/models/ai_cv_draft.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/templates/cv_template_preview.dart';
import 'package:flutter/material.dart';

/// Bottom sheet / section to pick among saved CVs (with template thumbnails).
class ChooseSavedCvSheet extends StatelessWidget {
  const ChooseSavedCvSheet({
    super.key,
    required this.cvs,
    required this.draftFor,
    required this.selectedFileId,
    required this.onSelected,
  });

  final List<CvMetadataModel> cvs;
  final AiCvDraft? Function(String fileId) draftFor;
  final String? selectedFileId;
  final ValueChanged<CvMetadataModel> onSelected;

  static Future<CvMetadataModel?> show(
    BuildContext context, {
    required List<CvMetadataModel> cvs,
    required AiCvDraft? Function(String fileId) draftFor,
    String? selectedFileId,
  }) {
    return showModalBottomSheet<CvMetadataModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return ChooseSavedCvSheet(
              cvs: cvs,
              draftFor: draftFor,
              selectedFileId: selectedFileId,
              onSelected: (cv) => Navigator.of(context).pop(cv),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a CV',
              style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Pick a saved template for this application.',
              style: context.text.bodySmall,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.68,
                ),
                itemCount: cvs.length,
                itemBuilder: (context, index) {
                  final cv = cvs[index];
                  final selected = cv.fileId == selectedFileId;
                  final template =
                      CvTemplateFixtures.byId(cv.templateId) ??
                          CvTemplateFixtures.all.first;
                  final draft = draftFor(cv.fileId) ??
                      CvTemplateFixtures.sampleDraft.copyWith(
                        fullName: cv.fileName.replaceAll('.pdf', ''),
                      );
                  return Material(
                    color: colors.cardSurface,
                    borderRadius: BorderRadius.circular(VitheyRadii.card),
                    child: InkWell(
                      onTap: () => onSelected(cv),
                      borderRadius: BorderRadius.circular(VitheyRadii.card),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(VitheyRadii.card),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : colors.border,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(VitheyRadii.card - 1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: CvTemplatePreview(
                                  draft: draft,
                                  template: template,
                                  compact: true,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cv.fileName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.labelSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colors.heading,
                                      ),
                                    ),
                                    Text(
                                      [
                                        if (cv.isDefault) 'Default',
                                        if (cv.isAiGenerated) 'AI',
                                        template.name,
                                      ].join(' · '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.text.bodySmall?.copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            CustomButton(
              label: 'Cancel',
              variant: CustomButtonVariant.ghost,
              icon: LucideIcons.x,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
