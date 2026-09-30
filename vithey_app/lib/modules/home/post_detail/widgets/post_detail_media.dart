import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class PostDetailMedia extends StatefulWidget {
  const PostDetailMedia({super.key, required this.post});

  final FeedPost post;

  @override
  State<PostDetailMedia> createState() => _PostDetailMediaState();
}

class _PostDetailMediaState extends State<PostDetailMedia> {
  VideoPlayerController? _controller;
  bool _initializing = false;
  String? _error;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    if (_controller != null || _initializing) return;
    final url = widget.post.mediaUrl;
    if (url == null || url.isEmpty) return;

    setState(() {
      _initializing = true;
      _error = null;
    });

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
      });
      await controller.play();
    } catch (e) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error = 'Could not play video';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.post.type) {
      case PostType.poster:
      case PostType.job:
        return _buildImage(widget.post.mediaUrl);
      case PostType.video:
        return _buildVideo();
    }
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return _placeholder();
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      fit: BoxFit.contain,
      placeholder: (_, __) => _placeholder(loading: true),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _buildVideo() {
    if (_controller != null && _controller!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller!),
            IconButton(
              iconSize: 56,
              color: Colors.white70,
              icon: VitheyIcon(_controller!.value.isPlaying
                  ? LucideIcons.circlePause
                  : LucideIcons.circlePlay),
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _initPlayer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildImage(widget.post.thumbnailUrl ?? widget.post.mediaUrl),
          if (_initializing)
            const CircularProgressIndicator(color: Colors.white)
          else
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: context.scheme.onSurfaceVariant,
                  shape: BoxShape.circle),
              child:
                  const VitheyIcon(LucideIcons.play, color: Colors.white, size: 40),
            ),
          if (_error != null)
            Positioned(
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: context.scheme.onSurfaceVariant,
                child:
                    Text(_error!, style: const TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      height: 240,
      color: context.appColors.inputFill,
      alignment: Alignment.center,
      child: loading
          ? const CircularProgressIndicator(strokeWidth: 2)
          : const VitheyIcon(LucideIcons.imageOff),
    );
  }
}
