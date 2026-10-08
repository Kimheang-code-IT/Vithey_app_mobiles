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
      title: 'settings'.tr,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 8),
          children: [
            SettingsSectionLabel(label: 'preferences'.tr),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: LucideIcons.user,
                  label: 'account'.tr,
                  onTap: () => Get.toNamed(AppRoutes.settingsAccount),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.lock,
                  label: 'privacy'.tr,
                  onTap: () => Get.toNamed(AppRoutes.settingsPrivacy),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.languages,
                  label: 'language'.tr,
                  subtitle: controller.languageLabel,
                  onTap: controller.openLanguagePicker,
                ),
              ],
            ),
            SettingsSectionLabel(label: 'system'.tr),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: LucideIcons.bell,
                  label: 'notifications'.tr,
                  onTap: () => Get.toNamed(AppRoutes.settingsNotifications),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.shield,
                  label: 'security'.tr,
                  onTap: () => Get.toNamed(AppRoutes.settingsSecurity),
                ),
                SettingsSwitchTile(
                  icon: LucideIcons.moon,
                  label: 'dark_mode'.tr,
                  value: controller.isDarkMode.value,
                  onChanged: controller.toggleDarkMode,
                ),
              ],
            ),
            SettingsSectionLabel(label: 'support'.tr),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: LucideIcons.circleHelp,
                  label: 'help_center'.tr,
                  onTap: () => Get.toNamed(AppRoutes.settingsHelpCenter),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.info,
                  label: 'about'.tr,
                  onTap: () => Get.toNamed(AppRoutes.settingsAbout),
                ),
              ],
            ),
            SettingsSectionLabel(label: 'general'.tr),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: LucideIcons.database,
                  label: 'data_storage'.tr,
                  onTap: () => Get.snackbar(
                    'settings'.tr,
                    'Data & storage is coming soon',
                  ),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.accessibility,
                  label: 'accessibility'.tr,
                  onTap: () => Get.snackbar(
                    'settings'.tr,
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
