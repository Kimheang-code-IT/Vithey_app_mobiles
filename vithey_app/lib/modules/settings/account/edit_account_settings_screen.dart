import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/modules/settings/account/edit_account_settings_controller.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_menu_tile.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_section_label.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

/// Edit private personal fields — Edit Profile style (row → bottom sheet).
/// No inline text fields on the list.
class EditAccountSettingsScreen extends GetView<EditAccountSettingsController> {
  const EditAccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Edit account',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading account...');
        }
        if (controller.hasError.value) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadProfile,
          );
        }
        if (controller.profile.value == null) {
          return const AppErrorWidget(message: 'Account unavailable');
        }

        final colors = context.appColors;
        final cardColor = colors.cardSurface;
        final dob = controller.dateOfBirth.value;

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        UserAvatar(
                          name: controller.fullName.value,
                          imageUrl: controller.avatarUrl.value,
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
                  subtitle: _display(controller.fullName.value),
                  onTap: () => controller.editFullName(context),
                ),
                      SettingsMenuTile(
                        icon: LucideIcons.mail,
                        label: 'Email',
                        subtitle: _display(controller.email.value),
                        onTap: controller.onEmailTap,
                      ),
                SettingsMenuTile(
                  icon: LucideIcons.phone,
                  label: 'Phone',
                  subtitle: _display(controller.phone.value),
                  onTap: () => controller.editPhone(context),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.cake,
                  label: 'Date of birth',
                  subtitle: dob == null
                      ? 'Not set'
                      : DateFormat('MMMM dd, yyyy').format(dob),
                  onTap: () => controller.editDateOfBirth(context),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.venusAndMars,
                  label: 'Gender',
                  subtitle: _display(controller.gender.value),
                  onTap: () => controller.editGender(context),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.mapPin,
                  label: 'Location',
                  subtitle: _display(controller.location.value),
                  onTap: () => controller.editLocation(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Save',
                      isLoading: controller.isSaving.value,
                      onPressed:
                          controller.isSaving.value ? null : controller.save,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: 'Cancel',
                      variant: CustomButtonVariant.outline,
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.cancel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  static String _display(String value) {
    final trimmed = value.trim();
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
