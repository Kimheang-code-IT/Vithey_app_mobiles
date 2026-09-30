import 'dart:io';

import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/skill_assets.dart';
import 'package:aub_connect_app/data/models/profile_skill_catalog.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Resolves a skill logo for pickers and ring watermarks (local assets first).
class SkillIcon extends StatelessWidget {
  const SkillIcon({
    super.key,
    this.skill,
    this.catalog,
    this.iconKey,
    this.iconPath,
    this.label,
    this.size = 28,
    this.opacity = 1,
    this.color,
  });

  final ProfileSkill? skill;
  final CatalogSkill? catalog;
  final String? iconKey;
  final String? iconPath;
  final String? label;
  final double size;
  final double opacity;
  final Color? color;

  factory SkillIcon.forSkill(
    ProfileSkill skill, {
    Key? key,
    double size = 28,
    double opacity = 1,
    Color? color,
  }) {
    return SkillIcon(
      key: key,
      skill: skill,
      size: size,
      opacity: opacity,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = iconPath ?? skill?.iconPath;
    if (path != null && path.trim().isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        return Opacity(
          opacity: opacity,
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallback(context),
          ),
        );
      }
    }

    final asset = SkillAssets.assetPath(
      iconKey: iconKey ?? skill?.iconKey ?? catalog?.id,
      label: label ?? skill?.name ?? catalog?.label,
    );
    if (asset != null) {
      return Opacity(
        opacity: opacity,
        child: Image.asset(
          asset,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _fallback(context),
        ),
      );
    }

    final entry = catalog ??
        findCatalogSkill(
          iconKey: iconKey ?? skill?.iconKey,
          label: label ?? skill?.name,
        );

    final iconData = entry?.icon ?? LucideIcons.sparkles;
    return Opacity(
      opacity: opacity,
      child: VitheyIcon(
        iconData,
        size: size,
        color: color ?? context.appColors.muted,
      ),
    );
  }

  Widget _fallback(BuildContext context) =>
      VitheyIcon(LucideIcons.sparkles, size: size, color: color);
}
