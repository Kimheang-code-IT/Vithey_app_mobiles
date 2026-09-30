import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/modules/settings/change_password/change_password_controller.dart';
import 'package:aub_connect_app/modules/settings/change_password/widgets/password_header.dart';
import 'package:aub_connect_app/modules/settings/change_password/widgets/password_input_field.dart';
import 'package:aub_connect_app/modules/settings/change_password/widgets/password_requirement_card.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';

class ChangePasswordScreen extends GetView<ChangePasswordController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Change Password',
      body: GetBuilder<ChangePasswordController>(
        builder: (_) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            const PasswordHeader(),
            const SizedBox(height: 24),
            PasswordInputField(
              label: 'Current Password',
              placeholder: 'Enter current password',
              controller: controller.currentPassword,
            ),
            const SizedBox(height: 12),
            PasswordInputField(
              label: 'New Password',
              placeholder: 'Enter new password',
              controller: controller.newPassword,
            ),
            const SizedBox(height: 12),
            PasswordInputField(
              label: 'Confirm New Password',
              placeholder: 'Repeat new password',
              controller: controller.confirmPassword,
            ),
            const SizedBox(height: 20),
            PasswordRequirementCard(
              requirements: {
                'At least 8 characters': controller.hasMinLength,
                'One uppercase letter': controller.hasUppercase,
                'One number': controller.hasNumber,
                'One special character': controller.hasSpecial,
              },
            ),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: 'Update Password',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.canSubmit ? controller.updatePassword : null,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
