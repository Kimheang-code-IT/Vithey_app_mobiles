import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

/// Logout row styled like other settings tiles (TikTok-style list item).
class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cardColor = context.appColors.cardSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.logOut,
                    size: 22,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Logout',
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
