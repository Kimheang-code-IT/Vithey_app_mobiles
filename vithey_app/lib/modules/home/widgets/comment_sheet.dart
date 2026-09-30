import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_link.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/comment_model.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class CommentSheet extends StatefulWidget {
  const CommentSheet({
    super.key,
    required this.post,
    required this.onCommentAdded,
    required this.onCommentsRemoved,
  });

  final FeedPost post;
  final VoidCallback onCommentAdded;
  final ValueChanged<int> onCommentsRemoved;

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _comments = <CommentModel>[].obs;
  final _isLoading = true.obs;
  final _isSending = false.obs;
  final _likedIds = <String>{}.obs;
  final _dislikedIds = <String>{}.obs;
  final _likeCounts = <String, int>{}.obs;
  final _repo = Get.find<PostRepository>();
  final _currentUser = Get.find<CurrentUserService>();

  CommentModel? _replyTarget;
  CommentModel? _editingComment;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    _isLoading.value = true;
    try {
      final items = await _repo.fetchComments(widget.post.id);
      _comments.assignAll(_flattenThreaded(items));
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending.value) return;

    if (_editingComment != null) {
      await _saveEdit(text);
      return;
    }

    _isSending.value = true;
    final parentId = _replyTarget?.id;
    final temp = CommentModel(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      postId: widget.post.id,
      author: _currentUser.postAuthor,
      text: text,
      createdAt: DateTime.now(),
      parentCommentId: parentId,
      isPending: true,
    );
    _insertComment(temp);
    _controller.clear();
    setState(() => _replyTarget = null);
    widget.onCommentAdded();

    try {
      final saved = await _repo.createComment(
        postId: widget.post.id,
        text: text,
        currentUser: _currentUser.postAuthor,
        parentCommentId: parentId,
      );
      final index = _comments.indexWhere((c) => c.id == temp.id);
      if (index >= 0) _comments[index] = saved;
    } catch (_) {
      final index = _comments.indexWhere((c) => c.id == temp.id);
      if (index >= 0) {
        _comments[index] = temp.copyWith(isPending: false, isFailed: true);
      }
    } finally {
      _isSending.value = false;
    }
  }

  Future<void> _saveEdit(String text) async {
    final editing = _editingComment!;
    _isSending.value = true;
    final index = _comments.indexWhere((c) => c.id == editing.id);
    if (index >= 0) {
      _comments[index] = editing.copyWith(text: text, isPending: true);
    }
    try {
      final saved = await _repo.updateComment(
        postId: widget.post.id,
        commentId: editing.id,
        text: text,
      );
      final savedIndex = _comments.indexWhere((c) => c.id == editing.id);
      if (savedIndex >= 0) _comments[savedIndex] = saved;
      _controller.clear();
      setState(() => _editingComment = null);
    } catch (_) {
      final failedIndex = _comments.indexWhere((c) => c.id == editing.id);
      if (failedIndex >= 0) _comments[failedIndex] = editing;
      Get.snackbar(AppStrings.appName, 'Could not update comment');
    } finally {
      _isSending.value = false;
    }
  }

  void _insertComment(CommentModel comment) {
    final parentId = comment.parentCommentId;
    if (parentId == null || parentId.isEmpty) {
      _comments.insert(0, comment);
      return;
    }
    final parentIndex = _comments.indexWhere((c) => c.id == parentId);
    if (parentIndex < 0) {
      _comments.insert(0, comment);
      return;
    }
    var insertAt = parentIndex + 1;
    while (insertAt < _comments.length &&
        _comments[insertAt].parentCommentId == parentId) {
      insertAt++;
    }
    _comments.insert(insertAt, comment);
  }

  void _replyTo(CommentModel comment) {
    final parentId = comment.parentCommentId;
    final parent = parentId == null || parentId.isEmpty
        ? comment
        : _comments.firstWhereOrNull((c) => c.id == parentId) ?? comment;
    setState(() {
      _editingComment = null;
      _replyTarget = parent;
    });
    final handle = parent.author.fullName.replaceAll(' ', '');
    _controller.text = '@$handle ';
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    _focusNode.requestFocus();
  }

  void _startEdit(CommentModel comment) {
    if (!comment.isOwnedBy(_currentUser.userId)) return;
    setState(() {
      _replyTarget = null;
      _editingComment = comment;
    });
    _controller.text = comment.text;
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    _focusNode.requestFocus();
  }

  Future<void> _delete(CommentModel comment) async {
    if (!comment.isOwnedBy(_currentUser.userId)) return;
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete comment?',
      message: 'This comment will be removed permanently.',
      confirmLabel: 'Delete',
      variant: ConfirmDialogVariant.destructive,
    );
    if (confirmed != true) return;

    final removed = _comments
        .where((c) => c.id == comment.id || c.parentCommentId == comment.id)
        .toList();
    _comments.removeWhere(
      (c) => c.id == comment.id || c.parentCommentId == comment.id,
    );
    widget.onCommentsRemoved(removed.length);
    try {
      await _repo.deleteComment(
        postId: widget.post.id,
        commentId: comment.id,
      );
    } catch (_) {
      _comments.assignAll(_flattenThreaded([..._comments, ...removed]));
      widget.onCommentsRemoved(-removed.length);
      Get.snackbar(AppStrings.appName, 'Could not delete comment');
    }
  }

  void _toggleLike(CommentModel comment) {
    final id = comment.id;
    final liked = _likedIds.contains(id);
    _dislikedIds.remove(id);
    if (liked) {
      _likedIds.remove(id);
      _likeCounts[id] = ((_likeCounts[id] ?? 1) - 1).clamp(0, 999999);
      if ((_likeCounts[id] ?? 0) == 0) _likeCounts.remove(id);
    } else {
      _likedIds.add(id);
      _likeCounts[id] = (_likeCounts[id] ?? 0) + 1;
    }
  }

  void _toggleDislike(CommentModel comment) {
    final id = comment.id;
    final disliked = _dislikedIds.contains(id);
    if (_likedIds.contains(id)) {
      _likedIds.remove(id);
      _likeCounts[id] = ((_likeCounts[id] ?? 1) - 1).clamp(0, 999999);
      if ((_likeCounts[id] ?? 0) == 0) _likeCounts.remove(id);
    }
    if (disliked) {
      _dislikedIds.remove(id);
    } else {
      _dislikedIds.add(id);
    }
  }

  List<CommentModel> _flattenThreaded(List<CommentModel> items) {
    final roots = items.where((c) => !c.isReply).toList();
    final replies = <String, List<CommentModel>>{};
    for (final reply in items.where((c) => c.isReply)) {
      replies.putIfAbsent(reply.parentCommentId!, () => []).add(reply);
    }
    return [
      for (final root in roots) ...[
        root,
        ...?replies[root.id],
      ],
    ];
  }

  String _compactTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: DraggableScrollableSheet(
        initialChildSize: 0.94,
        minChildSize: 0.55,
        maxChildSize: 0.98,
        expand: false,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colors.cardSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(VitheyRadii.sheet),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.muted.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 12, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const VitheyIcon(
                          LucideIcons.thumbsUp,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Comments',
                          style: context.text.titleLarge?.copyWith(fontSize: 16),
                        ),
                      ),
                      Text(
                        widget.post.shareCount > 0
                            ? '${widget.post.shareCount} shares'
                            : '${widget.post.commentCount} comments',
                        style: context.text.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.border),
                Expanded(
                  child: Obx(() {
                    if (_isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    if (_comments.isEmpty) {
                      return EmptyStateWidget(
                        title: 'No comments yet',
                        subtitle: 'Be the first to comment.',
                        icon: LucideIcons.messageCircle,
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 10, 8, 16),
                      itemCount: _comments.length,
                      itemBuilder: (_, index) =>
                          _buildComment(context, _comments[index]),
                    );
                  }),
                ),
                _buildComposer(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildComment(BuildContext context, CommentModel comment) {
    final colors = context.appColors;
    final isReply = comment.isReply;
    final isOwn = comment.isOwnedBy(_currentUser.userId);

    return Obx(() {
      final liked = _likedIds.contains(comment.id);
      final disliked = _dislikedIds.contains(comment.id);
      final likeCount = _likeCounts[comment.id] ?? 0;

      return Padding(
        padding: EdgeInsets.fromLTRB(isReply ? 36 : 4, 6, 4, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              name: comment.author.fullName,
              imageUrl: comment.author.avatarUrl,
              radius: isReply ? 14 : 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: comment.author.fullName,
                                    style: context.text.bodyMedium?.copyWith(
                                      color: colors.heading,
                                      fontSize: isReply ? 13.5 : 14.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '  ·  ${_compactTime(comment.createdAt)}',
                                    style: context.text.bodyMedium?.copyWith(
                                      color: colors.muted,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                            _CommentText(
                              text: comment.text,
                              fontSize: isReply ? 13.5 : 14.5,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _ActionLabel(
                                  label: 'Reply',
                                  onTap: () => _replyTo(comment),
                                ),
                                if (isOwn) ...[
                                  const SizedBox(width: 14),
                                  _ActionLabel(
                                    label: 'Edit',
                                    onTap: () => _startEdit(comment),
                                  ),
                                  const SizedBox(width: 14),
                                  _ActionLabel(
                                    label: 'Delete',
                                    color: context.scheme.error,
                                    onTap: () => _delete(comment),
                                  ),
                                ],
                                if (comment.isPending) ...[
                                  const SizedBox(width: 14),
                                  Text(
                                    'Sending…',
                                    style: context.text.bodyMedium
                                        ?.copyWith(color: colors.muted, fontSize: 12),
                                  ),
                                ],
                                if (likeCount > 0) ...[
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.inputFill,
                                      borderRadius:
                                          BorderRadius.circular(VitheyRadii.pill),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const VitheyIcon(
                                          LucideIcons.thumbsUp,
                                          size: 12,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$likeCount',
                                          style: context.text.labelLarge
                                              ?.copyWith(
                                            fontSize: 12,
                                            color: colors.heading,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VitheyIconButton(
                            icon: liked
                                ? LucideIcons.thumbsUp
                                : LucideIcons.thumbsUp,
                            color: liked
                                ? AppColors.primary
                                : colors.muted,
                            tooltip: 'Like',
                            onTap: () => _toggleLike(comment),
                          ),
                          VitheyIconButton(
                            icon: disliked
                                ? LucideIcons.thumbsDown
                                : LucideIcons.thumbsDown,
                            color: disliked
                                ? colors.heading
                                : colors.muted,
                            tooltip: 'Dislike',
                            onTap: () => _toggleDislike(comment),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildComposer(BuildContext context) {
    final colors = context.appColors;
    final me = _currentUser.postAuthor;
    final modeLabel = _editingComment != null
        ? 'Editing comment'
        : _replyTarget != null
            ? 'Replying to ${_replyTarget!.author.fullName}'
            : null;
    final hint = _editingComment != null
        ? 'Edit your comment…'
        : 'Comment as ${me.fullName.split(' ').first}';

    // Avatar diameter == single-line input height (focus keeps same height).
    const fieldHeight = 36.0;
    const avatarRadius = fieldHeight / 2;
    const maxLines = 5;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (modeLabel != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          modeLabel,
                          style: context.text.labelMedium?.copyWith(fontSize: 12.5),
                        ),
                      ),
                      VitheyTextLink(
                        label: 'Cancel',
                        onPressed: () {
                          setState(() {
                            _replyTarget = null;
                            _editingComment = null;
                          });
                          _controller.clear();
                        },
                        color: colors.muted,
                        fontSize: 12.5,
                      ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  UserAvatar(
                    name: me.fullName,
                    imageUrl: me.avatarUrl,
                    radius: avatarRadius,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _controller,
                      builder: (context, value, _) {
                        return Obx(() {
                          final canSend = value.text.trim().isNotEmpty &&
                              !_isSending.value;
                          return Container(
                            decoration: BoxDecoration(
                              color: colors.inputFill,
                              borderRadius:
                                  BorderRadius.circular(VitheyRadii.pill),
                              border: Border.all(
                                color: colors.border.withValues(alpha: 0.6),
                              ),
                            ),
                            padding: const EdgeInsets.only(left: 12, right: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minHeight: fieldHeight,
                                      maxHeight: 100,
                                    ),
                                    child: TextField(
                                      controller: _controller,
                                      focusNode: _focusNode,
                                      minLines: 1,
                                      maxLines: maxLines,
                                      keyboardType: TextInputType.multiline,
                                      cursorColor: AppColors.primary,
                                      style: context.text.bodyMedium
                                          ?.copyWith(height: 1.3),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: false,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        hintText: hint,
                                        hintStyle: context.text.bodyMedium
                                            ?.copyWith(color: colors.muted),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: fieldHeight,
                                  height: fieldHeight,
                                  child: IconButton(
                                    tooltip: _editingComment != null
                                        ? 'Save'
                                        : 'Send',
                                    onPressed: canSend ? _send : null,
                                    padding: EdgeInsets.zero,
                                    icon: _isSending.value
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : VitheyIcon(
                                            LucideIcons.send,
                                            size: 18,
                                            color: canSend
                                                ? AppColors.primary
                                                : colors.muted
                                                    .withValues(alpha: 0.45),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionLabel extends StatelessWidget {
  const _ActionLabel({
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Text(
        label,
        style: context.text.bodyMedium?.copyWith(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: color ?? context.appColors.muted,
        ),
      ),
    );
  }
}

class _CommentText extends StatelessWidget {
  const _CommentText({required this.text, required this.fontSize});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final spans = <InlineSpan>[];
    final regex = RegExp(r'(@[A-Za-z0-9_]+)');
    var start = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return Text.rich(
      TextSpan(
        style: context.text.bodyMedium?.copyWith(
          fontSize: fontSize,
          height: 1.35,
          color: colors.heading,
        ),
        children: spans.isEmpty ? [TextSpan(text: text)] : spans,
      ),
    );
  }
}
