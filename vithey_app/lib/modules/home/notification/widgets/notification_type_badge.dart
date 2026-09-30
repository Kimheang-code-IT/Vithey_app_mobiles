import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class NotificationTypeBadge extends StatelessWidget {
  const NotificationTypeBadge({super.key, required this.type});

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: colorFor(type),
        shape: BoxShape.circle,
        border: Border.all(
          color: context.appColors.cardSurface,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: context.appColors.subtleShadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: VitheyIcon(iconFor(type), size: 12, color: Colors.white),
    );
  }

  static Color colorFor(NotificationType type) {
    return switch (type) {
      NotificationType.postLike => const Color(0xFFE91E63),
      NotificationType.postComment ||
      NotificationType.postMention =>
        const Color(0xFF2196F3),
      NotificationType.postShare => AppColors.primary,
      NotificationType.newFollower => AppColors.success,
      NotificationType.jobApplicationReceived ||
      NotificationType.jobApplicationStatus =>
        const Color(0xFFFF9800),
      NotificationType.chatRequest ||
      NotificationType.chatMessage =>
        AppColors.primary,
      NotificationType.paymentDue ||
      NotificationType.paymentOverdue =>
        const Color(0xFFFFC107),
      NotificationType.aiAssistantResponse => const Color(0xFF9C27B0),
      NotificationType.studentVerification => AppColors.primary,
      NotificationType.system => AppColors.bodyLight,
    };
  }

  static IconData iconFor(NotificationType type) {
    return switch (type) {
      NotificationType.postLike => LucideIcons.heart,
      NotificationType.postComment ||
      NotificationType.postMention =>
        LucideIcons.messageSquare,
      NotificationType.postShare => LucideIcons.share2,
      NotificationType.newFollower => LucideIcons.userPlus,
      NotificationType.jobApplicationReceived ||
      NotificationType.jobApplicationStatus =>
        LucideIcons.briefcase,
      NotificationType.chatRequest ||
      NotificationType.chatMessage =>
        LucideIcons.messageCircle,
      NotificationType.paymentDue ||
      NotificationType.paymentOverdue =>
        LucideIcons.creditCard,
      NotificationType.aiAssistantResponse => LucideIcons.sparkles,
      NotificationType.studentVerification => LucideIcons.shieldCheck,
      NotificationType.system => LucideIcons.megaphone,
    };
  }
}
