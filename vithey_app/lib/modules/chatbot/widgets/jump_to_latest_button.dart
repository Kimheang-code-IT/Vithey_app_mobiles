import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class JumpToLatestButton extends StatelessWidget {
  const JumpToLatestButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: 'Jump to latest',
      onPressed: onTap,
      icon: LucideIcons.arrowDown,
      variant: CustomButtonVariant.secondary,
    );
  }
}
