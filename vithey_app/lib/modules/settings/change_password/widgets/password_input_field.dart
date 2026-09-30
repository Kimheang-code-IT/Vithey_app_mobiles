import 'package:aub_connect_app/core/widgets/vithey_field.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Password field with label, placeholder, and leading lock icon.
///
/// Uses the kit [VitheyField]; the eye toggle is built into the field.
class PasswordInputField extends StatelessWidget {
  const PasswordInputField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
  });

  final String label;
  final String placeholder;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return VitheyField(
      controller: controller,
      label: label,
      hint: placeholder,
      prefixIcon: LucideIcons.lock,
      obscureText: true,
    );
  }
}
