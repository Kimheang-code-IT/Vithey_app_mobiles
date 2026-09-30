import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class FaqCategory {
  const FaqCategory({
    required this.id,
    required this.title,
    required this.topics,
  });

  final String id;
  final String title;
  final List<String> topics;
}

class HelpCenterController extends GetxController {
  final query = ''.obs;
  final searchController = TextEditingController();

  static const categories = <FaqCategory>[
    FaqCategory(
      id: 'account',
      title: 'Account & Login',
      topics: ['Reset password', 'Update email', 'Logout'],
    ),
    FaqCategory(
      id: 'verification',
      title: 'Student Verification',
      topics: ['Accepted documents', 'Pending status'],
    ),
    FaqCategory(
      id: 'finance',
      title: 'Finance',
      topics: ['Payment alerts', 'Invoice detail'],
    ),
    FaqCategory(
      id: 'jobs',
      title: 'Jobs & CV',
      topics: ['Upload CV', 'Apply to job', 'Applicant review'],
    ),
    FaqCategory(
      id: 'chat',
      title: 'Chat & Safety',
      topics: ['Message requests', 'Block/report'],
    ),
    FaqCategory(
      id: 'ai',
      title: 'AI Assistant',
      topics: ['Topics', 'Privacy', 'Unavailable provider'],
    ),
  ];

  List<FaqCategory> get filteredCategories {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return categories;
    return categories
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.topics.any((t) => t.toLowerCase().contains(q)),
        )
        .toList();
  }

  void openFaqCategory(String categoryId) {
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    if (category == null) return;

    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    final ctx = Get.context!;
    final bg = ctx.appColors.inputFill;

    Get.bottomSheet(
      _FaqCategorySheet(category: category),
      backgroundColor: bg,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Future<void> contactSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@vithey.app',
      query: 'subject=Vithey%20App%20Support',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Vithey', 'Email support: support@vithey.app');
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class _FaqCategorySheet extends StatelessWidget {
  const _FaqCategorySheet({required this.category});

  final FaqCategory category;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cardColor = colors.cardSurface;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              category.title,
              textAlign: TextAlign.start,
              style: context.text.headlineSmall?.copyWith(
                fontSize: 20,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse common questions in this topic.',
              textAlign: TextAlign.start,
              style: context.text.bodyMedium?.copyWith(
                height: 1.4,
                color: colors.muted,
              ),
            ),
            const SizedBox(height: 20),
            DecoratedBox(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < category.topics.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 16,
                          color: colors.border.withValues(alpha: 0.6),
                        ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final navigator = Navigator.of(context);
                            if (navigator.canPop()) navigator.pop();
                            Get.snackbar(
                              category.title,
                              category.topics[i],
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.fileText,
                                  size: 22,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    category.topics[i],
                                    style: context.text.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  LucideIcons.chevronRight,
                                  size: 22,
                                  color: colors.muted.withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
