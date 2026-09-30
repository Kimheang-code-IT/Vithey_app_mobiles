import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/skill_assets.dart';
import 'package:aub_connect_app/data/models/startup_profile_draft.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// A selectable skill leaf or category entry with optional logo / icon.
class CatalogSkill {
  const CatalogSkill({
    required this.id,
    required this.label,
    this.iconUrl,
    this.icon,
  });

  final String id;
  final String label;

  /// Legacy remote logo URL (unused for bundled skill assets).
  final String? iconUrl;

  /// Fallback / category Material icon.
  final IconData? icon;
}

/// Coding subcategory after selecting Coding.
const codingCategories = [
  CatalogSkill(id: 'frontend', label: 'Frontend', icon: LucideIcons.globe),
  CatalogSkill(id: 'backend', label: 'Backend', icon: LucideIcons.server),
  CatalogSkill(id: 'other', label: 'Other', icon: LucideIcons.ellipsis),
];

CatalogSkill _assetSkill(String id, String label, {IconData? icon}) =>
    CatalogSkill(id: id, label: label, icon: icon);

final codingFrontendSkills = <CatalogSkill>[
  _assetSkill('flutter', 'Flutter'),
  _assetSkill('html', 'HTML'),
  _assetSkill('css', 'CSS'),
  _assetSkill('javascript', 'JavaScript'),
  _assetSkill('react', 'React'),
  _assetSkill('nextjs', 'Next.js'),
  _assetSkill('vuejs', 'Vue.js'),
  _assetSkill('angular', 'Angular'),
  _assetSkill('dart', 'Dart'),
  const CatalogSkill(id: 'other', label: 'Other', icon: LucideIcons.ellipsis),
];

final codingBackendSkills = <CatalogSkill>[
  _assetSkill('java', 'Java'),
  _assetSkill('spring', 'Spring Boot'),
  _assetSkill('kotlin', 'Kotlin'),
  _assetSkill('csharp', 'C#'),
  _assetSkill('php', 'PHP'),
  _assetSkill('laravel', 'Laravel'),
  _assetSkill('nodejs', 'Node.js'),
  _assetSkill('python', 'Python'),
  _assetSkill('django', 'Django'),
  _assetSkill('cplusplus', 'C++'),
  _assetSkill('mysql', 'MySQL'),
  _assetSkill('postgresql', 'PostgreSQL'),
  _assetSkill('mongodb', 'MongoDB'),
  _assetSkill('firebase', 'Firebase'),
  _assetSkill('docker', 'Docker'),
  const CatalogSkill(id: 'other', label: 'Other', icon: LucideIcons.ellipsis),
];

/// Top-level profile skill categories (same labels as startup skills).
List<CatalogSkill> get topLevelSkillCatalog => [
      for (final s in startupSkills)
        CatalogSkill(
          id: s.id,
          label: s.label,
          icon: s.icon,
        ),
      const CatalogSkill(id: 'other', label: 'Other', icon: LucideIcons.ellipsis),
    ];

/// All known catalog entries for icon lookup by label / id.
List<CatalogSkill> get allCatalogSkills => [
      ...codingFrontendSkills.where((s) => s.id != 'other'),
      ...codingBackendSkills.where((s) => s.id != 'other'),
    ];

/// Extra Material icons available in the “Choose Icon” picker (custom skills).
const pickableMaterialIcons = <CatalogSkill>[
  CatalogSkill(id: 'icon_star', label: 'Star', icon: LucideIcons.star),
  CatalogSkill(id: 'icon_favorite', label: 'Favorite', icon: LucideIcons.heart),
  CatalogSkill(id: 'icon_bolt', label: 'Bolt', icon: LucideIcons.zap),
  CatalogSkill(id: 'icon_lightbulb', label: 'Idea', icon: LucideIcons.lightbulb),
  CatalogSkill(id: 'icon_psychology', label: 'Mind', icon: LucideIcons.brain),
  CatalogSkill(id: 'icon_school', label: 'School', icon: LucideIcons.graduationCap),
  CatalogSkill(id: 'icon_work', label: 'Work', icon: LucideIcons.briefcase),
  CatalogSkill(id: 'icon_build', label: 'Build', icon: LucideIcons.wrench),
  CatalogSkill(id: 'icon_handyman', label: 'Tools', icon: LucideIcons.wrench),
  CatalogSkill(id: 'icon_science', label: 'Science', icon: LucideIcons.flaskConical),
  CatalogSkill(id: 'icon_biotech', label: 'Biotech', icon: LucideIcons.microscope),
  CatalogSkill(id: 'icon_memory', label: 'Chip', icon: LucideIcons.cpu),
  CatalogSkill(id: 'icon_terminal', label: 'Terminal', icon: LucideIcons.terminal),
  CatalogSkill(id: 'icon_cloud', label: 'Cloud', icon: LucideIcons.cloud),
  CatalogSkill(id: 'icon_security', label: 'Security', icon: LucideIcons.shield),
  CatalogSkill(id: 'icon_wifi', label: 'Network', icon: LucideIcons.wifi),
  CatalogSkill(id: 'icon_storage', label: 'Storage', icon: LucideIcons.database),
  CatalogSkill(id: 'icon_database', label: 'Database', icon: LucideIcons.braces),
  CatalogSkill(id: 'icon_phone', label: 'Mobile', icon: LucideIcons.smartphone),
  CatalogSkill(id: 'icon_laptop', label: 'Laptop', icon: LucideIcons.laptop),
  CatalogSkill(id: 'icon_desktop', label: 'Desktop', icon: LucideIcons.monitor),
  CatalogSkill(id: 'icon_palette', label: 'Palette', icon: LucideIcons.palette),
  CatalogSkill(id: 'icon_brush', label: 'Brush', icon: LucideIcons.brush),
  CatalogSkill(id: 'icon_design', label: 'Design', icon: LucideIcons.penTool),
  CatalogSkill(id: 'icon_architecture', label: 'Architecture', icon: LucideIcons.pencilRuler),
  CatalogSkill(id: 'icon_camera', label: 'Camera', icon: LucideIcons.camera),
  CatalogSkill(id: 'icon_videocam', label: 'Video', icon: LucideIcons.video),
  CatalogSkill(id: 'icon_music', label: 'Music', icon: LucideIcons.music),
  CatalogSkill(id: 'icon_mic', label: 'Mic', icon: LucideIcons.mic),
  CatalogSkill(id: 'icon_edit', label: 'Write', icon: LucideIcons.pencil),
  CatalogSkill(id: 'icon_article', label: 'Article', icon: LucideIcons.fileText),
  CatalogSkill(id: 'icon_translate', label: 'Language', icon: LucideIcons.languages),
  CatalogSkill(id: 'icon_campaign', label: 'Marketing', icon: LucideIcons.megaphone),
  CatalogSkill(id: 'icon_trending', label: 'Growth', icon: LucideIcons.trendingUp),
  CatalogSkill(id: 'icon_analytics', label: 'Analytics', icon: LucideIcons.chartLine),
  CatalogSkill(id: 'icon_insights', label: 'Insights', icon: LucideIcons.chartLine),
  CatalogSkill(id: 'icon_groups', label: 'Team', icon: LucideIcons.users),
  CatalogSkill(id: 'icon_handshake', label: 'Deal', icon: LucideIcons.handshake),
  CatalogSkill(id: 'icon_sports', label: 'Sports', icon: LucideIcons.volleyball),
  CatalogSkill(id: 'icon_fitness', label: 'Fitness', icon: LucideIcons.dumbbell),
  CatalogSkill(id: 'icon_restaurant', label: 'Food', icon: LucideIcons.utensils),
  CatalogSkill(id: 'icon_flight', label: 'Travel', icon: LucideIcons.plane),
  CatalogSkill(id: 'icon_public', label: 'Globe', icon: LucideIcons.globe),
  CatalogSkill(id: 'icon_auto_awesome', label: 'Sparkle', icon: LucideIcons.sparkles),
];

/// Icons shown in the custom-skill “Choose Icon” sheet.
List<CatalogSkill> get pickableSkillIcons {
  final seen = <String>{};
  final out = <CatalogSkill>[];
  for (final s in allCatalogSkills) {
    if (!SkillAssets.hasAsset(iconKey: s.id, label: s.label)) continue;
    if (!seen.add(s.id)) continue;
    out.add(s);
  }
  for (final s in pickableMaterialIcons) {
    if (!seen.add(s.id)) continue;
    out.add(s);
  }
  return out;
}

CatalogSkill? findCatalogSkill({String? iconKey, String? label}) {
  if (iconKey != null && iconKey.isNotEmpty) {
    for (final s in allCatalogSkills) {
      if (s.id == iconKey) return s;
    }
    for (final s in pickableMaterialIcons) {
      if (s.id == iconKey) return s;
    }
  }
  final name = label?.trim().toLowerCase();
  if (name == null || name.isEmpty) return null;
  for (final s in allCatalogSkills) {
    if (s.label.toLowerCase() == name) return s;
  }
  return null;
}

bool isCodingTopLevel(String label) => label.trim().toLowerCase() == 'coding';
