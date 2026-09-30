import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/notification_preferences/notification_preferences_controller.dart';
import 'package:aub_connect_app/modules/settings/notification_preferences/widgets/notification_master_card.dart';
import 'package:aub_connect_app/modules/settings/notification_preferences/widgets/notification_preference_card.dart';
import 'package:aub_connect_app/modules/settings/notification_preferences/widgets/notification_preference_tile.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_tile_divider.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class NotificationPreferencesScreen
    extends GetView<NotificationPreferencesController> {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Notifications',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final settings = controller.preferences.value;
        final categoriesEnabled = controller.categoriesEnabled;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          children: [
            NotificationMasterCard(
              value: settings.allowNotifications,
              onChanged: controller.toggleAllowNotifications,
            ),
            const _SectionLabel('ACTIVITY'),
            NotificationPreferenceCard(
              children: [
                NotificationPreferenceTile(
                  icon: LucideIcons.messageCircle,
                  title: 'Chat Messages',
                  subtitle: 'Replies and new conversations',
                  value: settings.chatMessages,
                  enabled: categoriesEnabled,
                  onChanged: controller.toggleChatMessages,
                ),
                const SettingsTileDivider(),
                NotificationPreferenceTile(
                  icon: LucideIcons.clock,
                  title: 'Reminders',
                  subtitle: 'Study sessions and due dates',
                  value: settings.reminders,
                  enabled: categoriesEnabled,
                  onChanged: controller.toggleReminders,
                ),
              ],
            ),
            const _SectionLabel('FROM VITHEY'),
            NotificationPreferenceCard(
              children: [
                NotificationPreferenceTile(
                  icon: LucideIcons.megaphone,
                  title: 'Announcements',
                  subtitle: 'News and important updates',
                  value: settings.announcements,
                  enabled: categoriesEnabled,
                  onChanged: controller.toggleAnnouncements,
                ),
                const SettingsTileDivider(),
                NotificationPreferenceTile(
                  icon: LucideIcons.bookOpen,
                  title: 'App Updates',
                  subtitle: 'New features and improvements',
                  value: settings.appUpdates,
                  enabled: categoriesEnabled,
                  onChanged: controller.toggleAppUpdates,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
      child: Text(
        label,
        style: context.text.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
