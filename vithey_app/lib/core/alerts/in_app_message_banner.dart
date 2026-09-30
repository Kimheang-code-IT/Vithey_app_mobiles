import 'package:aub_connect_app/core/alerts/in_app_alert.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// iOS/Android-style chat message heads-up banner.
class InAppMessageBanner extends StatelessWidget {
  const InAppMessageBanner({
    super.key,
    required this.alert,
    required this.onTap,
    required this.onDismiss,
  });

  final InAppAlert alert;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF3A3A3C) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF111111);
    final bodyColor = isDark ? const Color(0xFFD1D1D6) : const Color(0xFF3C3C43);
    final timeColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Dismissible(
          key: ValueKey(alert.id),
          direction: DismissDirection.up,
          onDismissed: (_) => onDismiss(),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AppBadge(isDark: isDark),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                alert.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodyMedium?.copyWith(
                                  fontWeight: VitheyWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _relative(alert.createdAt),
                              style: context.text.labelMedium
                                  ?.copyWith(color: timeColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                alert.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodySmall?.copyWith(
                                  color: bodyColor,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            if (alert.thumbnailUrl != null &&
                                alert.thumbnailUrl!.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              _Thumb(url: alert.thumbnailUrl!),
                            ] else if (alert.avatarUrl != null &&
                                alert.avatarUrl!.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              UserAvatar(
                                imageUrl: alert.avatarUrl,
                                name: alert.title,
                                radius: 16,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _relative(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt.toLocal());
    if (diff.inSeconds < 45) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _AppBadge extends StatelessWidget {
  const _AppBadge({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        color: isDark
            ? const Color(0xFF2C2C2E)
            : Theme.of(context).colorScheme.primary,
        alignment: Alignment.center,
        child: Image.asset(
          AppAssets.logoApp,
          width: 22,
          height: 22,
          errorBuilder: (_, __, ___) => VitheyIcon(
            LucideIcons.messageCircle,
            size: 18,
            color: isDark ? Colors.white : context.scheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => Container(
          width: 36,
          height: 36,
          color: context.appColors.inputFill,
          child: VitheyIcon(LucideIcons.image, size: 16, color: context.appColors.muted),
        ),
      ),
    );
  }
}
