import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:intl/intl.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ChatSharedTabs extends StatelessWidget {
  const ChatSharedTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  static const tabs = [
    AppStrings.chatMedias,
    AppStrings.chatVideos,
    AppStrings.chatFiles,
    AppStrings.chatLinks,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (index) {
        final active = index == selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTabSelected(index),
            child: Column(
              children: [
                Text(
                  tabs[index],
                  style: context.text.bodyMedium?.copyWith(
                    fontWeight: active
                        ? VitheyWeight.semibold
                        : VitheyWeight.regular,
                    color:
                        active ? AppColors.primary : context.appColors.muted,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  color: active ? AppColors.primary : Colors.transparent,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class SharedMediaGrid extends StatelessWidget {
  const SharedMediaGrid({
    super.key,
    this.itemCount = 0,
    this.imageUrls = const [],
  });

  final int itemCount;
  final List<String> imageUrls;

  int get _count => imageUrls.isNotEmpty ? imageUrls.length : itemCount;

  @override
  Widget build(BuildContext context) {
    if (_count == 0) {
      return const EmptyStateWidget(
        icon: LucideIcons.image,
        title: AppStrings.chatNoSharedMedia,
        subtitle: AppStrings.chatNoSharedMediaSubtitle,
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _count,
      itemBuilder: (_, index) {
        final url = imageUrls.isNotEmpty ? imageUrls[index] : null;
        return Container(
          decoration: BoxDecoration(
            color: context.appColors.inputFill,
            borderRadius: BorderRadius.circular(VitheyRadii.media),
          ),
          clipBehavior: Clip.antiAlias,
          child: url == null
              ? VitheyIcon(LucideIcons.image, color: context.appColors.muted)
              : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
        );
      },
    );
  }
}

class SharedVideoGrid extends StatelessWidget {
  const SharedVideoGrid({
    super.key,
    this.itemCount = 0,
    this.videoUrls = const [],
  });

  final int itemCount;
  final List<String> videoUrls;

  int get _count => videoUrls.isNotEmpty ? videoUrls.length : itemCount;

  @override
  Widget build(BuildContext context) {
    if (_count == 0) {
      return const EmptyStateWidget(
        icon: LucideIcons.video,
        title: AppStrings.chatNoSharedMedia,
        subtitle: AppStrings.chatNoSharedMediaSubtitle,
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _count,
      itemBuilder: (_, index) {
        final url = videoUrls.isNotEmpty ? videoUrls[index] : null;
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.appColors.inputFill,
                borderRadius: BorderRadius.circular(VitheyRadii.media),
              ),
              clipBehavior: Clip.antiAlias,
              child: url == null
                  ? null
                  : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
            ),
            Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                    color: Colors.white70, shape: BoxShape.circle),
                child: const VitheyIcon(LucideIcons.play, color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SharedFileTile extends StatelessWidget {
  const SharedFileTile({
    super.key,
    required this.fileName,
    required this.sizeLabel,
    required this.dateLabel,
  });

  final String fileName;
  final String sizeLabel;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        children: [
          const VitheyIcon(LucideIcons.fileText, color: AppColors.error, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName, style: context.text.labelLarge),
                const SizedBox(height: 2),
                Text(
                  '$sizeLabel, $dateLabel',
                  style: context.text.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SharedFilesList extends StatelessWidget {
  const SharedFilesList({super.key, required this.files});

  final List<({String name, String size, DateTime date})> files;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const EmptyStateWidget(
        icon: LucideIcons.fileText,
        title: AppStrings.chatNoSharedFiles,
        subtitle: AppStrings.chatNoSharedMediaSubtitle,
      );
    }
    final format = DateFormat('dd.MM.yy \'at\' h:mma');
    return Column(
      children: files
          .map(
            (f) => SharedFileTile(
              fileName: f.name,
              sizeLabel: f.size,
              dateLabel: format.format(f.date),
            ),
          )
          .toList(),
    );
  }
}

class SharedLinkTile extends StatelessWidget {
  const SharedLinkTile({
    super.key,
    required this.title,
    required this.description,
    required this.url,
  });

  final String title;
  final String description;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.appColors.inputFill,
              shape: BoxShape.circle,
            ),
            child: const VitheyIcon(LucideIcons.link, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.labelLarge),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.text.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  url,
                  style: context.text.bodySmall
                      ?.copyWith(color: AppColors.info),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SharedLinksList extends StatelessWidget {
  const SharedLinksList({super.key, required this.links});

  final List<({String month, String title, String description, String url})>
      links;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      return const EmptyStateWidget(
        icon: LucideIcons.link,
        title: AppStrings.chatNoSharedLinks,
        subtitle: AppStrings.chatNoSharedMediaSubtitle,
      );
    }
    final grouped =
        <String, List<({String title, String description, String url})>>{};
    for (final link in links) {
      grouped.putIfAbsent(link.month, () => []).add(
        (title: link.title, description: link.description, url: link.url),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(
              entry.key,
              style: context.text.bodySmall,
            ),
          ),
          for (final item in entry.value)
            SharedLinkTile(
              title: item.title,
              description: item.description,
              url: item.url,
            ),
        ],
      ],
    );
  }
}

class ChatQuickActionsRow extends StatelessWidget {
  const ChatQuickActionsRow({
    super.key,
    required this.onProfile,
    required this.onCall,
    required this.onVideo,
    required this.onMute,
    this.onCallLongPress,
    this.onVideoLongPress,
    this.isMuted = false,
  });

  final VoidCallback onProfile;
  final VoidCallback onCall;
  final VoidCallback onVideo;
  final VoidCallback onMute;
  final VoidCallback? onCallLongPress;
  final VoidCallback? onVideoLongPress;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: context.appColors.subtleShadow,
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionItem(
            icon: LucideIcons.user,
            label: AppStrings.chatProfileAction,
            onTap: onProfile,
          ),
          _ActionItem(
            icon: LucideIcons.phone,
            label: AppStrings.chatCallAction,
            onTap: onCall,
            onLongPress: onCallLongPress,
          ),
          _ActionItem(
            icon: LucideIcons.video,
            label: AppStrings.chatVideoAction,
            onTap: onVideo,
            onLongPress: onVideoLongPress,
          ),
          _ActionItem(
            icon: isMuted
                ? LucideIcons.bellOff
                : LucideIcons.bell,
            label: isMuted
                ? AppStrings.chatUnmuteAction
                : AppStrings.chatMuteAction,
            onTap: onMute,
            highlighted: isMuted,
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final iconColor = highlighted ? AppColors.error : AppColors.primary;
    // Unified primary wash fill; muted state speaks via the error icon only.
    const bgColor = AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: VitheyIcon(icon, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: context.text.labelMedium,
          ),
        ],
      ),
    );
  }
}

class ChatContactInfoCard extends StatelessWidget {
  const ChatContactInfoCard({
    super.key,
    this.phone,
    this.bio,
  });

  final String? phone;
  final String? bio;

  @override
  Widget build(BuildContext context) {
    if ((phone == null || phone!.isEmpty) && (bio == null || bio!.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.inputFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (phone != null && phone!.isNotEmpty)
            _InfoRow(
              icon: LucideIcons.phone,
              value: phone!,
              label: AppStrings.chatMobile,
            ),
          if (phone != null &&
              phone!.isNotEmpty &&
              bio != null &&
              bio!.isNotEmpty)
            const SizedBox(height: 14),
          if (bio != null && bio!.isNotEmpty)
            _InfoRow(
              icon: LucideIcons.info,
              value: bio!,
              label: AppStrings.chatBio,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VitheyIcon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: context.text.labelLarge),
              const SizedBox(height: 2),
              Text(label, style: context.text.labelMedium),
            ],
          ),
        ),
      ],
    );
  }
}
