import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/skill_assets.dart';
import 'package:aub_connect_app/data/models/ai_skill_scorer.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/profile/widgets/skill_icon.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ProfileSkillRing extends StatelessWidget {
  const ProfileSkillRing({
    super.key,
    required this.skill,
    this.size = 80,
    this.showLabel = true,
  });

  final ProfileSkill skill;
  final double size;

  /// When false, only the circle is rendered (edit-form preview).
  final bool showLabel;

  static const palette = [
    AppColors.primary,
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
    Color(0xFF9C27B0),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
  ];

  static Color colorFor(ProfileSkill skill) {
    if (skill.colorValue != null) return Color(skill.colorValue!);
    return palette[skill.name.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(skill);
    final aiPercent = AiSkillScorer.scoreSkill(skill);
    final progress = (aiPercent.clamp(0, 100)) / 100;
    final watermarkSize = size * 0.55;
    final percentSize = size >= 88 ? 20.0 : 14.0;

    final circle = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: size >= 88 ? 7 : 6,
              strokeAlign: CircularProgressIndicator.strokeAlignInside,
              backgroundColor: context.appColors.inputFill,
              color: color,
            ),
          ),
          SkillIcon.forSkill(
            skill,
            size: watermarkSize,
            opacity: 0.3,
          ),
          Text(
            '$aiPercent%',
            style: context.text.titleLarge?.copyWith(
              fontSize: percentSize,
            ),
          ),
        ],
      ),
    );

    if (!showLabel) return circle;

    return SizedBox(
      width: size,
      child: Column(
        children: [
          circle,
          const SizedBox(height: 10),
          Text(
            skill.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(
              height: 1.15,
              color: context.appColors.heading,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Edit-profile “Add Skill” control — first item in the skills list.
class ProfileAddSkillCircle extends StatelessWidget {
  const ProfileAddSkillCircle({
    super.key,
    required this.onTap,
    this.size = 80,
  });

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final ringTrack = context.appColors.inputFill;
    final inner = size * 0.42;

    return SizedBox(
      width: size,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ringTrack, width: 6),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: inner,
                  height: inner,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  child: VitheyIcon(
                    LucideIcons.plus,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: inner * 0.62,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add Skill',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(
              height: 1.15,
              color: context.appColors.heading,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ProfileSkillsRow extends StatelessWidget {
  const ProfileSkillsRow({
    super.key,
    required this.skills,
    this.canEdit = false,
    this.onAdd,
    this.onEdit,
  });

  final List<ProfileSkill> skills;
  final bool canEdit;
  final VoidCallback? onAdd;
  final ValueChanged<int>? onEdit;

  @override
  Widget build(BuildContext context) {
    // Keep original order so [onEdit] indexes match the profile skills list.
    final entries = <({int index, ProfileSkill skill})>[
      for (var i = 0; i < skills.length; i++)
        if (SkillAssets.hasAsset(
              iconKey: skills[i].iconKey,
              label: skills[i].name,
            ) ||
            canEdit)
          (index: i, skill: skills[i]),
    ];

    if (!canEdit && entries.isEmpty) return const SizedBox.shrink();

    final itemCount = entries.length + (canEdit ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: context.text.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              if (canEdit && i == 0) {
                return ProfileAddSkillCircle(onTap: onAdd ?? () {});
              }
              final entry = entries[canEdit ? i - 1 : i];
              final ring = ProfileSkillRing(skill: entry.skill);
              if (!canEdit || onEdit == null) return ring;
              return GestureDetector(
                onTap: () => onEdit!(entry.index),
                child: ring,
              );
            },
          ),
        ),
      ],
    );
  }
}
