import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/post_mutation_result.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/modules/profile/profile_all_posts_mixin.dart';
import 'package:aub_connect_app/modules/profile/profile_tabs_host.dart';

/// Visitor profile (e.g. Heng Liza viewed by Khorn Molika).
class ProfileViewController extends GetxController
    with GetSingleTickerProviderStateMixin, ProfileAllPostsMixin
    implements ProfileTabsHost {
  ProfileViewController(this._profileRepository);

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
  bool get isOwnProfile => false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is! ProfileArgs) {
      hasError.value = true;
      errorMessage.value = 'Profile not found';
      isLoading.value = false;
      tabController = TabController(length: 5, vsync: this);
      return;
    }
    _userId = args.userId;
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
      var loaded = await _profileRepository.getProfile(_userId);
      loaded = loaded.copyWith(
        isFollowing: _profileRepository.isFollowing(loaded.id),
      );
      profile.value = loaded;
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
      var loaded = await _profileRepository.getProfile(_userId);
      loaded = loaded.copyWith(
        isFollowing: _profileRepository.isFollowing(loaded.id),
      );
      profile.value = loaded;
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
      appliedJobs.assignAll(
        await _profileRepository.getUserAppliedJobs(_userId),
      );
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

  Future<void> toggleFollow() async {
    final current = profile.value;
    if (current == null) return;

    final following = !current.isFollowing;
    profile.value = current.copyWith(
      isFollowing: following,
      followerCount:
          (current.followerCount + (following ? 1 : -1)).clamp(0, 999999999),
    );

    try {
      await _profileRepository.toggleFollow(current.id);
    } catch (_) {
      profile.value = current;
      Get.snackbar(AppStrings.appName, 'Could not update follow');
    }
  }

  Future<void> startMessage() async {
    final current = profile.value;
    if (current == null) return;
    try {
      final chatRepo = Get.find<ChatRepository>();
      final conversationId =
          await chatRepo.findOrCreateConversation(current.id);
      Get.toNamed(
        AppRoutes.chatDetail,
        arguments: ChatDetailArgs(conversationId: conversationId),
      );
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not open chat');
    }
  }

  void shareProfile() {
    final current = profile.value;
    if (current == null) return;
    Share.share('Check out ${current.fullName} on Vithey App');
  }

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
    // Analytics is only for the signed-in user's own profile.
  }

  void _replacePost(FeedPost updated) {
    final posts = tabPosts[updated.type]!;
    final index = posts.indexWhere((post) => post.id == updated.id);
    if (index >= 0) posts[index] = updated;
  }

  @override
  void editPost(FeedPost post) {}

  @override
  Future<void> deletePost(BuildContext context, FeedPost post) async {}

  @override
  void openJobApplicants(FeedPost jobPost) {}

  @override
  void editJobPost(FeedPost jobPost) {}

  @override
  Future<void> deleteJobPost(BuildContext context, FeedPost jobPost) async {}

  @override
  void applyToJob(String jobPostId) {}

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.onClose();
  }
}
