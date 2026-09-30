import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:flutter/material.dart';

class VitheyFilterChipItem {
  const VitheyFilterChipItem({
    required this.id,
    required this.label,
    this.selected = false,
  });

  final String id;
  final String label;
  final bool selected;
}

/// Horizontal filter chips in the Vithey / Shadcn pill style.
///
/// Selected = solid brand teal; unselected = card surface with a subtle
/// border. 48px tap targets; no Material checkmark.
class VitheyFilterChips extends StatelessWidget {
  const VitheyFilterChips({
    super.key,
    required this.items,
    required this.onSelected,
  });

  final List<VitheyFilterChipItem> items;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return _VitheyChip(
            label: item.label,
            selected: item.selected,
            onTap: () => onSelected(item.id),
          );
        },
      ),
    );
  }
}

class _VitheyChip extends StatelessWidget {
  const _VitheyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final background = selected ? AppColors.primary : colors.cardSurface;
    final foreground = selected ? Colors.white : colors.heading;
    final borderColor = selected ? AppColors.primary : colors.border;

    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.text.labelLarge?.copyWith(
              fontWeight:
                  selected ? VitheyWeight.semibold : VitheyWeight.medium,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}
