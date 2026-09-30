import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/settings_controller.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_logout_button.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_menu_tile.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_section_label.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_switch_tile.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class SettingsHomeScreen extends GetView<SettingsController> {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Settings',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 8),
          children: [
            const SettingsSectionLabel(label: 'Preferences'),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: LucideIcons.user,
                  label: 'Account',
                  onTap: () => Get.toNamed(AppRoutes.settingsAccount),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.lock,
                  label: 'Privacy',
                  onTap: () => Get.toNamed(AppRoutes.settingsPrivacy),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.languages,
                  label: 'Language',
                  subtitle: controller.languageLabel,
                  onTap: controller.openLanguagePicker,
                ),
              ],
            ),
            const SettingsSectionLabel(label: 'System'),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: LucideIcons.bell,
                  label: 'Notifications',
                  onTap: () => Get.toNamed(AppRoutes.settingsNotifications),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.shield,
                  label: 'Security',
                  onTap: () => Get.toNamed(AppRoutes.settingsSecurity),
                ),
                SettingsSwitchTile(
                  icon: LucideIcons.moon,
                  label: 'Dark Mode',
                  value: controller.isDarkMode.value,
                  onChanged: controller.toggleDarkMode,
                ),
              ],
            ),
            const SettingsSectionLabel(label: 'Support'),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: LucideIcons.circleHelp,
                  label: 'Help Center',
                  onTap: () => Get.toNamed(AppRoutes.settingsHelpCenter),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.info,
                  label: 'About',
                  onTap: () => Get.toNamed(AppRoutes.settingsAbout),
                ),
              ],
            ),
            const SettingsSectionLabel(label: 'General'),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: LucideIcons.database,
                  label: 'Data & storage',
                  onTap: () => Get.snackbar(
                    'Settings',
                    'Data & storage is coming soon',
                  ),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.accessibility,
                  label: 'Accessibility',
                  onTap: () => Get.snackbar(
                    'Settings',
                    'Accessibility is coming soon',
                  ),
                ),
              ],
            ),
            SettingsLogoutButton(onPressed: controller.logout),
          ],
        );
      }),
    );
  }
}

class _CardGroup extends StatelessWidget {
  const _CardGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cardColor = context.appColors.cardSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(children: children),
        ),
      ),
    );
  }
}
