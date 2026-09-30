import 'package:flutter/material.dart';

/// Visual layout variants for AI / blank CV templates.
enum CvTemplateLayout {
  blank,
  sidebarLight,
  sidebarDark,
  headerPhoto,
  headerStrip,
  minimal,
}

/// Catalog entry for a CV design (gallery + renderer + PDF).
class CvTemplate {
  const CvTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.style,
    required this.language,
    required this.layout,
    required this.accentColor,
  });

  final String id;
  final String name;

  /// Professional | Creative | Modern
  final String category;

  /// Sidebar | Header | Minimal
  final String style;

  /// English | Khmer — section labels only.
  final String language;

  final CvTemplateLayout layout;
  final Color accentColor;

  bool get isBlank => layout == CvTemplateLayout.blank;

  /// Localized section labels for [language].
  CvTemplateLabels get labels =>
      language == 'Khmer' ? CvTemplateLabels.khmer : CvTemplateLabels.english;
}

class CvTemplateLabels {
  const CvTemplateLabels({
    required this.aboutMe,
    required this.experience,
    required this.education,
    required this.skills,
    required this.projects,
    required this.contact,
  });

  final String aboutMe;
  final String experience;
  final String education;
  final String skills;
  final String projects;
  final String contact;

  static const english = CvTemplateLabels(
    aboutMe: 'About Me',
    experience: 'Experience',
    education: 'Education',
    skills: 'Skills',
    projects: 'Projects',
    contact: 'Contact',
  );

  static const khmer = CvTemplateLabels(
    aboutMe: 'អំពីខ្ញុំ',
    experience: 'បទពិសោធន៍',
    education: 'ការសិក្សា',
    skills: 'ជំនាញ',
    projects: 'គម្រោង',
    contact: 'ទំនាក់ទំនង',
  );
}
