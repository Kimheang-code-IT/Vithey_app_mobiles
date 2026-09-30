import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/modules/settings/account/account_settings_controller.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_menu_tile.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_section_label.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

/// Account settings — private personal identity only.
/// Professional fields (skills, bio, work, links) live in Edit Profile.
class AccountSettingsScreen extends GetView<AccountSettingsController> {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Account',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading account...');
        }
        if (controller.hasError.value) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadAccount,
          );
        }
        final profile = controller.profile.value;
        if (profile == null) {
          return const AppErrorWidget(message: 'Account unavailable');
        }

        final colors = context.appColors;
        final cardColor = colors.cardSurface;

        return ListView(
          padding: const EdgeInsets.only(bottom: 8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          UserAvatar(
                            name: profile.fullName,
                            imageUrl: profile.avatarUrl,
                            radius: 44,
                          ),
                          if (controller.isUploadingAvatar.value)
                            const Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Material(
                              color: context.scheme.primary,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: controller.isUploadingAvatar.value
                                    ? null
                                    : controller.changeAvatar,
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(
                                    LucideIcons.camera,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.fullName,
                        style: context.text.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Private account information',
                        style: context.text.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        label: 'Edit personal info',
                        icon: LucideIcons.pencil,
                        variant: CustomButtonVariant.outline,
                        onPressed: controller.openEditInfo,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SettingsSectionLabel(label: 'Personal'),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: LucideIcons.user,
                  label: 'Full name',
                  subtitle: _valueOrNotSet(profile.fullName),
                  showChevron: false,
                ),
                SettingsMenuTile(
                  icon: LucideIcons.mail,
                  label: 'Email',
                  subtitle: _valueOrNotSet(profile.email),
                  showChevron: false,
                ),
                SettingsMenuTile(
                  icon: LucideIcons.phone,
                  label: 'Phone',
                  subtitle: _valueOrNotSet(profile.phone),
                  showChevron: false,
                ),
                SettingsMenuTile(
                  icon: LucideIcons.cake,
                  label: 'Date of birth',
                  subtitle: _valueOrNotSet(
                    controller.formatDateOfBirth(profile.dateOfBirth),
                  ),
                  showChevron: false,
                ),
                SettingsMenuTile(
                  icon: LucideIcons.venusAndMars,
                  label: 'Gender',
                  subtitle: _valueOrNotSet(profile.gender),
                  showChevron: false,
                ),
                SettingsMenuTile(
                  icon: LucideIcons.mapPin,
                  label: 'Location',
                  subtitle: _valueOrNotSet(profile.location),
                  showChevron: false,
                ),
              ],
            ),
            const SettingsSectionLabel(label: 'Verification'),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: LucideIcons.badgeCheck,
                  label: 'Student verification',
                  subtitle: profile.isStudentVerified
                      ? 'Verified student'
                      : 'Not verified',
                  onTap: () => Get.toNamed(AppRoutes.studentVerification),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  static String _valueOrNotSet(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? 'Not set' : trimmed;
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
