import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';

/// Loads Reels + Posters tab data (shared source for All tab mixed feed).
mixin ProfileAllPostsMixin on GetxController {
  ProfileRepository get profileRepository;
  String get profileUserId;

  Map<PostType, RxList<FeedPost>> get tabPosts;
  Map<PostType, RxBool> get tabLoading;
  Map<PostType, bool> get tabLoaded;

  bool _allPostsLoaded = false;

  /// Reels + Posters merged, sorted by time posted (most recent first).
  List<FeedPost> get mergedReelsAndPosters {
    final merged = [
      ...tabPosts[PostType.video]!,
      ...tabPosts[PostType.poster]!,
    ];
    merged.sort((a, b) {
      final aHours = DateTime.now().difference(a.createdAt).inHours;
      final bHours = DateTime.now().difference(b.createdAt).inHours;
      return aHours.compareTo(bHours);
    });
    return merged;
  }

  bool get isAllPostsLoading =>
      (tabLoading[PostType.video]!.value &&
          tabPosts[PostType.video]!.isEmpty) ||
      (tabLoading[PostType.poster]!.value &&
          tabPosts[PostType.poster]!.isEmpty);

  Future<void> ensureAllPostsLoaded() async {
    if (_allPostsLoaded) return;
    await Future.wait([
      _loadTab(PostType.video),
      _loadTab(PostType.poster),
    ]);
    _allPostsLoaded = true;
  }

  Future<void> _loadTab(PostType type) async {
    if (tabLoaded[type] == true || tabLoading[type]!.value) return;
    tabLoading[type]!.value = true;
    try {
      final result = await profileRepository.getUserPosts(
        userId: profileUserId,
        type: type,
        page: 1,
      );
      tabPosts[type]!.assignAll(result);
      tabLoaded[type] = true;
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not load posts');
    } finally {
      tabLoading[type]!.value = false;
    }
  }

  void invalidateAllPostsCache() {
    _allPostsLoaded = false;
    tabLoaded.remove(PostType.video);
    tabLoaded.remove(PostType.poster);
  }
}
