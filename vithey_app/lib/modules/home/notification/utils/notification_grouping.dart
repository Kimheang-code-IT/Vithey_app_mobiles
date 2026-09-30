import 'package:aub_connect_app/data/models/app_notification_model.dart';

class NotificationSection {
  const NotificationSection({required this.title, required this.items});

  final String title;
  final List<AppNotification> items;
}

/// Groups notifications by their local calendar day.
List<NotificationSection> groupNotifications(
  List<AppNotification> notifications, {
  DateTime? now,
}) {
  if (notifications.isEmpty) return [];

  final localNow = (now ?? DateTime.now()).toLocal();
  final todayStart = DateTime(localNow.year, localNow.month, localNow.day);
  final yesterdayStart = todayStart.subtract(const Duration(days: 1));
  final lastWeekStart = todayStart.subtract(const Duration(days: 7));

  final todayItems = <AppNotification>[];
  final yesterdayItems = <AppNotification>[];
  final lastWeekItems = <AppNotification>[];
  final earlierItems = <AppNotification>[];

  for (final notification in notifications) {
    final createdAt = notification.createdAt.toLocal();
    final day = DateTime(
      createdAt.year,
      createdAt.month,
      createdAt.day,
    );
    if (!day.isBefore(todayStart)) {
      todayItems.add(notification);
    } else if (!day.isBefore(yesterdayStart)) {
      yesterdayItems.add(notification);
    } else if (!day.isBefore(lastWeekStart)) {
      lastWeekItems.add(notification);
    } else {
      earlierItems.add(notification);
    }
  }

  final sections = <NotificationSection>[];
  if (todayItems.isNotEmpty) {
    sections.add(NotificationSection(title: 'Today', items: todayItems));
  }
  if (yesterdayItems.isNotEmpty) {
    sections
        .add(NotificationSection(title: 'Yesterday', items: yesterdayItems));
  }
  if (lastWeekItems.isNotEmpty) {
    sections.add(NotificationSection(title: 'Last week', items: lastWeekItems));
  }
  if (earlierItems.isNotEmpty) {
    sections.add(NotificationSection(title: 'Earlier', items: earlierItems));
  }
  return sections;
}
