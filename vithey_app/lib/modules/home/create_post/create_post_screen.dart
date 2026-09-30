import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/core/widgets/vithey_field.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_area.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/data/services/upload_service.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/modules/home/create_post/create_post_controller.dart';
import 'package:aub_connect_app/modules/home/create_post/widgets/create_post_media_zone.dart';
import 'package:intl/intl.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class CreatePostScreen extends GetView<CreatePostController> {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack(context);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: context.appColors.cardSurface,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: context.appColors.cardSurface,
              ),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: context.appColors.cardSurface,
          // Header lives in the body so status-bar + header share one flat color
          // (no separate Scaffold appBar tint / "live" strip on top).
          body: Column(
            children: [
              ColoredBox(
                color: context.appColors.cardSurface,
                child: SafeArea(
                  bottom: false,
                  child: _CreatePostHeader(
                    onBack: () => _handleBack(context),
                    onAudienceTap: () => _showAudienceSheet(context),
                    onPost: controller.publish,
                  ),
                ),
              ),
              Obx(() {
                final scheduledAt = controller.scheduledAt.value;
                if (scheduledAt == null) return const SizedBox.shrink();
                return _ScheduleBanner(
                  value: scheduledAt,
                  onTap: () => controller.pickSchedule(context),
                  onClear: controller.clearSchedule,
                );
              }),
              Expanded(child: _AdaptiveEditor(controller: controller)),
            ],
          ),
          bottomNavigationBar: _ComposerToolbar(
            onMedia: controller.showMediaSourceSheet,
            onSchedule: () => controller.pickSchedule(context),
            onCvLimit: () => _showCvLimitSheet(context),
            onCategory:
                controller.isEditing ? null : () => _showCategorySheet(context),
          ),
        ),
      ),
    );
  }

  Future<void> _handleBack(BuildContext context) async {
    final hasDraft = controller.hasUnsavedChanges;
    if (!hasDraft) {
      Get.back();
      return;
    }
    final discard = await showConfirmDialog(
      context: context,
      title: controller.isEditing ? 'Discard changes?' : 'Discard post?',
      message: controller.isEditing
          ? 'Your changes to this post will be lost.'
          : 'Your text, media, and schedule will be lost.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep editing',
      variant: ConfirmDialogVariant.destructive,
    );
    if (discard == true) Get.back();
  }

  void _showAudienceSheet(BuildContext context) {
    Get.bottomSheet<void>(
      _AudienceSheet(controller: controller),
      backgroundColor: context.appColors.cardSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
      ),
    );
  }

  void _showCategorySheet(BuildContext context) {
    Get.bottomSheet<void>(
      _CategorySheet(controller: controller),
      backgroundColor: context.appColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
      ),
    );
  }

  void _showCvLimitSheet(BuildContext context) {
    Get.bottomSheet<void>(
      _CvLimitSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: context.appColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
      ),
    );
  }
}

class _AdaptiveEditor extends StatelessWidget {
  const _AdaptiveEditor({required this.controller});

  final CreatePostController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mediaPath = controller.mediaPreviewPath;
      final isUploading = controller.isUploadingMedia.value;
      final error = controller.errorMessage.value;
      // Jobs (and any edit with media) use the media composer so the poster
      // is visible and replaceable — not the text-only expanded editor.
      final useMediaForm = mediaPath != null || controller.isJob;

      if (!useMediaForm) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('expanded-composer-editor'),
                controller: controller.contentController,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: _editorStyle(context),
                decoration: _editorDecoration(context),
              ),
            ),
            if (error.isNotEmpty) _ComposerError(message: error),
          ],
        );
      }

      return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (controller.isJob) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: VitheyField(
                  controller: controller.jobTitleController,
                  label: 'Job title',
                  hint: 'e.g. Web Developer',
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => controller.contentRevision.value++,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: VitheyField(
                  controller: controller.jobCompanyController,
                  label: 'Company',
                  hint: 'Company or organization',
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => controller.contentRevision.value++,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: VitheyField(
                  controller: controller.jobRequirementController,
                  label: 'Employment type',
                  hint: 'Full-time, Part-time, Internship…',
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => controller.contentRevision.value++,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: VitheyTextArea(
                  key: const ValueKey('job-location-editor'),
                  controller: controller.contentController,
                  label: 'Location',
                  hint: 'City, street, office…',
                  minLines: 3,
                  maxLines: 6,
                ),
              ),
            ] else ...[
              VitheyTextArea(
                key: const ValueKey('media-composer-editor'),
                controller: controller.contentController,
                hint: 'What\'s on your mind?',
                minLines: 4,
                maxLines: 12,
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(VitheyRadii.media),
                child: CreatePostMediaZone(
                  mediaPath: mediaPath,
                  isVideo: controller.isVideo,
                  isUploading: isUploading,
                  onPick: controller.showMediaSourceSheet,
                  onClear: controller.clearMedia,
                ),
              ),
            ),
            if (error.isNotEmpty) _ComposerError(message: error),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }

  TextStyle? _editorStyle(BuildContext context) {
    return context.text.bodyMedium?.copyWith(
      color: context.appColors.heading,
      fontSize: 15,
      height: 1.4,
    );
  }

  InputDecoration _editorDecoration(BuildContext context) {
    return InputDecoration(
      hintText: 'What\'s on your mind?',
      hintStyle: context.text.bodyMedium
          ?.copyWith(color: context.appColors.muted, fontSize: 15),
      filled: true,
      fillColor: context.appColors.cardSurface,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
    );
  }
}

class _ComposerError extends StatelessWidget {
  const _ComposerError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.scheme.errorContainer.withValues(alpha: 0.55),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        message,
        style: context.text.bodyMedium
            ?.copyWith(color: context.scheme.onErrorContainer, fontSize: 12),
      ),
    );
  }
}

class _CreatePostHeader extends GetView<CreatePostController> {
  const _CreatePostHeader({
    required this.onBack,
    required this.onAudienceTap,
    required this.onPost,
  });

  final VoidCallback onBack;
  final VoidCallback onAudienceTap;
  final VoidCallback onPost;

  static const double _headerHeight = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final currentUser = Get.find<CurrentUserService>();

    return ColoredBox(
      color: colors.cardSurface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: _headerHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Obx(() {
                controller.contentRevision.value;
                final postLabel = controller.isEditing
                    ? 'Save'
                    : controller.scheduledAt.value != null
                        ? 'Schedule'
                        : 'Post';

                return Row(
                  children: [
                    VitheyIconButton(
                      icon: LucideIcons.arrowLeft,
                      variant: VitheyIconButtonVariant.neutral,
                      tooltip: 'Back to home',
                      onTap: onBack,
                    ),
                    UserAvatar(
                      name: currentUser.displayName,
                      imageUrl: currentUser.user.value?.avatarUrl,
                      radius: 15,
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: onAudienceTap,
                      borderRadius: BorderRadius.circular(VitheyRadii.pill),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.audienceLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.labelLarge
                                  ?.copyWith(color: colors.muted),
                            ),
                            VitheyIcon(
                              LucideIcons.chevronDown,
                              color: colors.muted,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    _PublishAction(
                      label: postLabel,
                      enabled: controller.canPublish,
                      loading: controller.isPosting.value,
                      onPressed: onPost,
                    ),
                  ],
                );
              }),
            ),
          ),
          Divider(height: 1, thickness: 1, color: colors.border),
        ],
      ),
    );
  }
}

class _PublishAction extends StatelessWidget {
  const _PublishAction({
    required this.label,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? context.scheme.primary : context.appColors.inputFill,
      borderRadius: BorderRadius.circular(VitheyRadii.pill),
      child: InkWell(
        onTap: enabled && !loading ? onPressed : null,
        borderRadius: BorderRadius.circular(VitheyRadii.pill),
        child: SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.scheme.onPrimary,
                      ),
                    )
                  : Text(
                      label,
                      style: context.text.bodySmall?.copyWith(
                        color: enabled
                            ? context.scheme.onPrimary
                            : context.appColors.muted,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleBanner extends StatelessWidget {
  const _ScheduleBanner({
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final DateTime value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat("EEE, MMM d 'at' h:mma").format(value);
    return Material(
      color: context.scheme.primary.withValues(alpha: 0.09),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 9, 6, 9),
          child: Row(
            children: [
              VitheyIcon(
                LucideIcons.globe,
                color: context.scheme.primary,
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Posting on $formatted. ',
                    children: const [
                      TextSpan(
                        text: 'Edit',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  style: context.text.bodyMedium
                      ?.copyWith(color: context.appColors.heading, fontSize: 11),
                ),
              ),
              VitheyIconButton(
                icon: LucideIcons.x,
                iconSize: 20,
                variant: VitheyIconButtonVariant.neutral,
                tooltip: 'Clear schedule',
                onTap: onClear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposerToolbar extends GetView<CreatePostController> {
  const _ComposerToolbar({
    required this.onMedia,
    required this.onSchedule,
    required this.onCvLimit,
    required this.onCategory,
  });

  final VoidCallback onMedia;
  final VoidCallback onSchedule;
  final VoidCallback onCvLimit;
  final VoidCallback? onCategory;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.cardSurface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.cardSurface,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Obx(
            () => SizedBox(
              height: 48,
              child: Row(
                children: [
                  _ToolbarAction(
                    icon: LucideIcons.image,
                    label: 'Media',
                    onTap: onMedia,
                  ),
                  _ToolbarAction(
                    icon: LucideIcons.clock,
                    label: 'Schedule',
                    onTap: onSchedule,
                  ),
                  if (controller.isJob)
                    _ToolbarAction(
                      icon: LucideIcons.badge,
                      label: '${controller.cvLimit.value}',
                      onTap: onCvLimit,
                    ),
                  const Spacer(),
                  InkWell(
                    onTap: onCategory,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.categoryLabel,
                            style: context.text.labelSmall?.copyWith(
                              color: context.scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          VitheyIcon(
                            onCategory == null
                                ? LucideIcons.lock
                                : LucideIcons.chevronDown,
                            color: context.scheme.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 62, minHeight: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VitheyIcon(icon, size: 19, color: context.appColors.muted),
            const SizedBox(height: 2),
            Text(
              label,
              style: context.text.bodyMedium
                  ?.copyWith(color: context.appColors.muted, fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudienceSheet extends StatelessWidget {
  const _AudienceSheet({required this.controller});

  final CreatePostController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 15),
            Text(
              'Who can see your post?',
              style: context.text.titleLarge?.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 10),
            Obx(
              () => Column(
                children: [
                  _ChoiceRow(
                    icon: LucideIcons.globe,
                    title: 'Public',
                    subtitle: 'Visible for everyone',
                    selected: controller.audience.value == PostAudience.public,
                    onTap: () {
                      controller.selectAudience(PostAudience.public);
                      Get.back();
                    },
                  ),
                  _ChoiceRow(
                    icon: LucideIcons.users,
                    title: 'Friends',
                    subtitle: controller.isJob
                        ? 'Job posts must be Public'
                        : 'Only friends can see this post',
                    selected: controller.audience.value == PostAudience.friends,
                    enabled: !controller.isJob,
                    onTap: () {
                      controller.selectAudience(PostAudience.friends);
                      Get.back();
                    },
                  ),
                  _ChoiceRow(
                    icon: LucideIcons.lock,
                    title: 'Only Me',
                    subtitle: controller.isJob
                        ? 'Job posts must be Public'
                        : 'Only visible in my account',
                    selected: controller.audience.value == PostAudience.private,
                    enabled: !controller.isJob,
                    onTap: () {
                      controller.selectAudience(PostAudience.private);
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySheet extends StatelessWidget {
  const _CategorySheet({required this.controller});

  final CreatePostController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 15),
            Text(
              'What is your post type?',
              style: context.text.titleLarge?.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 10),
            Obx(
              () => Column(
                children: [
                  _ChoiceRow(
                    icon: LucideIcons.image,
                    title: 'General',
                    subtitle: 'Community or social post',
                    selected: controller.selectedType.value == PostType.poster,
                    onTap: () {
                      controller.selectType(PostType.poster);
                      Get.back();
                    },
                  ),
                  _ChoiceRow(
                    icon: LucideIcons.briefcase,
                    title: 'Job',
                    subtitle: 'Job announcement with Apply action',
                    selected: controller.selectedType.value == PostType.job,
                    onTap: () {
                      controller.selectType(PostType.job);
                      Get.back();
                    },
                  ),
                  _ChoiceRow(
                    icon: LucideIcons.video,
                    title: 'Video',
                    subtitle: 'Share a video',
                    selected: controller.selectedType.value == PostType.video,
                    onTap: () {
                      controller.selectType(PostType.video);
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CvLimitSheet extends StatefulWidget {
  const _CvLimitSheet({required this.controller});

  final CreatePostController controller;

  @override
  State<_CvLimitSheet> createState() => _CvLimitSheetState();
}

class _CvLimitSheetState extends State<_CvLimitSheet> {
  late final TextEditingController _amountController;
  int? _selectedPreset;
  String? _error;

  @override
  void initState() {
    super.initState();
    final current = widget.controller.cvLimit.value;
    final isPreset = CreatePostController.cvLimitPresets.contains(current);
    _selectedPreset = isPreset ? current : null;
    _amountController = TextEditingController(
      text: isPreset ? '' : '$current',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectPreset(int limit) {
    setState(() {
      _selectedPreset = limit;
      _amountController.clear();
      _error = null;
    });
  }

  void _onCustomChanged(String value) {
    setState(() {
      if (value.trim().isNotEmpty) {
        _selectedPreset = null;
      }
      _error = null;
    });
  }

  void _confirm() {
    final error = widget.controller.applyCvLimitInput(
      preset: _selectedPreset,
      customAmount: _selectedPreset == null ? _amountController.text : null,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 18 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 12),
              Text(
                'Limit CV',
                style: context.text.titleLarge?.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 4),
              for (final limit in CreatePostController.cvLimitPresets)
                _CvLimitOptionRow(
                  label: '$limit',
                  selected: _selectedPreset == limit,
                  onTap: () => _selectPreset(limit),
                ),
              const SizedBox(height: 8),
              VitheyField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                hint: 'Insert amount',
                errorText: _error,
                onChanged: _onCustomChanged,
                onSubmitted: (_) => _confirm(),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
              const SizedBox(height: 12),
              CustomButton(label: 'Next', onPressed: _confirm),
            ],
          ),
        ),
      ),
    );
  }
}

class _CvLimitOptionRow extends StatelessWidget {
  const _CvLimitOptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(VitheyRadii.field),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 11),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.text.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            VitheyIcon(
              selected
                  ? LucideIcons.circleDot
                  : LucideIcons.circle,
              color:
                  selected ? context.scheme.primary : context.appColors.muted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: ListTile(
        enabled: enabled,
        onTap: enabled ? onTap : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 2),
        leading: VitheyIcon(icon, color: context.appColors.muted),
        title: Text(title, style: context.text.labelLarge),
        subtitle: Text(
          subtitle,
          style: context.text.bodySmall?.copyWith(fontSize: 11.5),
        ),
        trailing: VitheyIcon(
          selected
              ? LucideIcons.circleDot
              : LucideIcons.circle,
          color: selected ? context.scheme.primary : context.appColors.muted,
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: context.appColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class CreatePostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatePostController>(
      () => CreatePostController(
          Get.find<PostRepository>(), Get.find<UploadService>()),
    );
  }
}
