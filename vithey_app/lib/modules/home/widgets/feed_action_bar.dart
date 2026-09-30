import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class FeedActionBar extends StatefulWidget {
  const FeedActionBar({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    this.onReact,
    this.alignStart = false,
    this.onDark = false,
    this.showShareAction = true,
  });

  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final ValueChanged<PostReactionType>? onReact;

  /// Kept for profile screens that want compact left-aligned actions.
  final bool alignStart;

  /// Light icons for dark fullscreen overlays.
  final bool onDark;

  /// When false, hides the trailing share action — used on profile cards.
  final bool showShareAction;

  @override
  State<FeedActionBar> createState() => _FeedActionBarState();
}

class _FeedActionBarState extends State<FeedActionBar>
    with SingleTickerProviderStateMixin {
  final _likeKey = GlobalKey();
  OverlayEntry? _pickerEntry;
  late final AnimationController _pickerAnim;

  @override
  void initState() {
    super.initState();
    _pickerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _removePicker();
    _pickerAnim.dispose();
    super.dispose();
  }

  void _removePicker() {
    _pickerEntry?.remove();
    _pickerEntry = null;
    if (_pickerAnim.isAnimating || _pickerAnim.value > 0) {
      _pickerAnim.value = 0;
    }
  }

  Future<void> _showReactionPicker() async {
    if (_pickerEntry != null) {
      _removePicker();
      return;
    }
    HapticFeedback.mediumImpact();

    final box = _likeKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (box == null || overlayBox == null) return;

    final offset = box.localToGlobal(Offset.zero, ancestor: overlayBox);
    final size = box.size;

    _pickerEntry = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removePicker,
              ),
            ),
            Positioned(
              left: (offset.dx - 8).clamp(8.0, overlayBox.size.width - 280),
              top: offset.dy - 64,
              child: FadeTransition(
                opacity: _pickerAnim,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _pickerAnim,
                    curve: Curves.easeOutBack,
                  ),
                  alignment: Alignment.bottomLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: _ReactionPickerBar(
                      selected: widget.post.activeReaction,
                      onSelect: (type) {
                        _removePicker();
                        final handler = widget.onReact;
                        if (handler != null) {
                          handler(type);
                        } else {
                          widget.onLike();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Keep like button area from being blocked oddly
            Positioned(
              left: offset.dx,
              top: offset.dy,
              width: size.width,
              height: size.height,
              child: const SizedBox.shrink(),
            ),
          ],
        );
      },
    );

    overlay.insert(_pickerEntry!);
    await _pickerAnim.forward();
  }

  Color _idleColor(BuildContext context) {
    return widget.onDark
        ? Colors.white.withValues(alpha: 0.85)
        : context.appColors.muted;
  }

  Color _reactionColor(PostReactionType type) {
    return switch (type) {
      PostReactionType.like => const Color(0xFF1877F2),
      PostReactionType.love => const Color(0xFFF33E58),
      PostReactionType.care => const Color(0xFFF7B125),
      PostReactionType.haha => const Color(0xFFF7B125),
      PostReactionType.wow => const Color(0xFFF7B125),
      PostReactionType.sad => const Color(0xFFF7B125),
      PostReactionType.angry => const Color(0xFFE9710F),
    };
  }

  @override
  Widget build(BuildContext context) {
    final idle = _idleColor(context);
    final reaction = widget.post.activeReaction;
    final reacted = reaction != null;
    final likeColor = reacted ? _reactionColor(reaction) : idle;

    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 2, 10, 6),
      child: Row(
        children: [
          // Left action cluster
          Expanded(
            child: Row(
              children: [
                KeyedSubtree(
                  key: _likeKey,
                  child: _IconAction(
                    onTap: widget.onLike,
                    onLongPress: _showReactionPicker,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Idle: Lucide outline. Liked: solid filled thumb + color.
                        // Other reactions: emoji.
                        if (reacted && reaction != PostReactionType.like)
                          Text(reaction.emoji,
                              style: context.text.bodyLarge
                                  ?.copyWith(fontSize: 20))
                        else if (reacted)
                          VitheyIcon(
                            LucideIcons.thumbsUp,
                            size: 22,
                            color: likeColor,
                          )
                        else
                          VitheyIcon(
                            LucideIcons.thumbsUp,
                            size: 22,
                            color: idle,
                          ),
                        if (widget.post.reactionCount > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '${widget.post.reactionCount}',
                            style: context.text.labelLarge
                                ?.copyWith(color: likeColor),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                _IconAction(
                  onTap: widget.onComment,
                  child: VitheyIcon(
                    LucideIcons.messageCircle,
                    size: 22,
                    color: idle,
                  ),
                ),
                if (widget.showShareAction)
                  _IconAction(
                    onTap: widget.onShare,
                    child: VitheyIcon(LucideIcons.share2, size: 22, color: idle),
                  ),
              ],
            ),
          ),

          // Right reaction summary badges
          if (widget.post.reactionCount > 0)
            _ReactionSummary(
              count: widget.post.reactionCount,
              userReaction: reaction,
              onDark: widget.onDark,
            ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.child,
    required this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: child,
        ),
      ),
    );
  }
}

class _ReactionPickerBar extends StatelessWidget {
  const _ReactionPickerBar({
    required this.onSelect,
    this.selected,
  });

  final ValueChanged<PostReactionType> onSelect;
  final PostReactionType? selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: context.appColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: PostReactionType.values.map((type) {
          final isSelected = selected == type;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Material(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => onSelect(type),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(type.emoji,
                      style:
                          context.text.bodyLarge?.copyWith(fontSize: 28)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReactionSummary extends StatelessWidget {
  const _ReactionSummary({
    required this.count,
    required this.onDark,
    this.userReaction,
  });

  final int count;
  final PostReactionType? userReaction;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final badges = <PostReactionType>[
      userReaction ?? PostReactionType.like,
      if (userReaction != PostReactionType.love) PostReactionType.love,
      if (userReaction != PostReactionType.care &&
          userReaction != PostReactionType.love)
        PostReactionType.care,
    ].take(2).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 18.0 + (badges.length - 1) * 12.0,
          height: 22,
          child: Stack(
            children: [
              for (var i = 0; i < badges.length; i++)
                Positioned(
                  left: i * 12.0,
                  child: _ReactionBadge(type: badges[i]),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReactionBadge extends StatelessWidget {
  const _ReactionBadge({required this.type});

  final PostReactionType type;

  Color get _bg => switch (type) {
        PostReactionType.like => const Color(0xFF1877F2),
        PostReactionType.love => const Color(0xFFF33E58),
        PostReactionType.care => const Color(0xFFF7B125),
        _ => const Color(0xFFF7B125),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: _bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        type == PostReactionType.like
            ? '👍'
            : type == PostReactionType.love
                ? '❤️'
                : type.emoji,
        style: context.text.bodyLarge?.copyWith(fontSize: 10, height: 1),
      ),
    );
  }
}
