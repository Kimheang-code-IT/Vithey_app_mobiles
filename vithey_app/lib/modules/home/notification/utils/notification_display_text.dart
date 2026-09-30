import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:intl/intl.dart';

/// Builds human-readable notification copy with actor emphasis support.
class NotificationDisplayText {
  static String formatRelativeTime(DateTime createdAt, {DateTime? now}) {
    final localCreatedAt = createdAt.toLocal();
    final localNow = (now ?? DateTime.now()).toLocal();
    final difference = localNow.difference(localCreatedAt);
    final safeDifference = difference.isNegative ? Duration.zero : difference;
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final createdDay = DateTime(
      localCreatedAt.year,
      localCreatedAt.month,
      localCreatedAt.day,
    );
    final calendarDays = today.difference(createdDay).inDays;

    if (calendarDays == 0) {
      if (safeDifference.inMinutes < 1) return 'Just now';
      if (safeDifference.inMinutes < 60) {
        return '${safeDifference.inMinutes}min ago';
      }
      return '${safeDifference.inHours}h ago';
    }
    if (calendarDays == 1) {
      return 'Yesterday at ${DateFormat('h:mm a').format(localCreatedAt)}';
    }
    if (calendarDays <= 14) return '$calendarDays days ago';
    return DateFormat('MMM d').format(localCreatedAt);
  }

  static String build(AppNotification notification) {
    final actor = notification.actor?.fullName;
    if (actor != null && actor.isNotEmpty) {
      return switch (notification.type) {
        NotificationType.postLike => '$actor liked your post.',
        NotificationType.postComment => '$actor commented on your post.',
        NotificationType.postMention => '$actor mentioned you in a comment.',
        NotificationType.postShare => '$actor shared your post.',
        NotificationType.newFollower => '$actor started following you.',
        NotificationType.chatMessage => '$actor sent you a message.',
        NotificationType.chatRequest => '$actor sent you a message request.',
        NotificationType.jobApplicationReceived =>
          '$actor applied for a job you posted.',
        _ =>
          notification.body.isNotEmpty ? notification.body : notification.title,
      };
    }
    return switch (notification.type) {
      NotificationType.jobApplicationStatus => notification.body.isNotEmpty
          ? notification.body
          : 'Your job application status was updated.',
      NotificationType.paymentDue => notification.body.isNotEmpty
          ? notification.body
          : 'You have a payment due soon.',
      NotificationType.paymentOverdue => notification.body.isNotEmpty
          ? notification.body
          : 'You have an overdue payment.',
      NotificationType.aiAssistantResponse =>
        'Vithey AI finished your request.',
      NotificationType.studentVerification => notification.body.isNotEmpty
          ? notification.body
          : 'Your student verification status changed.',
      NotificationType.system =>
        notification.body.isNotEmpty ? notification.body : notification.title,
      _ =>
        notification.body.isNotEmpty ? notification.body : notification.title,
    };
  }

  /// Splits display text into bold actor prefix + regular suffix for Facebook-style rows.
  static ({String? actorName, String actionText}) parts(
      AppNotification notification) {
    final actor = notification.actor?.fullName;
    if (actor == null || actor.isEmpty) {
      return (actorName: null, actionText: build(notification));
    }
    final full = build(notification);
    if (!full.startsWith(actor)) {
      return (actorName: actor, actionText: full);
    }
    final suffix = full.substring(actor.length).trimLeft();
    return (actorName: actor, actionText: suffix.isEmpty ? full : suffix);
  }
}
