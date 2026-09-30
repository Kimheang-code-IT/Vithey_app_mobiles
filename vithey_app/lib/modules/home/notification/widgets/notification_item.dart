import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/modules/home/notification/utils/notification_display_text.dart';
import 'package:aub_connect_app/modules/home/notification/widgets/notification_type_badge.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMore,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final parts = NotificationDisplayText.parts(notification);
    final radius = BorderRadius.circular(16);

    return Semantics(
      label:
          '${isUnread ? 'Unread. ' : ''}${NotificationDisplayText.build(notification)}',
      button: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: context.appColors.subtleShadow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Material(
            color: context.appColors.cardSurface,
            child: InkWell(
              onTap: onTap,
              // Fixed height so every notification card is the same size.
              child: SizedBox(
                height: 78,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Accent tab: unread only — flush against the card's
                    // left edge, rounded on the right side only, ~60% of
                    // the card height and vertically centered. The cell
                    // keeps its width when read so the layout doesn't shift.
                    SizedBox(
                      width: 4,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        opacity: isUnread ? 1 : 0,
                        child: Center(
                          child: FractionallySizedBox(
                            heightFactor: 0.6,
                            child: Container(
                              decoration: BoxDecoration(
                                color: context.scheme.primary,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 4, 0),
                        child: Row(
                          children: [
                            if (notification.actor != null)
                              UserAvatar(
                                name: notification.actor!.fullName,
                                imageUrl: notification.actor!.avatarUrl,
                                radius: 21,
                              )
                            else
                              CircleAvatar(
                                radius: 21,
                                backgroundColor: context.appColors.inputFill,
                                child: VitheyIcon(
                                  NotificationTypeBadge.iconFor(
                                      notification.type),
                                  color: NotificationTypeBadge.colorFor(
                                      notification.type),
                                  size: 21,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _NotificationText(
                                actorName: parts.actorName,
                                actionText: parts.actionText,
                                isUnread: isUnread,
                                createdAt: notification.createdAt,
                              ),
                            ),
                            VitheyIconButton(
                              icon: LucideIcons.ellipsis,
                              variant: VitheyIconButtonVariant.neutral,
                              tooltip: 'More options',
                              onTap: onMore,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationText extends StatelessWidget {
  const _NotificationText({
    required this.actorName,
    required this.actionText,
    required this.isUnread,
    required this.createdAt,
  });

  final String? actorName;
  final String actionText;
  final bool isUnread;
  final DateTime createdAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (actorName != null) ...[
          Text(
            actorName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          actionText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodySmall?.copyWith(
            color: context.appColors.heading,
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          NotificationDisplayText.formatRelativeTime(createdAt),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodySmall?.copyWith(fontSize: 11.5),
        ),
      ],
    );
  }
}
