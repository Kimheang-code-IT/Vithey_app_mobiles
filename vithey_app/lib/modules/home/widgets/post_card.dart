import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/widgets/feed_action_bar.dart';
import 'package:aub_connect_app/modules/home/widgets/post_author_header.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.headerTrailing,
    this.body,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onBodyTap,
    this.onReact,
    this.onAuthorTap,
    this.caption,
    this.margin = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.showShareAction = true,
  });

  final FeedPost post;
  final Widget? headerTrailing;
  final Widget? body;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onBodyTap;
  final ValueChanged<PostReactionType>? onReact;
  final VoidCallback? onAuthorTap;
  final Widget? caption;
  final EdgeInsetsGeometry margin;
  final bool showShareAction;

  @override
  Widget build(BuildContext context) {
    return VitheyCard(
      padding: EdgeInsets.zero,
      margin: margin,
      bordered: true,
      elevated: false,
      borderRadius: VitheyRadii.card,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostAuthorHeader(
              post: post, trailing: headerTrailing, onAuthorTap: onAuthorTap),
          if (caption != null)
            caption!
          else if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(
                post.content,
                style: context.text.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
          if (body != null) GestureDetector(onTap: onBodyTap, child: body),
          FeedActionBar(
            post: post,
            onLike: onLike,
            onComment: onComment,
            onShare: onShare,
            onReact: onReact,
            showShareAction: showShareAction,
          ),
        ],
      ),
    );
  }
}

class PostMediaImage extends StatelessWidget {
  const PostMediaImage({super.key, this.url, this.height});

  final String? url;
  final double? height;

  bool get _isLocalFile {
    final value = url;
    if (value == null || value.isEmpty) return false;
    return !value.startsWith('http://') && !value.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return const SizedBox.shrink();

    final Widget media;
    if (_isLocalFile) {
      media = Image.file(
        File(url!),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: context.appColors.inputFill,
          alignment: Alignment.center,
          child: const VitheyIcon(LucideIcons.imageOff),
        ),
      );
    } else {
      media = CachedNetworkImage(
        imageUrl: url!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => ColoredBox(
          color: context.appColors.inputFill,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: context.appColors.inputFill,
          alignment: Alignment.center,
          child: const VitheyIcon(LucideIcons.imageOff),
        ),
      );
    }

    if (height != null) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: media,
      );
    }
    return AspectRatio(
      aspectRatio: 1.04,
      child: ColoredBox(
        color: context.appColors.inputFill,
        child: media,
      ),
    );
  }
}
