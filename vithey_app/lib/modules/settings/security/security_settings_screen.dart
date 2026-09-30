import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/security/security_settings_controller.dart';
import 'package:aub_connect_app/modules/settings/security/widgets/security_option_card.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_menu_tile.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_section_label.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_tile_divider.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class SecuritySettingsScreen extends GetView<SecuritySettingsController> {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Security',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          const SettingsSectionLabel(label: 'Authentication'),
          _CardGroup(
            children: [
              SettingsMenuTile(
                icon: LucideIcons.lock,
                label: 'Change Password',
                subtitle: 'Update your account password',
                onTap: controller.openChangePassword,
              ),
              const SettingsTileDivider(),
              Obx(
                () => SecuritySwitchTile(
                  icon: LucideIcons.keyRound,
                  title: 'Two-Factor Authentication',
                  subtitle: 'Coming soon',
                  value: controller.twoFactorEnabled.value,
                  enabled: controller.twoFactorAvailable,
                  onChanged: controller.toggleTwoFactor,
                ),
              ),
              const SettingsTileDivider(),
              Obx(
                () => SecuritySwitchTile(
                  icon: LucideIcons.fingerprint,
                  title: 'Biometric Login',
                  subtitle: 'Coming soon',
                  value: controller.biometricEnabled.value,
                  enabled: controller.biometricAvailable,
                  onChanged: controller.toggleBiometric,
                ),
              ),
            ],
          ),
          const SettingsSectionLabel(label: 'Sessions'),
          _CardGroup(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.smartphone,
                      color: context.scheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Device',
                            style: context.text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Last active: Just now',
                            style: context.text.bodySmall?.copyWith(height: 1.25),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Active',
                        style: context.text.labelMedium?.copyWith(
                          color: context.scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
