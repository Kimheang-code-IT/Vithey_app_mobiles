import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/data/services/upload_service.dart';
import 'package:aub_connect_app/modules/home/create_post/models/create_post_args.dart';
import 'package:aub_connect_app/modules/home/create_post/widgets/create_post_schedule_sheet.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
enum PostAudience { public, friends, private }

class CreatePostController extends GetxController {
  CreatePostController(this._postRepository, this._uploadService);

  final PostRepository _postRepository;
  final UploadService _uploadService;
  final _imagePicker = ImagePicker();

  final contentController = TextEditingController();
  final jobTitleController = TextEditingController(text: 'Job announcement!');
  final jobCompanyController = TextEditingController();
  final jobRequirementController = TextEditingController();
  final selectedType = Rxn<PostType>();
  final audience = PostAudience.public.obs;
  final contentRevision = 0.obs;
  final cvLimit = 30.obs;
  static const int minCvLimit = 1;
  static const int maxCvLimit = 999;
  static const List<int> cvLimitPresets = [10, 20, 30, 40, 50];
  final isPosting = false.obs;
  final isUploadingMedia = false.obs;
  final errorMessage = ''.obs;
  final mediaPath = RxnString();
  final mediaFileName = RxnString();
  final scheduledAt = Rxn<DateTime>();
  final existingMediaUrl = RxnString();
  final removeExistingMedia = false.obs;
  FeedPost? editingPost;

  bool get isJob => selectedType.value == PostType.job;
  bool get isVideo => selectedType.value == PostType.video;
  bool get isEditing => editingPost != null;
  String? get mediaPreviewPath => mediaPath.value ?? existingMediaUrl.value;
  bool get hasContent => contentController.text.trim().isNotEmpty;
  bool get hasUnsavedChanges {
    final original = editingPost;
    if (original == null) {
      return hasContent || mediaPath.value != null || scheduledAt.value != null;
    }
    return contentController.text.trim() != original.content ||
        mediaPath.value != null ||
        removeExistingMedia.value ||
        (isJob &&
            (jobTitleController.text.trim() != (original.jobMeta.title ?? '') ||
                jobCompanyController.text.trim() !=
                    (original.jobMeta.description ?? '') ||
                jobRequirementController.text.trim() !=
                    (original.jobMeta.requirement ?? '')));
  }

  bool get canPublish =>
      !isPosting.value &&
      selectedType.value != null &&
      hasContent &&
      (!isVideo || mediaPreviewPath != null) &&
      (!isEditing || hasUnsavedChanges) &&
      (scheduledAt.value == null || scheduledAt.value!.isAfter(DateTime.now()));

  String get categoryLabel => switch (selectedType.value) {
        PostType.job => 'Job',
        PostType.video => 'Video',
        _ => 'General',
      };

  String get audienceLabel => switch (audience.value) {
        PostAudience.public => 'Anyone',
        PostAudience.friends => 'Friends',
        PostAudience.private => 'Only Me',
      };

  @override
  void onInit() {
    super.onInit();
    final args = CreatePostArgs.from(Get.arguments);
    editingPost = args.editingPost;
    final original = editingPost;
    selectedType.value = original?.type ?? args.initialType ?? PostType.poster;
    if (original != null) {
      contentController.text = original.content;
      existingMediaUrl.value = original.mediaUrl ?? original.thumbnailUrl;
      if (original.type == PostType.job) {
        jobTitleController.text = original.jobMeta.title ?? 'Job announcement!';
        jobCompanyController.text = original.jobMeta.description ?? '';
        jobRequirementController.text = original.jobMeta.requirement ?? '';
      }
    }
    contentController.addListener(_onContentChanged);
  }

  void _onContentChanged() => contentRevision.value++;

  void selectType(PostType type) {
    if (isEditing) return;
    selectedType.value = type;
    if (type == PostType.job) audience.value = PostAudience.public;
    errorMessage.value = '';
  }

  void selectAudience(PostAudience value) {
    if (isJob && value != PostAudience.public) {
      errorMessage.value = 'Job posts must be Public';
      return;
    }
    audience.value = value;
    errorMessage.value = '';
  }

  void selectCvLimit(int value) => cvLimit.value = value;

  /// Returns an error message when [raw] is invalid; otherwise applies and
  /// returns null.
  String? applyCvLimitInput({int? preset, String? customAmount}) {
    if (preset != null) {
      if (!cvLimitPresets.contains(preset)) {
        return 'Choose a valid CV limit';
      }
      cvLimit.value = preset;
      return null;
    }

    final trimmed = customAmount?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Choose a limit or insert an amount';
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < minCvLimit || parsed > maxCvLimit) {
      return 'Enter a whole number from $minCvLimit to $maxCvLimit';
    }
    cvLimit.value = parsed;
    return null;
  }

  Future<void> showMediaSourceSheet() async {
    final type = selectedType.value;
    if (type == null) {
      errorMessage.value = 'Select a post type first';
      return;
    }

    final source = await Get.bottomSheet<ImageSource>(
      SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const VitheyIcon(LucideIcons.camera),
              title: const Text('Take Photo'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const VitheyIcon(LucideIcons.images),
              title: Text(type == PostType.video
                  ? 'Choose Video'
                  : 'Choose from Library'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
    );
    if (source == null) return;
    await _pickMedia(source);
  }

  Future<void> _pickMedia(ImageSource source) async {
    final type = selectedType.value;
    if (type == null) return;

    final picked = type == PostType.video
        ? await _imagePicker.pickVideo(source: source)
        : await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    mediaPath.value = picked.path;
    mediaFileName.value = picked.name;
    removeExistingMedia.value = false;
  }

  void clearMedia() {
    if (mediaPath.value != null) {
      mediaPath.value = null;
      mediaFileName.value = null;
      return;
    }
    if (existingMediaUrl.value != null) {
      existingMediaUrl.value = null;
      removeExistingMedia.value = true;
    }
  }

  Future<void> pickSchedule(BuildContext context) async {
    final value =
        await CreatePostScheduleSheet.pick(context, initial: scheduledAt.value);
    if (value == null) return;
    if (!value.isAfter(DateTime.now())) {
      errorMessage.value = 'Choose a future date and time';
      return;
    }
    scheduledAt.value = value;
    errorMessage.value = '';
  }

  void clearSchedule() => scheduledAt.value = null;

  Future<void> publish() async {
    if (isPosting.value) return;
    final type = selectedType.value;
    final content = contentController.text.trim();
    if (type == null) {
      errorMessage.value = 'Select a post type';
      return;
    }
    if (content.isEmpty) {
      errorMessage.value = 'Write something to post';
      return;
    }
    if (scheduledAt.value != null &&
        !scheduledAt.value!.isAfter(DateTime.now())) {
      errorMessage.value = 'Choose a future date and time';
      return;
    }
    if (type == PostType.video && mediaPath.value == null) {
      errorMessage.value = 'Choose a video to post';
      return;
    }

    isPosting.value = true;
    errorMessage.value = '';
    try {
      String? mediaFileId;
      final path = mediaPath.value;
      if (path != null) {
        if (_postRepository.useMockApi) {
          // Mock mode keeps the local path so the feed can show the selected
          // photo, and stays null when the user posted text only.
          mediaFileId = path;
        } else {
          isUploadingMedia.value = true;
          final fileName =
              mediaFileName.value ?? path.split(RegExp(r'[\\/]')).last;
          final uploadType = type == PostType.video ? 'VIDEO' : 'POSTER';
          final mimeType =
              _mimeTypeFor(fileName, isVideo: type == PostType.video);
          final uploaded = await _uploadService.uploadPostMedia(
            filePath: path,
            fileName: fileName,
            mimeType: mimeType,
            type: uploadType,
          );
          mediaFileId = uploaded.fileId;
          isUploadingMedia.value = false;
        }
      }

      final jobMeta = type == PostType.job
          ? JobMeta(
              title: jobTitleController.text.trim().isEmpty
                  ? 'Job announcement!'
                  : jobTitleController.text.trim(),
              description: jobCompanyController.text.trim().isEmpty
                  ? null
                  : jobCompanyController.text.trim(),
              requirement: jobRequirementController.text.trim().isEmpty
                  ? null
                  : jobRequirementController.text.trim(),
            )
          : null;
      final post = isEditing
          ? await _postRepository.updatePost(
              postId: editingPost!.id,
              content: content,
              mediaFileId: mediaFileId,
              removeMedia: removeExistingMedia.value,
              jobMeta: jobMeta,
            )
          : await _postRepository.createPost(
              type: type,
              content: content,
              mediaFileId: mediaFileId,
              scheduledAt: scheduledAt.value,
              jobMeta: jobMeta,
            );
      Get.back(result: post);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isPosting.value = false;
      isUploadingMedia.value = false;
    }
  }

  String _mimeTypeFor(String fileName, {required bool isVideo}) {
    final lower = fileName.toLowerCase();
    if (isVideo) {
      return lower.endsWith('.mov') ? 'video/quicktime' : 'video/mp4';
    }
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  @override
  void onClose() {
    contentController.removeListener(_onContentChanged);
    contentController.dispose();
    jobTitleController.dispose();
    jobCompanyController.dispose();
    jobRequirementController.dispose();
    super.onClose();
  }
}
