import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/vithey_action_sheet.dart';
import 'package:aub_connect_app/core/widgets/vithey_search_pill.dart';
import 'package:aub_connect_app/data/fixtures/cv_template_fixtures.dart';
import 'package:aub_connect_app/data/models/cv_template.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/templates/cv_template_gallery_controller.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/templates/cv_template_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CvTemplateGalleryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(CvTemplateGalleryController.new);
  }
}

class CvTemplateGalleryScreen extends GetView<CvTemplateGalleryController> {
  const CvTemplateGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.cancel();
      },
      child: Scaffold(
        backgroundColor: colors.bodyBackground,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: controller.cancel,
                      icon: VitheyIcon(
                        LucideIcons.arrowLeft,
                        color: colors.heading,
                      ),
                    ),
                    Text(
                      'Templates',
                      style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 4),
                    VitheyIcon(
                      LucideIcons.chevronDown,
                      size: 18,
                      color: colors.muted,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: VitheySearchPill(
                  controller: controller.searchController,
                  hintText: 'Search templates.',
                  onClear: () {
                    controller.searchController.clear();
                    controller.query.value = '';
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: _FilterPill(
                          label: 'Category',
                          value: controller.category.value,
                          onTap: () => _pickFilter(
                            context,
                            title: 'Category',
                            options: CvTemplateFixtures.categories,
                            current: controller.category.value,
                            onSelected: controller.setCategory,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterPill(
                          label: 'Style',
                          value: controller.style.value,
                          onTap: () => _pickFilter(
                            context,
                            title: 'Style',
                            options: CvTemplateFixtures.styles,
                            current: controller.style.value,
                            onSelected: controller.setStyle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterPill(
                          label: 'Language',
                          value: controller.language.value,
                          onTap: () => _pickFilter(
                            context,
                            title: 'Language',
                            options: CvTemplateFixtures.languages,
                            current: controller.language.value,
                            onSelected: controller.setLanguage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  final items = controller.filtered;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _BlankTile(onTap: controller.openBlank);
                      }
                      final template = items[index - 1];
                      return _TemplateTile(
                        template: template,
                        onTap: () => controller.openTemplate(template),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFilter(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String current,
    required ValueChanged<String> onSelected,
  }) async {
    final picked = await showVitheyActionSheet<String>(
      context: context,
      title: title,
      actions: [
        for (final option in options)
          VitheyActionSheetAction(
            value: option,
            label: option == 'All' ? 'All $title' : option,
            icon: option == current ? LucideIcons.check : LucideIcons.circle,
          ),
      ],
    );
    if (picked != null) onSelected(picked);
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final showing = value == 'All' ? label : value;
    return Material(
      color: colors.cardSurface,
      borderRadius: BorderRadius.circular(VitheyRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VitheyRadii.pill),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VitheyRadii.pill),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  showing,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.heading,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              VitheyIcon(
                LucideIcons.chevronDown,
                size: 14,
                color: colors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlankTile extends StatelessWidget {
  const _BlankTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.inputFill,
      borderRadius: BorderRadius.circular(VitheyRadii.card),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VitheyRadii.card),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.subtleShadow,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VitheyIcon(
                LucideIcons.plus,
                size: 36,
                color: colors.heading,
              ),
              const SizedBox(height: 8),
              Text(
                'Create blank',
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.heading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.template,
    required this.onTap,
  });

  final CvTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.cardSurface,
      borderRadius: BorderRadius.circular(VitheyRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VitheyRadii.card),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.subtleShadow,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(VitheyRadii.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: CvTemplatePreview(
                    draft: CvTemplateFixtures.sampleDraft,
                    template: template,
                    compact: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Text(
                    template.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.heading,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
