import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

/// Shared auth CTA label style — primary and outline buttons match size/weight.
const kAuthButtonFontSize = 16.0;
const kAuthButtonFontWeight = FontWeight.w600;

/// Google sign-in CTA (coming soon flow). Kit outline button with the
/// Google logo as leading widget.
class OAuthButton extends StatelessWidget {
  const OAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AuthOutlineButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      leading: Image.asset(
        AppAssets.googleIcon,
        width: 20,
        height: 20,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Outline CTA matching Google button chrome (used for Google + Back).
class AuthOutlineButton extends StatelessWidget {
  const AuthOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        label: label,
        variant: CustomButtonVariant.outline,
        leading: leading,
        isLoading: isLoading,
        onPressed: onPressed,
      ),
    );
  }
}

class SocialDivider extends StatelessWidget {
  const SocialDivider({
    super.key,
    this.label,
    this.fontSize = 12,
  });

  /// When null/empty, renders a plain horizontal rule (same height chrome).
  final String? label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final color = context.appColors.border;
    final text = label?.trim();
    // Keep both variants the same height so Sign Up Part 1/2 chrome matches.
    const height = 18.0;
    if (text == null || text.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Divider(color: color, height: 1, thickness: 1),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(child: Divider(color: color, height: 1, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              text,
              style: context.text.labelMedium?.copyWith(
                fontSize: fontSize,
                height: 1,
              ),
            ),
          ),
          Expanded(child: Divider(color: color, height: 1, thickness: 1)),
        ],
      ),
    );
  }
}
