import 'package:flutter/material.dart';
import 'package:aub_connect_app/data/models/ai_cv_draft.dart';
import 'package:aub_connect_app/data/models/cv_template.dart';

/// Mock CV template catalog for the Canva-style gallery.
abstract final class CvTemplateFixtures {
  static const categories = ['All', 'Professional', 'Creative', 'Modern'];
  static const styles = ['All', 'Sidebar', 'Header', 'Minimal'];
  static const languages = ['All', 'English', 'Khmer'];

  static const List<CvTemplate> all = [
    CvTemplate(
      id: 'tpl-sidebar-light',
      name: 'Donna Soft',
      category: 'Professional',
      style: 'Sidebar',
      language: 'English',
      layout: CvTemplateLayout.sidebarLight,
      accentColor: Color(0xFF7BA3C9),
    ),
    CvTemplate(
      id: 'tpl-sidebar-dark',
      name: 'Francisco Navy',
      category: 'Professional',
      style: 'Sidebar',
      language: 'English',
      layout: CvTemplateLayout.sidebarDark,
      accentColor: Color(0xFF1B3A5F),
    ),
    CvTemplate(
      id: 'tpl-header-photo',
      name: 'Adam Classic',
      category: 'Modern',
      style: 'Header',
      language: 'English',
      layout: CvTemplateLayout.headerPhoto,
      accentColor: Color(0xFF2C2C2C),
    ),
    CvTemplate(
      id: 'tpl-header-strip',
      name: 'Muhammad Warm',
      category: 'Creative',
      style: 'Header',
      language: 'English',
      layout: CvTemplateLayout.headerStrip,
      accentColor: Color(0xFF8B6B4A),
    ),
    CvTemplate(
      id: 'tpl-sidebar-teal',
      name: 'Lorna Teal',
      category: 'Modern',
      style: 'Sidebar',
      language: 'English',
      layout: CvTemplateLayout.sidebarDark,
      accentColor: Color(0xFF03B4AC),
    ),
    CvTemplate(
      id: 'tpl-minimal-en',
      name: 'Isabel Clean',
      category: 'Professional',
      style: 'Minimal',
      language: 'English',
      layout: CvTemplateLayout.minimal,
      accentColor: Color(0xFF374151),
    ),
    CvTemplate(
      id: 'tpl-sidebar-kh',
      name: 'សុភាព ខ្មែរ',
      category: 'Professional',
      style: 'Sidebar',
      language: 'Khmer',
      layout: CvTemplateLayout.sidebarLight,
      accentColor: Color(0xFF5B8FA8),
    ),
    CvTemplate(
      id: 'tpl-minimal-kh',
      name: 'សាមញ្ញ',
      category: 'Modern',
      style: 'Minimal',
      language: 'Khmer',
      layout: CvTemplateLayout.minimal,
      accentColor: Color(0xFF03B4AC),
    ),
    CvTemplate(
      id: 'tpl-header-creative',
      name: 'Isabel Bold',
      category: 'Creative',
      style: 'Header',
      language: 'English',
      layout: CvTemplateLayout.headerPhoto,
      accentColor: Color(0xFF4A5568),
    ),
  ];

  /// Default layout used for "Create blank".
  static const blank = CvTemplate(
    id: 'tpl-blank',
    name: 'Blank',
    category: 'Modern',
    style: 'Minimal',
    language: 'English',
    layout: CvTemplateLayout.blank,
    accentColor: Color(0xFF6B7280),
  );

  static CvTemplate? byId(String? id) {
    if (id == null || id.isEmpty) return null;
    if (id == blank.id) return blank;
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  static CvTemplate requireById(String? id) =>
      byId(id) ?? all.first;

  static List<CvTemplate> filter({
    String query = '',
    String category = 'All',
    String style = 'All',
    String language = 'All',
  }) {
    final q = query.trim().toLowerCase();
    return all.where((t) {
      if (category != 'All' && t.category != category) return false;
      if (style != 'All' && t.style != style) return false;
      if (language != 'All' && t.language != language) return false;
      if (q.isEmpty) return true;
      return t.name.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q) ||
          t.style.toLowerCase().contains(q);
    }).toList();
  }

  /// Sample draft for gallery thumbnails (not user data).
  static const sampleDraft = AiCvDraft(
    fullName: 'Alex Rivera',
    summary:
        'Product designer and Flutter enthusiast building career tools for students.',
    skills: ['Flutter', 'UI Design', 'Figma', 'Dart'],
    education: ['AUB · Computer Science'],
    experience: ['Intern Designer at Studio North'],
    projects: ['Vithey CV Builder'],
    contact: 'alex@example.com · Phnom Penh',
  );
}
