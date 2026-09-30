import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/modules/profile/profile_navigation.dart';
import 'package:aub_connect_app/data/models/search_args.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/data/repositories/search_repository.dart';

class SearchSeeAllController extends GetxController {
  SearchSeeAllController(this._repository, this.args);

  final SearchRepository _repository;
  final SearchSeeAllArgs args;

  final people = <UserSearchResult>[].obs;
  final posts = <PostSearchResult>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;

  int _page = 1;
  bool _hasMore = true;

  bool get isPeople => args.category == SearchSeeAllCategory.people;

  @override
  void onInit() {
    super.onInit();
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    isLoading.value = true;
    hasError.value = false;
    _page = 1;
    _hasMore = true;
    people.clear();
    posts.clear();
    try {
      if (isPeople) {
        final result =
            await _repository.searchPeople(query: args.query, page: _page);
        people.assignAll(result.items);
        _hasMore = result.hasMore;
      } else {
        final result = await _repository.searchPosts(
          query: args.query,
          type: args.postType,
          page: _page,
        );
        posts.assignAll(result.items);
        _hasMore = result.hasMore;
      }
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !_hasMore || isLoading.value) return;
    isLoadingMore.value = true;
    try {
      final nextPage = _page + 1;
      if (isPeople) {
        final result =
            await _repository.searchPeople(query: args.query, page: nextPage);
        people.addAll(result.items);
        _hasMore = result.hasMore;
      } else {
        final result = await _repository.searchPosts(
          query: args.query,
          type: args.postType,
          page: nextPage,
        );
        posts.addAll(result.items);
        _hasMore = result.hasMore;
      }
      _page = nextPage;
    } catch (_) {
      // keep loaded items
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> openPerson(UserSearchResult user) async {
    await _repository.addRecentUser(user);
    openUserProfile(user.userId);
  }

  void openPost(String postId) =>
      Get.toNamed(AppRoutes.postDetail, arguments: postId);

  Future<void> messagePerson(UserSearchResult user) async {
    try {
      final chatRepo = Get.find<ChatRepository>();
      final conversationId =
          await chatRepo.findOrCreateConversation(user.userId);
      await _repository.addRecentUser(user);
      Get.toNamed(AppRoutes.chatDetail,
          arguments: ChatDetailArgs(conversationId: conversationId));
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not open chat');
    }
  }
}
