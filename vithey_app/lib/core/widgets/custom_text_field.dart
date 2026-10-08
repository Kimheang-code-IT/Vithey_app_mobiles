import 'package:aub_connect_app/core/widgets/vithey_field.dart';
import 'package:flutter/material.dart';

/// Reusable text field with validation and password toggle.
///
/// Thin alias over [VitheyField] (shadcn_flutter) so existing call sites keep
/// working while the whole app standardizes on one field API.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.fillColor,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  /// Kept for API compatibility; shadcn theme owns fill color.
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return VitheyField(
      controller: controller,
      label: label,
      hint: hint,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      prefixIcon: prefixIcon,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      readOnly: readOnly,
      onTap: onTap,
      focusNode: focusNode,
      filled: true,
    );
  }
}
