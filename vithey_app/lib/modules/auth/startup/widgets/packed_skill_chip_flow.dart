import 'package:flutter/material.dart';
import 'package:aub_connect_app/data/models/startup_profile_draft.dart';
import 'package:aub_connect_app/modules/auth/startup/widgets/selectable_skill_chip.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';

/// Packs skill chips into rows by moving shorter chips into leftover space
/// so each line fills better (long + short together).
class PackedSkillChipFlow extends StatelessWidget {
  const PackedSkillChipFlow({
    super.key,
    required this.skills,
    required this.selectedIds,
    required this.onToggle,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  final List<SkillOption> skills;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final double spacing;
  final double runSpacing;

  static const _labelStyle = TextStyle(
    fontSize: VitheyType.subtitle,
    fontWeight: VitheyWeight.medium,
  );

  /// Matches [SelectableSkillChip]: pad 12+12, icon 16, gap 6, border 1+1, fudge.
  static const _chromeWidth = 12.0 + 12.0 + 16.0 + 6.0 + 2.0 + 4.0;

  static double _chipWidth(String label) {
    final tp = TextPainter(
      text: TextSpan(text: label, style: _labelStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return _chromeWidth + tp.width;
  }

  /// Keep list order, but pull later shorter chips into leftover row space
  /// so lines fill without overflowing.
  static List<List<SkillOption>> packRows(
    List<SkillOption> skills,
    double maxWidth,
    double spacing,
  ) {
    final remaining = List<SkillOption>.from(skills);
    final rows = <List<SkillOption>>[];

    while (remaining.isNotEmpty) {
      final row = <SkillOption>[];
      var space = maxWidth;

      // Start each row with the next skill in list order.
      final first = remaining.removeAt(0);
      final firstW = _chipWidth(first.label);
      row.add(first);
      space -= firstW + spacing;

      // Fill leftover with the soonest later chip that still fits.
      var i = 0;
      while (i < remaining.length) {
        final w = _chipWidth(remaining[i].label);
        if (w <= space) {
          row.add(remaining.removeAt(i));
          space -= w + spacing;
        } else {
          i++;
        }
      }

      rows.add(row);
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = packRows(skills, constraints.maxWidth, spacing);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) SizedBox(height: runSpacing),
              Row(
                children: [
                  for (var j = 0; j < rows[i].length; j++) ...[
                    if (j > 0) SizedBox(width: spacing),
                    SelectableSkillChip(
                      label: rows[i][j].label,
                      icon: rows[i][j].icon,
                      selected: selectedIds.contains(rows[i][j].id),
                      onTap: () => onToggle(rows[i][j].id),
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
