import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/widgets/squircle_icon.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class PasswordHeader extends StatelessWidget {
  const PasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        const SquircleIcon(icon: LucideIcons.lock, size: 72),
        const SizedBox(height: 16),
        Text(
          'Update your password',
          style: context.text.headlineSmall?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose a strong password to keep your account safe',
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.muted),
        ),
      ],
    );
  }
}
