import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/profile/profile_controller.dart';

/// Shared contract for profile tab widgets (own + visitor screens).
abstract class ProfileTabsHost extends GetxController {
  Rxn<UserProfileModel> get profile;
  bool get isOwnProfile;
  TabController get tabController;
  Map<PostType, RxList<FeedPost>> get tabPosts;
  Map<PostType, RxBool> get tabLoading;

  Future<void> ensureAllPostsLoaded();
  List<FeedPost> get mergedReelsAndPosters;
  bool get isAllPostsLoading;

  void openPost(String postId);
  void openPostAnalytics(FeedPost post);
  void openJobApplicants(FeedPost jobPost);
  void applyToJob(String jobPostId);
  void editPost(FeedPost post);
  Future<void> deletePost(BuildContext context, FeedPost post);
  void editJobPost(FeedPost jobPost);
  Future<void> deleteJobPost(BuildContext context, FeedPost jobPost);
}

ProfileTabsHost resolveProfileTabsHost(ProfileTabsHost? host) =>
    host ?? Get.find<ProfileController>();
