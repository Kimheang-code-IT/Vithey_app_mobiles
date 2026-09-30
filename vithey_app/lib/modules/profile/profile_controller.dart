import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/post_mutation_result.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/jobs/models/apply_cv_args.dart';
import 'package:aub_connect_app/modules/jobs/models/apply_cv_result.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/modules/home/create_post/models/create_post_args.dart';
import 'package:aub_connect_app/modules/profile/profile_all_posts_mixin.dart';
import 'package:aub_connect_app/modules/profile/profile_tabs_host.dart';

/// Own profile only (Khorn Molika / logged-in user) — main Profile tab.
class ProfileController extends GetxController
    with GetSingleTickerProviderStateMixin, ProfileAllPostsMixin
    implements ProfileTabsHost {
  ProfileController(this._profileRepository);

  final ProfileRepository _profileRepository;

  @override
  ProfileRepository get profileRepository => _profileRepository;

  @override
  String get profileUserId => _userId;

  @override
  late TabController tabController;
  @override
  final profile = Rxn<UserProfileModel>();
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final appliedJobs = <AppliedJobSummary>[].obs;
  final appliedJobsLoading = false.obs;
  bool _appliedJobsLoaded = false;

  @override
  final tabPosts = <PostType, RxList<FeedPost>>{
    PostType.poster: <FeedPost>[].obs,
    PostType.video: <FeedPost>[].obs,
    PostType.job: <FeedPost>[].obs,
  };

  @override
  final tabLoading = <PostType, RxBool>{
    PostType.poster: false.obs,
    PostType.video: false.obs,
    PostType.job: false.obs,
  };

  @override
  final tabLoaded = <PostType, bool>{};

  late final String _userId;

  @override
  bool get isOwnProfile => true;

  @override
  void onInit() {
    super.onInit();
    _userId = ProfileRepository.currentUserId;
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(_onTabChanged);
    loadProfile();
  }

  void _onTabChanged() {
    if (tabController.indexIsChanging) return;
    final index = tabController.index;
    if (index == 4) {
      _ensureAppliedJobsLoaded();
      return;
    }
    final type = _typeForTab(index);
    if (type != null) _ensureTabLoaded(type);
  }

  PostType? _typeForTab(int index) {
    return switch (index) {
      1 => PostType.video,
      2 => PostType.poster,
      3 => PostType.job,
      _ => null,
    };
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      profile.value = await _profileRepository.getProfile(_userId);
      await ensureAllPostsLoaded();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      profile.value = await _profileRepository.getProfile(_userId);
    } catch (_) {
      await loadProfile();
    }
  }

  Future<void> _ensureTabLoaded(PostType type) async {
    if (tabLoaded[type] == true || tabLoading[type]!.value) return;
    tabLoading[type]!.value = true;
    try {
      final result = await _profileRepository.getUserPosts(
        userId: _userId,
        type: type,
        page: 1,
      );
      tabPosts[type]!.assignAll(result);
      tabLoaded[type] = true;
    } catch (e) {
      Get.snackbar(AppStrings.appName, 'Could not load ${_labelForType(type)}');
    } finally {
      tabLoading[type]!.value = false;
    }
  }

  Future<void> _ensureAppliedJobsLoaded() async {
    if (_appliedJobsLoaded || appliedJobsLoading.value) return;
    appliedJobsLoading.value = true;
    try {
      appliedJobs.assignAll(await _profileRepository.getMyAppliedJobs());
      _appliedJobsLoaded = true;
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not load applied jobs');
    } finally {
      appliedJobsLoading.value = false;
    }
  }

  String _labelForType(PostType type) {
    return switch (type) {
      PostType.poster => 'posters',
      PostType.video => 'reels',
      PostType.job => 'jobs',
    };
  }

  void shareProfile() {
    final current = profile.value;
    if (current == null) return;
    Share.share('Check out ${current.fullName} on Vithey App');
  }

  void openEditProfile() async {
    final result = await Get.toNamed(AppRoutes.editProfile);
    if (result == true) {
      await refreshProfile();
    }
  }

  /// Persist skills from Profile All tab (add / edit / remove).
  Future<void> saveSkills(List<ProfileSkill> skills) async {
    try {
      profile.value = await _profileRepository.updateProfile(skills: skills);
    } catch (e) {
      Get.snackbar(AppStrings.appName, e.toString());
    }
  }

  void openVerifyStudent() {
    final verified =
        Get.find<StudentVerificationRepository>().isVerified.value;
    if (verified) {
      Get.toNamed(AppRoutes.verificationStatus);
    } else {
      Get.toNamed(AppRoutes.studentVerification);
    }
  }

  void openPreviewOwnCv() => Get.toNamed(AppRoutes.previewOwnCv);

  @override
  void openPost(String postId) {
    Get.toNamed(AppRoutes.postDetail, arguments: postId)?.then((result) {
      if (result is PostMutationResult) {
        for (final posts in tabPosts.values) {
          posts.removeWhere((post) => post.id == result.postId);
        }
      } else if (result is FeedPost) {
        _replacePost(result);
      }
    });
  }

  @override
  void openPostAnalytics(FeedPost post) {
    if (!isOwnProfile) return;
    Get.toNamed(AppRoutes.postAnalytics, arguments: post);
  }

  @override
  void editPost(FeedPost post) {
    if (!post.isOwnPost) return;
    Get.toNamed(
      AppRoutes.createPost,
      arguments: CreatePostArgs(editingPost: post),
    )?.then((result) {
      if (result is FeedPost) _replacePost(result);
    });
  }

  @override
  Future<void> deletePost(BuildContext context, FeedPost post) async {
    if (!post.isOwnPost) return;
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete post?',
      message:
          'This post and its comments will be permanently removed. This cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Keep post',
      variant: ConfirmDialogVariant.destructive,
    );
    if (confirmed != true) return;
    try {
      await Get.find<PostRepository>().deletePost(post.id);
      tabPosts[post.type]!.removeWhere((item) => item.id == post.id);
      Get.snackbar(AppStrings.appName, 'Post deleted');
    } catch (error) {
      Get.snackbar(AppStrings.appName, error.toString());
    }
  }

  void _replacePost(FeedPost updated) {
    final posts = tabPosts[updated.type]!;
    final index = posts.indexWhere((post) => post.id == updated.id);
    if (index >= 0) posts[index] = updated;
  }

  @override
  void openJobApplicants(FeedPost jobPost) {
    Get.toNamed(
      AppRoutes.jobApplicants,
      arguments: JobApplicantsArgs(
        jobPostId: jobPost.id,
        jobTitle: jobPost.jobMeta.title ?? 'Job',
      ),
    );
  }

  @override
  void editJobPost(FeedPost jobPost) {
    Get.toNamed(
      AppRoutes.createPost,
      arguments: CreatePostArgs(editingPost: jobPost),
    )?.then((result) {
      if (result is FeedPost) _replacePost(result);
    });
  }

  @override
  Future<void> deleteJobPost(BuildContext context, FeedPost jobPost) async {
    if (!jobPost.isOwnPost) return;
    final title = jobPost.jobMeta.title?.trim();
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete job?',
      message: title == null || title.isEmpty
          ? 'Remove this job from your posts? This cannot be undone.'
          : 'Remove “$title” from your posts? This cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Keep job',
      variant: ConfirmDialogVariant.destructive,
    );
    if (confirmed != true) return;
    try {
      await Get.find<PostRepository>().deletePost(jobPost.id);
      tabPosts[PostType.job]!.removeWhere((p) => p.id == jobPost.id);
      Get.snackbar(AppStrings.appName, 'Job deleted');
    } catch (error) {
      Get.snackbar(AppStrings.appName, error.toString());
    }
  }

  @override
  void applyToJob(String jobPostId) {
    final jobs = tabPosts[PostType.job] ?? const <FeedPost>[];
    FeedPost? preview;
    for (final job in jobs) {
      if (job.id == jobPostId) {
        preview = job;
        break;
      }
    }
    Get.toNamed(
      AppRoutes.applyCv,
      arguments: ApplyCvArgs(jobPostId: jobPostId, jobPreview: preview),
    )?.then((result) {
      if (result is ApplyCvResult) {
        final list = tabPosts[PostType.job]!;
        final index = list.indexWhere((p) => p.id == jobPostId);
        if (index >= 0) {
          list[index] = list[index]
              .copyWith(applicationState: JobApplicationState.applied);
        }
        _appliedJobsLoaded = false;
        if (tabController.index == 4) {
          _ensureAppliedJobsLoaded();
        }
      }
    });
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.onClose();
  }
}
