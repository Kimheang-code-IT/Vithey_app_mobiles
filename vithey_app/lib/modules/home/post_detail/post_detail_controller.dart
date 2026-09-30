import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/data/models/comment_model.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/post_author.dart';
import 'package:aub_connect_app/data/models/post_mutation_result.dart';
import 'package:aub_connect_app/data/repositories/comment_repository.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/modules/jobs/models/apply_cv_args.dart';
import 'package:aub_connect_app/modules/jobs/models/apply_cv_result.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/modules/home/create_post/models/create_post_args.dart';

class PostDetailController extends GetxController {
  PostDetailController(
    this._postRepository,
    this._commentRepository,
    this._jobApplicationRepository,
  );

  final PostRepository _postRepository;
  final CommentRepository _commentRepository;
  final JobApplicationRepository _jobApplicationRepository;

  final post = Rxn<FeedPost>();
  final comments = <CommentModel>[].obs;
  final isLoading = true.obs;
  final isCommentsLoading = false.obs;
  final isSending = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final mentionQuery = ''.obs;
  final showMentions = false.obs;
  final replyTarget = Rxn<CommentModel>();
  final editingComment = Rxn<CommentModel>();

  final commentController = TextEditingController();
  final commentFocus = FocusNode();

  String? _postId;
  int _commentPage = 1;
  bool _hasMoreComments = true;

  CurrentUserService get _currentUser => Get.find<CurrentUserService>();
  String get currentUserId => _currentUser.userId;

  @override
  void onInit() {
    super.onInit();
    _postId = Get.arguments as String?;
    commentController.addListener(_onCommentChanged);
    loadPost();
  }

  Future<void> loadPost() async {
    if (_postId == null) {
      hasError.value = true;
      errorMessage.value = 'Post not found';
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    try {
      final loaded = await _postRepository.fetchPost(_postId!);
      if (loaded == null) {
        hasError.value = true;
        errorMessage.value = 'Post unavailable';
        return;
      }
      post.value = await _normalize(loaded);
      await loadComments(reset: true);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadComments({bool reset = false}) async {
    if (_postId == null || isCommentsLoading.value) return;
    if (!reset && !_hasMoreComments) return;

    if (reset) {
      _commentPage = 1;
      _hasMoreComments = true;
      comments.clear();
    }

    isCommentsLoading.value = true;
    try {
      final items = await _commentRepository.fetchComments(
        postId: _postId!,
        page: _commentPage,
      );
      if (items.isEmpty) {
        _hasMoreComments = false;
      } else {
        final existing = comments.map((c) => c.id).toSet();
        final incoming = items.where((c) => !existing.contains(c.id)).toList();
        if (reset) {
          comments.assignAll(_flattenThreaded(incoming));
        } else {
          comments.addAll(incoming);
          comments.assignAll(_flattenThreaded(comments.toList()));
        }
        _commentPage += 1;
      }
    } finally {
      isCommentsLoading.value = false;
    }
  }

  Future<FeedPost> _normalize(FeedPost item) async {
    var normalized = item.copyWith(
      userReacted: _postRepository.isReacted(item.id) || item.userReacted,
      isFollowingAuthor:
          _postRepository.isFollowing(item.author.id) || item.isFollowingAuthor,
    );
    if (normalized.type == PostType.job &&
        !normalized.isOwnPost &&
        normalized.applicationState != JobApplicationState.applied) {
      try {
        final applied =
            await _jobApplicationRepository.hasUserApplied(normalized.id);
        if (applied) {
          normalized = normalized.copyWith(
              applicationState: JobApplicationState.applied);
        }
      } catch (_) {}
    }
    return normalized;
  }

  Future<void> toggleLike() async {
    final current = post.value;
    if (current == null) return;

    final reacted = !current.userReacted;
    post.value = current.copyWith(
      userReacted: reacted,
      reactionCount:
          (current.reactionCount + (reacted ? 1 : -1)).clamp(0, 999999),
    );

    try {
      await _postRepository.toggleReaction(current.id);
    } catch (_) {
      post.value = current;
      Get.snackbar(AppStrings.appName, 'Could not update reaction');
    }
  }

  Future<void> toggleFollow() async {
    final current = post.value;
    if (current == null || current.isOwnPost) return;

    final following = !current.isFollowingAuthor;
    post.value = current.copyWith(isFollowingAuthor: following);

    try {
      await _postRepository.setFollow(current.author.id, following);
    } catch (_) {
      post.value = current;
      Get.snackbar(AppStrings.appName, 'Could not update follow');
    }
  }

  void editPost() {
    final current = post.value;
    if (current == null || !current.isOwnPost) return;
    Get.toNamed(
      AppRoutes.createPost,
      arguments: CreatePostArgs(editingPost: current),
    )?.then((result) {
      if (result is FeedPost) post.value = result;
    });
  }

  Future<void> deletePost(BuildContext context) async {
    final current = post.value;
    if (current == null || !current.isOwnPost) return;
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
      await _postRepository.deletePost(current.id);
      Get.back(result: PostMutationResult.deleted(current.id));
    } catch (error) {
      Get.snackbar(AppStrings.appName, error.toString());
    }
  }

  Future<void> submitComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty || isSending.value || _postId == null) return;

    final editing = editingComment.value;
    if (editing != null) {
      await _saveEditedComment(editing, text);
      return;
    }

    isSending.value = true;
    showMentions.value = false;

    final parentId = replyTarget.value?.id;
    final author = _currentUser.postAuthor;
    final temp = CommentModel(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      postId: _postId!,
      author: author,
      text: text,
      createdAt: DateTime.now(),
      parentCommentId: parentId,
      isPending: true,
    );
    _insertComment(temp);
    commentController.clear();
    replyTarget.value = null;

    final current = post.value;
    if (current != null) {
      post.value = current.copyWith(commentCount: current.commentCount + 1);
    }

    try {
      final saved = await _commentRepository.createComment(
        postId: _postId!,
        text: text,
        currentUser: author,
        parentCommentId: parentId,
      );
      final index = comments.indexWhere((c) => c.id == temp.id);
      if (index >= 0) comments[index] = saved;
    } catch (_) {
      final index = comments.indexWhere((c) => c.id == temp.id);
      if (index >= 0) {
        comments[index] = temp.copyWith(isPending: false, isFailed: true);
      }
      if (current != null) post.value = current;
      Get.snackbar(AppStrings.appName, 'Could not post comment');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> _saveEditedComment(CommentModel editing, String text) async {
    isSending.value = true;
    showMentions.value = false;
    final previous = editing;
    final index = comments.indexWhere((c) => c.id == editing.id);
    if (index >= 0) {
      comments[index] = editing.copyWith(text: text, isPending: true);
    }

    try {
      final saved = await _commentRepository.updateComment(
        postId: _postId!,
        commentId: editing.id,
        text: text,
      );
      final savedIndex = comments.indexWhere((c) => c.id == editing.id);
      if (savedIndex >= 0) comments[savedIndex] = saved;
      commentController.clear();
      editingComment.value = null;
    } catch (_) {
      final failedIndex = comments.indexWhere((c) => c.id == editing.id);
      if (failedIndex >= 0) comments[failedIndex] = previous;
      Get.snackbar(AppStrings.appName, 'Could not update comment');
    } finally {
      isSending.value = false;
    }
  }

  void _insertComment(CommentModel comment) {
    final parentId = comment.parentCommentId;
    if (parentId == null || parentId.isEmpty) {
      comments.insert(0, comment);
      return;
    }
    final parentIndex = comments.indexWhere((c) => c.id == parentId);
    if (parentIndex < 0) {
      comments.insert(0, comment);
      return;
    }
    var insertAt = parentIndex + 1;
    while (insertAt < comments.length &&
        comments[insertAt].parentCommentId == parentId) {
      insertAt++;
    }
    comments.insert(insertAt, comment);
  }

  void mentionUser(PostAuthor user) {
    final handle = user.fullName.replaceAll(' ', '');
    final text = commentController.text;
    final atIndex = text.lastIndexOf('@');
    if (atIndex >= 0) {
      commentController.text = '${text.substring(0, atIndex)}@$handle ';
    } else {
      commentController.text = '$text@$handle ';
    }
    commentController.selection =
        TextSelection.collapsed(offset: commentController.text.length);
    showMentions.value = false;
    mentionQuery.value = '';
    commentFocus.requestFocus();
  }

  void replyTo(CommentModel comment) {
    // One nested level: replies attach to the top-level parent.
    editingComment.value = null;
    final parentId = comment.parentCommentId;
    final parent = parentId == null || parentId.isEmpty
        ? comment
        : comments.firstWhereOrNull((c) => c.id == parentId) ?? comment;
    replyTarget.value = parent;
    final handle = parent.author.fullName.replaceAll(' ', '');
    commentController.text = '@$handle ';
    commentController.selection =
        TextSelection.collapsed(offset: commentController.text.length);
    showMentions.value = false;
    mentionQuery.value = '';
    commentFocus.requestFocus();
  }

  void cancelReply() {
    replyTarget.value = null;
  }

  void startEdit(CommentModel comment) {
    if (!comment.isOwnedBy(currentUserId)) return;
    replyTarget.value = null;
    editingComment.value = comment;
    commentController.text = comment.text;
    commentController.selection =
        TextSelection.collapsed(offset: commentController.text.length);
    showMentions.value = false;
    mentionQuery.value = '';
    commentFocus.requestFocus();
  }

  void cancelEdit() {
    editingComment.value = null;
    commentController.clear();
  }

  Future<void> deleteComment(CommentModel comment) async {
    if (!comment.isOwnedBy(currentUserId) || _postId == null) return;

    final confirmed = await showConfirmDialog(
      context: Get.context!,
      title: 'Delete comment?',
      message: 'This comment will be removed permanently.',
      confirmLabel: 'Delete',
      variant: ConfirmDialogVariant.destructive,
    );
    if (confirmed != true) return;

    final removed = comments
        .where(
          (c) => c.id == comment.id || c.parentCommentId == comment.id,
        )
        .toList();
    comments.removeWhere(
      (c) => c.id == comment.id || c.parentCommentId == comment.id,
    );
    if (editingComment.value?.id == comment.id) cancelEdit();
    if (replyTarget.value?.id == comment.id) cancelReply();

    final current = post.value;
    if (current != null) {
      post.value = current.copyWith(
        commentCount: (current.commentCount - removed.length).clamp(0, 999999),
      );
    }

    try {
      await _commentRepository.deleteComment(
        postId: _postId!,
        commentId: comment.id,
      );
    } catch (_) {
      comments.assignAll(_flattenThreaded([...comments, ...removed]));
      if (current != null) post.value = current;
      Get.snackbar(AppStrings.appName, 'Could not delete comment');
    }
  }

  List<CommentModel> _flattenThreaded(List<CommentModel> items) {
    final roots = items.where((c) => !c.isReply).toList();
    final byParent = <String, List<CommentModel>>{};
    for (final reply in items.where((c) => c.isReply)) {
      byParent.putIfAbsent(reply.parentCommentId!, () => []).add(reply);
    }
    final out = <CommentModel>[];
    final placed = <String>{};
    for (final root in roots) {
      out.add(root);
      placed.add(root.id);
      for (final reply in byParent[root.id] ?? const <CommentModel>[]) {
        out.add(reply);
        placed.add(reply.id);
      }
    }
    for (final item in items) {
      if (!placed.contains(item.id)) out.add(item);
    }
    return out;
  }

  void applyJob() {
    final current = post.value;
    if (current == null || current.type != PostType.job) return;
    Get.toNamed(
      AppRoutes.applyCv,
      arguments: ApplyCvArgs(jobPostId: current.id, jobPreview: current),
    )?.then((result) {
      if (result is ApplyCvResult) {
        post.value =
            current.copyWith(applicationState: JobApplicationState.applied);
      }
    });
  }

  void _onCommentChanged() {
    final text = commentController.text;
    final match = RegExp(r'@(\w*)$').firstMatch(text);
    if (match != null) {
      mentionQuery.value = match.group(1) ?? '';
      showMentions.value = true;
    } else {
      showMentions.value = false;
      mentionQuery.value = '';
    }
  }

  List<PostAuthor> get filteredMentionUsers =>
      _commentRepository.searchMentionUsers(mentionQuery.value);

  @override
  void onClose() {
    commentController.removeListener(_onCommentChanged);
    commentController.dispose();
    commentFocus.dispose();
    super.onClose();
  }
}
