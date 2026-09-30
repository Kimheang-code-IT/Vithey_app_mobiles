import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/widgets/post_owner_actions.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ProfileJobCard extends StatelessWidget {
  const ProfileJobCard({
    super.key,
    required this.post,
    required this.isOwnProfile,
    required this.onOpenApplicants,
    required this.onApply,
    required this.onOpenPost,
    this.onEdit,
    this.onDelete,
  });

  final FeedPost post;
  final bool isOwnProfile;
  final VoidCallback onOpenApplicants;
  final VoidCallback onApply;
  final VoidCallback onOpenPost;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  void _openPosterPreview(BuildContext context) {
    final url = post.mediaUrl;
    if (url == null || url.isEmpty) return;
    final title = post.jobMeta.title ?? 'Job opening';
    final company = post.jobMeta.description ?? post.author.fullName;
    final employment = post.jobMeta.requirement ?? 'Full-time';
    final location =
        post.content.isNotEmpty ? post.content.split('\n').first : 'Phnom Penh';

    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (ctx, _, __) => _JobPosterFullscreen(
          imageUrl: url,
          title: title,
          companyLine: '$company ( $employment )',
          location: location,
          postedAt: RelativeTime.format(post.createdAt),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = post.jobMeta.title ?? 'Job opening';
    final company = post.jobMeta.description ?? post.author.fullName;
    final employment = post.jobMeta.requirement ?? 'Full-time';
    final location =
        post.content.isNotEmpty ? post.content.split('\n').first : 'Phnom Penh';

    return VitheyCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(vertical: 8),
      bordered: true,
      elevated: false,
      borderRadius: VitheyRadii.card,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _openPosterPreview(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(VitheyRadii.media),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: _PosterImage(
                            url: post.mediaUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 72,
                      child: Text(
                        RelativeTime.format(post.createdAt),
                        textAlign: TextAlign.start,
                        style: context.text.labelSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: isOwnProfile ? onOpenApplicants : onOpenPost,
                    borderRadius: BorderRadius.circular(VitheyRadii.field),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: context.text.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$company ( $employment )',
                            style: context.text.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              VitheyIcon(
                                LucideIcons.mapPin,
                                size: 14,
                                color: context.appColors.muted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.labelMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isOwnProfile && onEdit != null && onDelete != null)
                  PostOwnerActions(
                    onEdit: onEdit!,
                    onDelete: onDelete!,
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: context.appColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: isOwnProfile
                ? Row(
                    children: [
                      InkWell(
                        onTap: onOpenApplicants,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${post.applicantCount} Application',
                            style: context.text.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onOpenApplicants,
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          'View List >',
                          style: context.text.labelLarge?.copyWith(
                            color: context.appColors.muted,
                          ),
                        ),
                      ),
                    ],
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: post.applicationState == JobApplicationState.applied
                        ? Text(
                            'Applied',
                            style: context.text.labelLarge?.copyWith(
                              color: context.appColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : CustomButton(
                            label: 'Apply',
                            onPressed: onApply,
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Fullscreen poster: image centered; job details float from the bottom.
class _JobPosterFullscreen extends StatelessWidget {
  const _JobPosterFullscreen({
    required this.imageUrl,
    required this.title,
    required this.companyLine,
    required this.location,
    required this.postedAt,
  });

  final String imageUrl;
  final String title;
  final String companyLine;
  final String location;
  final String postedAt;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: Center(
              child: _PosterImage(url: imageUrl, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: topInset + 4,
            right: 4,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
              icon: const VitheyIcon(LucideIcons.x),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 16 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: context.text.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      companyLine,
                      style: context.text.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        VitheyIcon(
                          LucideIcons.mapPin,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            location,
                            style: context.text.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      postedAt,
                      style: context.text.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.url, required this.fit});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return ColoredBox(
        color: context.appColors.inputFill,
        child: const VitheyIcon(LucideIcons.briefcase),
      );
    }
    if (url!.startsWith('assets/')) {
      return Image.asset(url!, fit: fit);
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      placeholder: (_, __) => ColoredBox(color: context.appColors.inputFill),
      errorWidget: (_, __, ___) => ColoredBox(
        color: context.appColors.inputFill,
        child: const VitheyIcon(LucideIcons.imageOff),
      ),
    );
  }
}
