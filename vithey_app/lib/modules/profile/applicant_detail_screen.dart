import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/data/models/applicant_detail_model.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/modules/profile/profile_navigation.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/modules/profile/widgets/application_feedback_success.dart';
import 'package:aub_connect_app/modules/profile/widgets/applicant_ai_match_panel.dart';
import 'package:aub_connect_app/modules/profile/widgets/experience_timeline.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ApplicantDetailController extends GetxController {
  ApplicantDetailController(this._repository);

  final ProfileRepository _repository;

  final detail = Rxn<ApplicantDetailModel>();
  final isLoading = true.obs;
  final hasError = false.obs;
  final isActionLoading = false.obs;

  String? _applicationId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as ApplicantDetailArgs?;
    _applicationId = args?.applicationId;
    loadDetail();
  }

  Future<void> loadDetail() async {
    if (_applicationId == null) {
      hasError.value = true;
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    hasError.value = false;
    try {
      detail.value = await _repository.getApplicantDetail(_applicationId!);
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void openApplicantProfile() {
    final current = detail.value;
    if (current == null) return;
    openUserProfile(current.applicantUserId);
  }

  Future<void> accept() async {
    final current = detail.value;
    if (current == null || isActionLoading.value) return;

    final confirmed = await showConfirmDialog(
      context: Get.context!,
      title: 'Accept applicant?',
      message: 'This applicant will be notified of your decision.',
      confirmLabel: 'Accept',
    );
    if (confirmed != true) return;

    isActionLoading.value = true;
    try {
      await _repository.updateApplicationStatus(current.applicationId, ApplicationStatus.accepted);
      detail.value = _copyWithStatus(current, ApplicationStatus.accepted);
      ApplicationFeedbackSuccess.show();
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> reject() async {
    final current = detail.value;
    if (current == null || isActionLoading.value) return;

    final confirmed = await showConfirmDialog(
      context: Get.context!,
      title: 'Reject applicant?',
      message: 'This applicant will be notified of your decision.',
      confirmLabel: 'Reject',
      variant: ConfirmDialogVariant.destructive,
    );
    if (confirmed != true) return;

    isActionLoading.value = true;
    try {
      await _repository.updateApplicationStatus(current.applicationId, ApplicationStatus.rejected);
      detail.value = _copyWithStatus(current, ApplicationStatus.rejected);
      ApplicationFeedbackSuccess.show();
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> viewCv() async {
    final current = detail.value;
    if (current == null || !current.hasCv) return;

    Get.toNamed(
      AppRoutes.applicantCvPreview,
      arguments: ApplicantCvArgs(
        applicationId: current.applicationId,
        applicantName: current.applicantName,
        cvFileName: current.cvFileName,
      ),
    );
  }

  ApplicantDetailModel _copyWithStatus(ApplicantDetailModel current, ApplicationStatus status) {
    return ApplicantDetailModel(
      applicationId: current.applicationId,
      jobPostId: current.jobPostId,
      jobTitle: current.jobTitle,
      applicantUserId: current.applicantUserId,
      applicantName: current.applicantName,
      headline: current.headline,
      location: current.location,
      email: current.email,
      avatarUrl: current.avatarUrl,
      status: status,
      cvFileName: current.cvFileName,
      experience: current.experience,
      education: current.education,
    );
  }
}

class ApplicantDetailScreen extends GetView<ApplicantDetailController> {
  const ApplicantDetailScreen({super.key});

  static const _coverTeal = Color(0xFF7DDAD6);
  static const _decorTeal = Color(0xFF2A9E99);
  static const _avatarRadius = 40.0;
  static const _pagePad = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final name = controller.detail.value?.applicantName;
          return Text(name ?? 'Applicant', style: context.text.headlineSmall);
        }),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();
        if (controller.hasError.value || controller.detail.value == null) {
          return AppErrorWidget(
            message: 'Could not load applicant details',
            onRetry: controller.loadDetail,
          );
        }

        final applicant = controller.detail.value!;

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _ApplicantCoverHeader(
                    name: applicant.applicantName,
                    avatarUrl: applicant.avatarUrl,
                    coverTeal: _coverTeal,
                    decorTeal: _decorTeal,
                    avatarRadius: _avatarRadius,
                    pagePad: _pagePad,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(_pagePad, 0, _pagePad, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group 1: name + apply position (tight)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                applicant.applicantName,
                                style: context.text.headlineSmall,
                              ),
                            ),
                            const SizedBox(width: 12),
                            CustomButton(
                              label: 'View Profile',
                              onPressed: controller.openApplicantProfile,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Apply position: ${applicant.jobTitle}',
                          style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        // Gap between profile group and contact group
                        const SizedBox(height: 20),
                        // Group 2: location + email (tight)
                        if (applicant.location != null)
                          _ContactRow(icon: LucideIcons.mapPin, text: applicant.location!),
                        if (applicant.location != null && applicant.email != null)
                          const SizedBox(height: 2),
                        if (applicant.email != null)
                          _ContactRow(icon: LucideIcons.mail, text: applicant.email!),
                        const SizedBox(height: 28),
                        ExperienceTimeline(
                          title: 'Experience',
                          entries: applicant.experience,
                        ),
                        const SizedBox(height: 28),
                        ExperienceTimeline(
                          title: 'Education',
                          entries: applicant.education,
                          useEducationIcon: true,
                        ),
                        // Block 5 — AI match certify panel (AI-JOB-08/13).
                        if (Get.find<FeatureFlags>().useAiJobMatch) ...[
                          const SizedBox(height: 28),
                          ApplicantAiMatchPanel(
                            jobPostId: applicant.jobPostId,
                            applicantUserId: applicant.applicantUserId,
                            applicantName: applicant.applicantName,
                          ),
                        ],
                        const SizedBox(height: 28),
                        _CurriculumVitaeCard(
                          fileName: applicant.cvFileName,
                          hasCv: applicant.hasCv,
                          onTap: controller.viewCv,
                          onDownload: controller.viewCv,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _OwnerActionBar(
              status: applicant.status,
              isLoading: controller.isActionLoading.value,
              onAccept: controller.accept,
              onReject: controller.reject,
            ),
          ],
        );
      }),
    );
  }
}

class _ApplicantCoverHeader extends StatelessWidget {
  const _ApplicantCoverHeader({
    required this.name,
    required this.avatarUrl,
    required this.coverTeal,
    required this.decorTeal,
    required this.avatarRadius,
    required this.pagePad,
  });

  final String name;
  final String? avatarUrl;
  final Color coverTeal;
  final Color decorTeal;
  final double avatarRadius;
  final double pagePad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pagePad, pagePad, pagePad, avatarRadius + 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: coverTeal,
              borderRadius: BorderRadius.circular(VitheyRadii.card),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: _decorIcons(context, decorTeal)),
          ),
          Positioned(
            left: 12,
            bottom: -avatarRadius + 4,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: UserAvatar(
                name: name,
                imageUrl: avatarUrl,
                radius: avatarRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _decorIcons(BuildContext context, Color iconColor) {
    return [
      Positioned(
        left: 20,
        top: 32,
        child: Text(
          '</>',
          style: context.text.titleMedium?.copyWith(fontSize: 28, color: iconColor),
        ),
      ),
      Positioned(
        right: 28,
        top: 24,
        child: VitheyIcon(LucideIcons.dices, color: iconColor, size: 28),
      ),
      Positioned(
        right: 72,
        top: 54,
        child: VitheyIcon(LucideIcons.box, color: iconColor, size: 26),
      ),
      Positioned(
        left: 78,
        top: 18,
        child: VitheyIcon(LucideIcons.messageCircle, color: iconColor, size: 24),
      ),
      Positioned(
        right: 16,
        top: 78,
        child: VitheyIcon(LucideIcons.star, color: iconColor, size: 24),
      ),
      Positioned(
        left: 118,
        top: 50,
        child: VitheyIcon(LucideIcons.sparkles, color: iconColor, size: 22),
      ),
    ];
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        VitheyIcon(icon, size: 18, color: context.appColors.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: context.text.bodySmall),
        ),
      ],
    );
  }
}

class _CurriculumVitaeCard extends StatelessWidget {
  const _CurriculumVitaeCard({
    required this.fileName,
    required this.hasCv,
    required this.onTap,
    required this.onDownload,
  });

  final String? fileName;
  final bool hasCv;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  static const _previewHeight = 220.0;

  @override
  Widget build(BuildContext context) {
    final border = context.appColors.border;
    // Show only the original uploaded file name from the application.
    final displayName = fileName?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Curriculum Vitae', style: context.text.titleLarge),
        const SizedBox(height: 12),
        Material(
          color: context.appColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VitheyRadii.card),
            side: BorderSide(color: border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SizedBox(
                height: _previewHeight,
                width: double.infinity,
                child: hasCv
                    ? InkWell(
                        onTap: onTap,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          // Thumbnail mock only — label uses application cvFileName.
                          child: Image.asset(
                            AppAssets.applicantCvPreview,
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => _NoCvPlaceholder(onTap: null),
                          ),
                        ),
                      )
                    : const _NoCvPlaceholder(onTap: null),
              ),
              if (hasCv)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color: context.appColors.muted.withValues(alpha: 0.08),
                  child: Row(
                    children: [
                      VitheyIcon(_fileIcon(displayName), color: AppColors.error, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          displayName == null || displayName.isEmpty ? 'CV' : displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      VitheyIconButton(
                        icon: LucideIcons.download,
                        variant: VitheyIconButtonVariant.neutral,
                        tooltip: 'Download',
                        onTap: onDownload,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _fileIcon(String? name) {
    final lower = (name ?? '').toLowerCase();
    if (lower.endsWith('.pdf')) return LucideIcons.fileText;
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) return LucideIcons.fileText;
    if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.webp')) {
      return LucideIcons.image;
    }
    return LucideIcons.fileText;
  }
}

class _NoCvPlaceholder extends StatelessWidget {
  const _NoCvPlaceholder({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          VitheyIcon(LucideIcons.fileText, size: 40, color: context.appColors.muted),
          const SizedBox(height: 8),
          Text(
            'No CV Available',
            style: context.text.labelLarge?.copyWith(color: context.appColors.muted),
          ),
        ],
      ),
    );
    if (onTap == null) return child;
    return InkWell(onTap: onTap, child: child);
  }
}

class _OwnerActionBar extends StatelessWidget {
  const _OwnerActionBar({
    required this.status,
    required this.isLoading,
    required this.onAccept,
    required this.onReject,
  });

  final ApplicationStatus status;
  final bool isLoading;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final acceptEnabled = !isLoading && status != ApplicationStatus.accepted;
    final rejectEnabled = !isLoading && status != ApplicationStatus.rejected;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: context.appColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                label: 'Accept',
                onPressed: acceptEnabled ? onAccept : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                label: 'Reject',
                variant: CustomButtonVariant.outline,
                onPressed: rejectEnabled ? onReject : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApplicantDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApplicantDetailController(Get.find<ProfileRepository>()));
  }
}
