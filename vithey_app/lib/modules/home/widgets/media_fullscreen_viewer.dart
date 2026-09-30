import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/core/widgets/vithey_action_sheet.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
/// Opens poster image / video in an immersive detail stage (TikTok-style).
Future<void> showMediaFullscreen(
  BuildContext context,
  FeedPost post, {
  VoidCallback? onLike,
  VoidCallback? onComment,
  VoidCallback? onShare,
  VoidCallback? onFollow,
  VoidCallback? onAuthorTap,
  bool showShareAction = true,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: true,
      barrierColor: Colors.black,
      transitionsBuilder: (context, animation, secondary, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      pageBuilder: (ctx, _, __) => MediaFullscreenViewer(
        post: post,
        onLike: onLike,
        onComment: onComment,
        onShare: onShare,
        onFollow: onFollow,
        onAuthorTap: onAuthorTap,
        showShareAction: showShareAction,
      ),
    ),
  );
}

class MediaFullscreenViewer extends StatefulWidget {
  const MediaFullscreenViewer({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onFollow,
    this.onAuthorTap,
    this.showShareAction = true,
  });

  final FeedPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onFollow;
  final VoidCallback? onAuthorTap;
  final bool showShareAction;

  @override
  State<MediaFullscreenViewer> createState() => _MediaFullscreenViewerState();
}

class _MediaFullscreenViewerState extends State<MediaFullscreenViewer> {
  late FeedPost _post;
  VideoPlayerController? _controller;
  bool _initializing = false;
  bool _captionExpanded = false;
  String? _error;

  bool get _isVideo => _post.type == PostType.video;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (_isVideo) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initPlayer());
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleLike() {
    widget.onLike?.call();
    setState(() {
      final liked = !_post.userReacted;
      _post = _post.copyWith(
        userReacted: liked,
        reactionCount:
            (_post.reactionCount + (liked ? 1 : -1)).clamp(0, 1 << 30),
      );
    });
  }

  void _toggleFollow() {
    widget.onFollow?.call();
    setState(() {
      _post = _post.copyWith(isFollowingAuthor: !_post.isFollowingAuthor);
    });
  }

  void _onComment() {
    widget.onComment?.call();
  }

  void _onShare() {
    widget.onShare?.call();
    final text = _post.content.trim().isNotEmpty
        ? _post.content.trim()
        : (_post.jobMeta.title ?? 'Vithey post');
    Share.share(text);
  }

  Future<void> _initPlayer() async {
    if (_controller != null || _initializing) return;
    final url = _post.mediaUrl;
    if (url == null || url.isEmpty) return;

    setState(() {
      _initializing = true;
      _error = null;
    });

    try {
      late final VideoPlayerController controller;
      if (url.startsWith('http://') || url.startsWith('https://')) {
        controller = VideoPlayerController.networkUrl(Uri.parse(url));
      } else if (url.startsWith('assets/')) {
        controller = VideoPlayerController.asset(url);
      } else {
        controller = VideoPlayerController.file(File(url));
      }
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
      });
      await controller.setLooping(true);
      await controller.play();
      controller.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error = 'Could not play video';
        });
      }
    }
  }

  String get _caption {
    final jobTitle = _post.jobMeta.title?.trim();
    final content = _post.content.trim();
    if (jobTitle != null && jobTitle.isNotEmpty && content.isNotEmpty) {
      return '$jobTitle\n$content';
    }
    if (content.isNotEmpty) return content;
    return jobTitle ?? '';
  }

  String? get _subtitle {
    final role = _post.jobMeta.title?.trim();
    if (role != null && role.isNotEmpty && _post.type == PostType.job) {
      return role;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final caption = _caption;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Media stage
          Positioned.fill(
            child: _isVideo ? _buildVideoStage() : _buildImageStage(),
          ),

          // Top gradient + back
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(top: topInset),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                      shape: const CircleBorder(),
                    ),
                    icon: const VitheyIcon(LucideIcons.arrowLeft,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          // Right-side actions
          Positioned(
            right: 10,
            bottom: 120 + bottomInset,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SideAction(
                  icon: _post.userReacted
                      ? LucideIcons.thumbsUp
                      : LucideIcons.thumbsUp,
                  label:
                      _post.reactionCount > 0 ? '${_post.reactionCount}' : '',
                  active: _post.userReacted,
                  onTap: _toggleLike,
                ),
                const SizedBox(height: 18),
                _SideAction(
                  icon: LucideIcons.messageCircle,
                  label: _post.commentCount > 0 ? '${_post.commentCount}' : '',
                  onTap: _onComment,
                ),
                if (widget.showShareAction) ...[
                  const SizedBox(height: 18),
                  _SideAction(
                    icon: LucideIcons.share2,
                    onTap: _onShare,
                  ),
                ],
              ],
            ),
          ),

          // Bottom author + caption
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(14, 24, 14, 12 + bottomInset),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: widget.onAuthorTap,
                          child: Row(
                            children: [
                              UserAvatar(
                                name: _post.author.fullName,
                                imageUrl: _post.author.avatarUrl,
                                radius: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            _post.author.fullName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        if (!_post.isOwnPost) ...[
                                          Text(
                                            ' • ',
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: _toggleFollow,
                                            child: Text(
                                              _post.isFollowingAuthor
                                                  ? 'Following'
                                                  : 'Follow',
                                              style: context.text.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: _post.isFollowingAuthor
                                                    ? Colors.white70
                                                    : AppColors.primaryLight),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (_subtitle != null)
                                      Text(
                                        _subtitle!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.text.bodySmall?.copyWith(fontSize: 12, color: Colors.white
                                              .withValues(alpha: 0.65)),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (caption.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => setState(
                              () => _captionExpanded = !_captionExpanded,
                            ),
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                                children: [
                                  TextSpan(
                                    text: _captionExpanded ||
                                            caption.length <= 90
                                        ? caption
                                        : '${caption.substring(0, 90).trimRight()}…',
                                  ),
                                  if (!_captionExpanded && caption.length > 90)
                                    const TextSpan(
                                      text: ' more',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showVitheyActionSheet<void>(
                        context: context,
                        title: 'Post actions',
                        actions: [
                          VitheyActionSheetItem(
                            label: 'Share',
                            icon: LucideIcons.share2,
                            onTap: _onShare,
                          ),
                          VitheyActionSheetItem(
                            label: 'View profile',
                            icon: LucideIcons.user,
                            onTap: widget.onAuthorTap,
                          ),
                        ],
                        cancelLabel: 'Cancel',
                      );
                    },
                    icon: const VitheyIcon(LucideIcons.ellipsis, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageStage() {
    return InteractiveViewer(
      minScale: 0.9,
      maxScale: 4,
      child: Center(
        child: _FullscreenImage(url: _post.mediaUrl, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildVideoStage() {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return GestureDetector(
        onTap: () {
          setState(() {
            controller.value.isPlaying ? controller.pause() : controller.play();
          });
        },
        child: Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio == 0
                ? 9 / 16
                : controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(controller),
                if (!controller.value.isPlaying)
                  const VitheyIcon(
                    LucideIcons.circlePlay,
                    color: Colors.white70,
                    size: 72,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: _FullscreenImage(
            url: _post.thumbnailUrl ?? _post.mediaUrl,
            fit: BoxFit.contain,
          ),
        ),
        Center(
          child: _initializing
              ? const CircularProgressIndicator(color: Colors.white)
              : IconButton(
                  iconSize: 72,
                  color: Colors.white70,
                  icon: const VitheyIcon(LucideIcons.circlePlay),
                  onPressed: _initPlayer,
                ),
        ),
        if (_error != null)
          Positioned(
            left: 20,
            right: 20,
            bottom: 160,
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
      ],
    );
  }
}

class _SideAction extends StatelessWidget {
  const _SideAction({
    required this.icon,
    required this.onTap,
    this.label = '',
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    // 48px circular hit target, TikTok-style rail.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VitheyIcon(
              icon,
              color: active ? AppColors.primaryLight : Colors.white,
              size: 28,
              shadows: const [
                Shadow(blurRadius: 8, color: Colors.black54),
              ],
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FullscreenImage extends StatelessWidget {
  const _FullscreenImage({required this.url, required this.fit});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const VitheyIcon(
        LucideIcons.imageOff,
        color: Colors.white54,
        size: 48,
      );
    }
    if (url!.startsWith('assets/')) {
      return Image.asset(url!, fit: fit);
    }
    if (!url!.startsWith('http://') && !url!.startsWith('https://')) {
      return Image.file(
        File(url!),
        fit: fit,
        errorBuilder: (_, __, ___) => const VitheyIcon(
          LucideIcons.imageOff,
          color: Colors.white54,
          size: 48,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      placeholder: (_, __) => const Center(
        child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
      ),
      errorWidget: (_, __, ___) => const VitheyIcon(
        LucideIcons.imageOff,
        color: Colors.white54,
        size: 48,
      ),
    );
  }
}
