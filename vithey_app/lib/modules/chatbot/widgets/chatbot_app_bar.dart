import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

PreferredSizeWidget buildChatbotAppBar({
  required VoidCallback onMenu,
  required VoidCallback onBackHome,
}) {
  return AppBar(
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    leading: _AppBarAction(
      icon: LucideIcons.menu,
      tooltip: 'Menu',
      onPressed: onMenu,
    ),
    title: _VitheyAiBadge(),
    actions: [
      _AppBarAction(
        icon: LucideIcons.arrowLeft,
        tooltip: 'Back to home',
        onPressed: onBackHome,
      ),
      const SizedBox(width: 8),
    ],
  );
}

class _AppBarAction extends StatelessWidget {
  const _AppBarAction({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: 44,
              height: 44,
              child: VitheyIcon(icon, size: 22, color: context.appColors.heading),
            ),
          ),
        ),
      ),
    );
  }
}

class _VitheyAiBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            VitheyIcon(
              LucideIcons.sparkles,
              size: 15,
              color: context.scheme.onPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              'Vithey AI',
              style: context.text.titleSmall?.copyWith(
                color: context.scheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
