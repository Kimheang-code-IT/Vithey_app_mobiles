import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class StartupProfileDraft {
  StartupProfileDraft({
    Set<String>? skillIds,
    Set<String>? interestIds,
    this.discoverySource,
  })  : skillIds = skillIds ?? <String>{},
        interestIds = interestIds ?? <String>{};

  final Set<String> skillIds;
  final Set<String> interestIds;
  String? discoverySource;
}

class SkillOption {
  const SkillOption({required this.id, required this.label, required this.icon});

  final String id;
  final String label;
  final IconData icon;
}

const startupSkills = [
  SkillOption(id: 'graphic_design', label: 'Graphic Design', icon: LucideIcons.brush),
  SkillOption(id: 'management', label: 'Management', icon: LucideIcons.network),
  SkillOption(id: 'ai', label: 'AI', icon: LucideIcons.globe),
  SkillOption(id: 'social_media', label: 'Social Media Influence', icon: LucideIcons.trendingUp),
  SkillOption(id: 'data_analysis', label: 'Data Analysis', icon: LucideIcons.chartLine),
  SkillOption(id: 'content_video', label: 'Content Video', icon: LucideIcons.circlePlay),
  SkillOption(id: 'coding', label: 'Coding', icon: LucideIcons.code),
  SkillOption(id: 'marketing', label: 'Marketing', icon: LucideIcons.megaphone),
  SkillOption(id: 'sale', label: 'Sale', icon: LucideIcons.user),
  SkillOption(id: 'ui_ux', label: 'UI/UX Design', icon: LucideIcons.penTool),
  SkillOption(id: 'photography', label: 'Photography', icon: LucideIcons.camera),
  SkillOption(id: 'writing', label: 'Writing', icon: LucideIcons.penLine),
  SkillOption(id: 'public_speaking', label: 'Public Speaking', icon: LucideIcons.mic),
  SkillOption(id: 'translation', label: 'Translation', icon: LucideIcons.languages),
];

const startupInterests = [
  SkillOption(id: 'academic_news', label: 'Academic News', icon: LucideIcons.graduationCap),
  SkillOption(id: 'campus_events', label: 'Campus Events', icon: LucideIcons.calendar),
  SkillOption(id: 'student_life', label: 'Student Life', icon: LucideIcons.users),
  SkillOption(id: 'workshops', label: 'Workshops', icon: LucideIcons.folder),
  SkillOption(id: 'career_opportunities', label: 'Career Opportunities', icon: LucideIcons.briefcase),
  SkillOption(id: 'digital_technology', label: 'Digital and Technology', icon: LucideIcons.laptop),
  SkillOption(id: 'sports', label: 'Sports', icon: LucideIcons.volleyball),
  SkillOption(id: 'arts_culture', label: 'Arts and Cultures', icon: LucideIcons.palette),
];

const startupDiscoveryOptions = [
  SkillOption(id: 'facebook', label: 'Facebook', icon: LucideIcons.facebook),
  SkillOption(id: 'instagram', label: 'Instagram', icon: LucideIcons.camera),
  SkillOption(id: 'campus', label: 'Campus Event', icon: LucideIcons.calendarCheck),
  SkillOption(id: 'friend', label: 'Friend', icon: LucideIcons.user),
  SkillOption(id: 'other', label: 'Other', icon: LucideIcons.ellipsis),
];
