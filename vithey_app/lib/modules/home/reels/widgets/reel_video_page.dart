import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/core/widgets/vithey_action_sheet.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
/// One Facebook/TikTok-style reel page inside a vertical PageView.
class ReelVideoPage extends StatefulWidget {
  const ReelVideoPage({
    super.key,
    required this.post,
    required this.isActive,
    required this.muted,
    required this.onToggleMute,
    required this.onLike,
    required this.onComment,
    required this.onAuthorTap,
    this.bottomInset = 0,
  });

  final FeedPost post;
  final bool isActive;
  final bool muted;
  final VoidCallback onToggleMute;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onAuthorTap;
  final double bottomInset;

  @override
  State<ReelVideoPage> createState() => _ReelVideoPageState();
}

class _ReelVideoPageState extends State<ReelVideoPage> {
  VideoPlayerController? _controller;
  bool _initializing = false;
  bool _showControls = true;
  bool _captionExpanded = false;
  bool _saved = false;
  String? _error;
  late FeedPost _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initPlayer());
    }
  }

  @override
  void didUpdateWidget(covariant ReelVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _disposePlayer();
      _post = widget.post;
      _captionExpanded = false;
      _saved = false;
      if (widget.isActive) _initPlayer();
    } else {
      _post = widget.post;
    }

    if (widget.isActive && !oldWidget.isActive) {
      _initPlayer().then((_) => _play());
    } else if (!widget.isActive && oldWidget.isActive) {
      _pause();
    }

    if (widget.muted != oldWidget.muted) {
      _controller?.setVolume(widget.muted ? 0 : 1);
    }
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  void _disposePlayer() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    _controller = null;
  }

  void _onTick() {
    if (mounted) setState(() {});
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
      controller.addListener(_onTick);
      await controller.setLooping(true);
      await controller.setVolume(widget.muted ? 0 : 1);
      setState(() {
        _controller = controller;
        _initializing = false;
      });
      if (widget.isActive) await controller.play();
    } catch (_) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error = 'Could not play video';
        });
      }
    }
  }

  Future<void> _play() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      await _initPlayer();
      return;
    }
    await c.play();
  }

  Future<void> _pause() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    await c.pause();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
        _showControls = true;
      } else {
        c.play();
        _showControls = true;
      }
    });
  }

  void _seekBy(Duration delta) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    final next = c.value.position + delta;
    final end = c.value.duration;
    final clamped =
        next < Duration.zero ? Duration.zero : (next > end ? end : next);
    c.seekTo(clamped);
  }

  void _toggleLike() {
    widget.onLike();
    setState(() {
      final liked = !_post.userReacted;
      _post = _post.copyWith(
        userReacted: liked,
        reactionCount:
            (_post.reactionCount + (liked ? 1 : -1)).clamp(0, 1 << 30),
      );
    });
  }

  void _onShare() {
    final text = _post.content.trim().isNotEmpty
        ? _post.content.trim()
        : 'Check this reel on Vithey';
    Share.share(text);
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    if (h > 0) return '$h:${m.padLeft(2, '0')}:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = 12.0 + widget.bottomInset;
    final c = _controller;
    final ready = c != null && c.value.isInitialized;
    final playing = ready && c.value.isPlaying;
    final position = ready ? c.value.position : Duration.zero;
    final duration = ready ? c.value.duration : Duration.zero;
    final progress = duration.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video stage
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (!ready) return;
                setState(() => _showControls = !_showControls);
                if (playing) {
                  // brief show then hide while playing
                }
              },
              onDoubleTap: _toggleLike,
              child: _buildStage(ready, c),
            ),
          ),

          // Center playback controls
          if (_showControls && ready)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RoundControl(
                    icon: LucideIcons.rotateCcw,
                    onTap: () => _seekBy(const Duration(seconds: -10)),
                  ),
                  const SizedBox(width: 28),
                  _RoundControl(
                    icon: playing
                        ? LucideIcons.pause
                        : LucideIcons.play,
                    size: 34,
                    onTap: _togglePlay,
                  ),
                  const SizedBox(width: 28),
                  _RoundControl(
                    icon: LucideIcons.rotateCw,
                    onTap: () => _seekBy(const Duration(seconds: 10)),
                  ),
                ],
              ),
            ),

          // Right action rail (above bottom meta so it doesn't sit on the seek bar)
          Positioned(
            right: 8,
            bottom: 168 + bottomPad,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SideAction(
                  icon: _post.userReacted
                      ? LucideIcons.thumbsUp
                      : LucideIcons.thumbsUp,
                  label: _formatCount(_post.reactionCount),
                  active: _post.userReacted,
                  onTap: _toggleLike,
                ),
                const SizedBox(height: 16),
                _SideAction(
                  icon: LucideIcons.messageCircle,
                  label: _formatCount(_post.commentCount),
                  onTap: widget.onComment,
                ),
                const SizedBox(height: 16),
                _SideAction(
                  icon: LucideIcons.share2,
                  label: _formatCount(_post.shareCount),
                  onTap: _onShare,
                ),
                const SizedBox(height: 16),
                _SideAction(
                  icon: _saved
                      ? LucideIcons.bookmark
                      : LucideIcons.bookmark,
                  label: _formatCount(487),
                  active: _saved,
                  onTap: () => setState(() => _saved = !_saved),
                ),
                const SizedBox(height: 16),
                _SideAction(
                  icon: LucideIcons.ellipsis,
                  onTap: () => _showMoreSheet(context),
                ),
              ],
            ),
          ),

          // Bottom meta + progress — full width edge-to-edge
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(12, 40, 12, bottomPad),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: widget.onAuthorTap,
                    child: Row(
                      children: [
                        UserAvatar(
                          name: _post.author.fullName,
                          imageUrl: _post.author.avatarUrl,
                          radius: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _post.author.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        VitheyIcon(
                          LucideIcons.globe,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ],
                    ),
                  ),
                  if (_post.content.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(
                        () => _captionExpanded = !_captionExpanded,
                      ),
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 13,
                            height: 1.35,
                          ),
                          children: [
                            TextSpan(
                              text: _captionExpanded ||
                                      _post.content.length <= 80
                                  ? _post.content
                                  : '${_post.content.substring(0, 80).trimRight()}…',
                            ),
                            if (!_captionExpanded && _post.content.length > 80)
                              const TextSpan(
                                text: ' more',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        ready
                            ? '${_format(position)} / ${_format(duration)}'
                            : '0:00 / 0:00',
                        style: context.text.labelMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        onPressed: widget.onToggleMute,
                        icon: VitheyIcon(
                          widget.muted
                              ? LucideIcons.volumeX
                              : LucideIcons.volume2,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.5,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: SliderComponentShape.noOverlay,
                      trackShape: const RectangularSliderTrackShape(),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                      // Kill Material's default side inset so the bar is full width.
                      padding: EdgeInsets.zero,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Slider(
                        value: progress,
                        onChanged: ready
                            ? (v) {
                                final ms =
                                    (duration.inMilliseconds * v).round();
                                c.seekTo(Duration(milliseconds: ms));
                              }
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage(bool ready, VideoPlayerController? c) {
    if (_error != null) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.white70)),
        ),
      );
    }
    if (_initializing || !ready) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (_post.thumbnailUrl != null)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: _post.thumbnailUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          else
            const ColoredBox(color: Colors.black),
          const Center(
            child: CircularProgressIndicator(color: Colors.white70),
          ),
        ],
      );
    }

    // Full-bleed cover (TikTok/IG style) so the action rail sits on the video.
    final size = c!.value.size;
    final w = size.width <= 0 ? 9.0 : size.width;
    final h = size.height <= 0 ? 16.0 : size.height;
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: w,
          height: h,
          child: VideoPlayer(c),
        ),
      ),
    );
  }

  void _showMoreSheet(BuildContext context) {
    showVitheyActionSheet<void>(
      context: context,
      title: 'Reel actions',
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
  }

  static String _formatCount(int n) {
    if (n <= 0) return '';
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.icon,
    required this.onTap,
    this.size = 28,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: VitheyIcon(icon, color: Colors.white, size: size),
        ),
      ),
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
    // 48px circular hit target with a subtle scrim wash.
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VitheyIcon(
              icon,
              color: active ? AppColors.primaryLight : Colors.white,
              size: 27,
              shadows: const [
                Shadow(
                  color: Color(0x99000000),
                  blurRadius: 8,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Color(0x99000000),
                      blurRadius: 8,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
