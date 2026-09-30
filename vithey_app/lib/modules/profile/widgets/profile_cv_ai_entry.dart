import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_action_sheet.dart';
import 'package:aub_connect_app/data/fixtures/cv_template_fixtures.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/cv_repository.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/ai_cv_args.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/templates/cv_template_preview.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

/// Profile → About → CV library: list saved templates, set default, download.
class ProfileCvAiEntry extends StatefulWidget {
  const ProfileCvAiEntry({super.key});

  @override
  State<ProfileCvAiEntry> createState() => _ProfileCvAiEntryState();
}

class _ProfileCvAiEntryState extends State<ProfileCvAiEntry> {
  List<CvMetadataModel> _cvs = const [];
  bool _loading = true;

  CvRepository get _repo => Get.find<CvRepository>();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final list = await _repo.listSavedCvs();
    if (!mounted) return;
    setState(() {
      _cvs = list;
      _loading = false;
    });
  }

  Future<void> _openGallery() async {
    await Get.toNamed(
      AppRoutes.applyCvTemplates,
      arguments: const AiCvArgs(returnToApply: false),
    );
    await _reload();
  }

  Future<void> _setDefault(CvMetadataModel cv) async {
    await _repo.setDefaultCv(cv.fileId);
    await _reload();
    Get.snackbar('Vithey', '${cv.fileName} is now your default CV.');
  }

  Future<void> _download(CvMetadataModel cv) async {
    try {
      await _repo.downloadSavedCv(cv);
    } catch (_) {
      Get.snackbar('Vithey', 'Could not download this CV yet.');
    }
  }

  Future<void> _delete(CvMetadataModel cv) async {
    await _repo.deleteSavedCv(cv.fileId);
    await _reload();
  }

  Future<void> _showActions(CvMetadataModel cv) async {
    await showVitheyActionSheet<void>(
      context: context,
      title: cv.fileName,
      actions: [
        VitheyActionSheetItem(
          label: cv.isDefault ? 'Default CV' : 'Set as default',
          icon: LucideIcons.star,
          onTap: cv.isDefault ? null : () => _setDefault(cv),
        ),
        VitheyActionSheetItem(
          label: 'Download PDF',
          icon: LucideIcons.download,
          onTap: () => _download(cv),
        ),
        VitheyActionSheetItem(
          label: 'Delete',
          icon: LucideIcons.trash2,
          isDestructive: true,
          onTap: () => _delete(cv),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        border: Border.all(color: colors.border),
        color: colors.cardSurface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VitheyIcon(LucideIcons.fileText,
                  size: 20, color: colors.heading),
              const SizedBox(width: 8),
              Text(
                'CV templates',
                style: context.text.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _loading
                ? 'Loading your CV library…'
                : _cvs.isEmpty
                    ? 'No CV yet — create one with AI templates.'
                    : '${_cvs.length} saved · tap a card for options',
            style: context.text.bodySmall,
          ),
          if (!_loading && _cvs.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _cvs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final cv = _cvs[index];
                  final template = CvTemplateFixtures.byId(cv.templateId) ??
                      CvTemplateFixtures.blank;
                  final draft = _repo.draftForFile(cv.fileId) ??
                      CvTemplateFixtures.sampleDraft.copyWith(
                        fullName: cv.fileName.replaceAll('_', ' ').replaceAll('.pdf', ''),
                      );
                  return SizedBox(
                    width: 118,
                    child: Material(
                      color: colors.inputFill,
                      borderRadius: BorderRadius.circular(VitheyRadii.card),
                      child: InkWell(
                        onTap: () => _showActions(cv),
                        borderRadius: BorderRadius.circular(VitheyRadii.card),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(VitheyRadii.card),
                            border: Border.all(
                              color: cv.isDefault
                                  ? AppColors.primary
                                  : colors.border,
                              width: cv.isDefault ? 2 : 1,
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
                                    template: template.isBlank
                                        ? CvTemplateFixtures.all.first
                                        : template,
                                    compact: true,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(6, 4, 6, 6),
                                  child: Text(
                                    cv.isDefault
                                        ? 'Default'
                                        : (template.name),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.text.labelSmall?.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: colors.heading,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          CustomButton(
            label: 'Create with AI templates',
            icon: LucideIcons.sparkles,
            variant: CustomButtonVariant.outline,
            onPressed: _openGallery,
          ),
        ],
      ),
    );
  }
}
