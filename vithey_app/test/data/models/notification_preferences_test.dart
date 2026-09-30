import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/data/models/settings_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('master switch off blocks every notification type', () {
    const preferences = NotificationPreferences(allowNotifications: false);

    for (final type in NotificationType.values) {
      expect(preferences.allowsType(type), isFalse, reason: '$type');
    }
  });

  test('chat toggle gates chat messages and chat requests', () {
    const preferences = NotificationPreferences(chatMessages: false);

    expect(preferences.allowsType(NotificationType.chatMessage), isFalse);
    expect(preferences.allowsType(NotificationType.chatRequest), isFalse);
    expect(preferences.allowsType(NotificationType.postLike), isTrue);
  });

  test('reminders toggle gates payment alerts', () {
    const preferences = NotificationPreferences(reminders: false);

    expect(preferences.allowsType(NotificationType.paymentDue), isFalse);
    expect(preferences.allowsType(NotificationType.paymentOverdue), isFalse);
    expect(preferences.allowsType(NotificationType.chatMessage), isTrue);
  });

  test('system notifications follow announcements or app updates toggle', () {
    const preferences = NotificationPreferences(
      announcements: false,
      appUpdates: true,
    );

    expect(preferences.allowsType(NotificationType.system), isFalse);
    expect(
      preferences.allowsType(
        NotificationType.system,
        event: 'system.app_update',
      ),
      isTrue,
    );

    const updatesOff = NotificationPreferences(
      announcements: true,
      appUpdates: false,
    );
    expect(updatesOff.allowsType(NotificationType.system), isTrue);
    expect(
      updatesOff.allowsType(
        NotificationType.system,
        event: 'system.app_update',
      ),
      isFalse,
    );
  });

  test('social and job activity is gated by the master switch only', () {
    const preferences = NotificationPreferences(
      chatMessages: false,
      reminders: false,
      announcements: false,
      appUpdates: false,
    );

    expect(preferences.allowsType(NotificationType.postComment), isTrue);
    expect(preferences.allowsType(NotificationType.newFollower), isTrue);
    expect(
      preferences.allowsType(NotificationType.jobApplicationReceived),
      isTrue,
    );
    expect(
      preferences.allowsType(NotificationType.aiAssistantResponse),
      isTrue,
    );
  });
}
