import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/modules/home/notification/utils/notification_display_text.dart';
import 'package:aub_connect_app/modules/home/notification/utils/notification_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 7, 15, 17, 30);

  AppNotification notification(String id, DateTime createdAt) {
    return AppNotification(
      id: id,
      type: NotificationType.system,
      title: 'Title',
      body: 'Body',
      destination: const NotificationDestination(),
      createdAt: createdAt,
    );
  }

  test('groups notifications by local calendar day', () {
    final sections = groupNotifications(
      [
        notification('today', DateTime(2026, 7, 15, 9)),
        notification('yesterday', DateTime(2026, 7, 14, 23)),
        notification('week', DateTime(2026, 7, 8, 12)),
        notification('earlier', DateTime(2026, 7, 7, 12)),
      ],
      now: now,
    );

    expect(
      sections.map((section) => section.title),
      ['Today', 'Yesterday', 'Last week', 'Earlier'],
    );
  });

  test('formats compact relative times', () {
    expect(
      NotificationDisplayText.formatRelativeTime(
        now.subtract(const Duration(minutes: 30)),
        now: now,
      ),
      '30min ago',
    );
    expect(
      NotificationDisplayText.formatRelativeTime(
        DateTime(2026, 7, 14, 15, 21),
        now: now,
      ),
      'Yesterday at 3:21 PM',
    );
    expect(
      NotificationDisplayText.formatRelativeTime(
        DateTime(2026, 7, 7, 12),
        now: now,
      ),
      '8 days ago',
    );
  });
}
