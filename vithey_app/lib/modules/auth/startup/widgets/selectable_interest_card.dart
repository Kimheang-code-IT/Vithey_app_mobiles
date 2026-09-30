import 'package:flutter/material.dart';
import 'package:aub_connect_app/modules/auth/startup/widgets/startup_selection_style.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
/// Startup 2 grid card — unique layout; shared selection chrome.
class SelectableInterestCard extends StatelessWidget {
  const SelectableInterestCard({
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VitheyIcon(icon, size: 20, color: iconColor),
              const Spacer(),
              Text(
                label,
                style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: labelColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
