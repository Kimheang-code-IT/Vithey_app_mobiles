import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/modules/auth/startup/widgets/startup_selection_style.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
/// Startup 3 list row — unique layout; shared selection chrome + radio.
class DiscoverySourceRow extends StatelessWidget {
  const DiscoverySourceRow({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = StartupSelectionStyle.fill(context, selected: selected);
    final border = StartupSelectionStyle.border(context, selected: selected);
    final iconColor = StartupSelectionStyle.icon(context, selected: selected);
    final labelColor = StartupSelectionStyle.label(context, selected: selected);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              VitheyIcon(icon, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: labelColor),
                ),
              ),
              VitheyIcon(
                selected ? LucideIcons.circleDot : LucideIcons.circle,
                size: 20,
                color: selected ? AppColors.primary : iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
