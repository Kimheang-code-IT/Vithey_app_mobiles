import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/ai_cv_draft.dart';
import 'package:aub_connect_app/data/models/cv_template.dart';
import 'package:flutter/material.dart';

/// Editable CV section tapped on the live template preview (Canva-style).
enum CvEditSection {
  fullName,
  summary,
  skills,
  education,
  experience,
  projects,
  contact,
}

extension CvEditSectionLabel on CvEditSection {
  String get title => switch (this) {
        CvEditSection.fullName => 'Full name',
        CvEditSection.summary => 'About / Summary',
        CvEditSection.skills => 'Skills',
        CvEditSection.education => 'Education',
        CvEditSection.experience => 'Experience',
        CvEditSection.projects => 'Projects',
        CvEditSection.contact => 'Contact',
      };

  String get hint => switch (this) {
        CvEditSection.fullName => 'Your full name',
        CvEditSection.summary => 'Short summary about you',
        CvEditSection.skills => 'Comma-separated skills',
        CvEditSection.education => 'One school / degree per line',
        CvEditSection.experience => 'One role per line',
        CvEditSection.projects => 'One project per line',
        CvEditSection.contact => 'Email · phone · location',
      };

  int get maxLines => switch (this) {
        CvEditSection.fullName => 1,
        CvEditSection.contact => 2,
        CvEditSection.skills => 3,
        _ => 6,
      };
}

/// Renders a CV draft in a chosen template layout (gallery thumb + editor).
///
/// When [editable] is true, tapping a text block calls [onEditSection]
/// so the host can open an inline editor (Canva-style).
class CvTemplatePreview extends StatelessWidget {
  const CvTemplatePreview({
    super.key,
    required this.draft,
    required this.template,
    this.compact = false,
    this.editable = false,
    this.onEditSection,
    this.activeSection,
  });

  final AiCvDraft draft;
  final CvTemplate template;
  final bool compact;
  final bool editable;
  final ValueChanged<CvEditSection>? onEditSection;
  final CvEditSection? activeSection;

  @override
  Widget build(BuildContext context) {
    switch (template.layout) {
      case CvTemplateLayout.sidebarLight:
      case CvTemplateLayout.sidebarDark:
        return _SidebarLayout(
          draft: draft,
          template: template,
          compact: compact,
          dark: template.layout == CvTemplateLayout.sidebarDark,
          editable: editable,
          onEditSection: onEditSection,
          activeSection: activeSection,
        );
      case CvTemplateLayout.headerPhoto:
        return _HeaderPhotoLayout(
          draft: draft,
          template: template,
          compact: compact,
          editable: editable,
          onEditSection: onEditSection,
          activeSection: activeSection,
        );
      case CvTemplateLayout.headerStrip:
        return _HeaderStripLayout(
          draft: draft,
          template: template,
          compact: compact,
          editable: editable,
          onEditSection: onEditSection,
          activeSection: activeSection,
        );
      case CvTemplateLayout.minimal:
      case CvTemplateLayout.blank:
        return _MinimalLayout(
          draft: draft,
          template: template,
          compact: compact,
          editable: editable,
          onEditSection: onEditSection,
          activeSection: activeSection,
        );
    }
  }
}

double _fs(bool compact, double full) => compact ? full * 0.42 : full;

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.text,
    required this.color,
    required this.compact,
  });

  final String text;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: compact ? 4 : 10, bottom: compact ? 2 : 4),
      child: Text(
        text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: _fs(compact, 9),
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: color,
        ),
      ),
    );
  }
}

class _EditableBlock extends StatelessWidget {
  const _EditableBlock({
    required this.section,
    required this.editable,
    required this.active,
    required this.onEdit,
    required this.child,
  });

  final CvEditSection section;
  final bool editable;
  final bool active;
  final ValueChanged<CvEditSection>? onEdit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!editable) return child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onEdit == null ? null : () => onEdit!(section),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.28),
            width: active ? 1.5 : 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText({
    required this.text,
    required this.compact,
    this.color = const Color(0xFF1F2937),
    this.maxLines,
    this.placeholder,
  });

  final String text;
  final bool compact;
  final Color color;
  final int? maxLines;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    final empty = text.trim().isEmpty;
    if (empty && placeholder == null) return const SizedBox.shrink();
    return Text(
      empty ? (placeholder ?? '') : text,
      maxLines: maxLines ?? (compact ? 3 : 8),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: _fs(compact, 8.5),
        height: 1.3,
        color: empty ? color.withValues(alpha: 0.45) : color,
        fontStyle: empty ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.initials,
    required this.size,
    required this.bg,
  });

  final String initials;
  final double size;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size * 0.06),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.32,
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

class _SidebarLayout extends StatelessWidget {
  const _SidebarLayout({
    required this.draft,
    required this.template,
    required this.compact,
    required this.dark,
    required this.editable,
    this.onEditSection,
    this.activeSection,
  });

  final AiCvDraft draft;
  final CvTemplate template;
  final bool compact;
  final bool dark;
  final bool editable;
  final ValueChanged<CvEditSection>? onEditSection;
  final CvEditSection? activeSection;

  @override
  Widget build(BuildContext context) {
    final accent = template.accentColor;
    final labels = template.labels;
    final sidebarFg = dark ? Colors.white : const Color(0xFF1F2937);
    final sidebarMuted = dark ? Colors.white70 : const Color(0xFF4B5563);
    final pad = compact ? 6.0 : 14.0;
    final avatar = compact ? 28.0 : 56.0;

    Widget block(CvEditSection s, Widget child) => _EditableBlock(
          section: s,
          editable: editable,
          active: activeSection == s,
          onEdit: onEditSection,
          child: child,
        );

    return ColoredBox(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 38,
            child: ColoredBox(
              color: dark ? accent : accent.withValues(alpha: 0.22),
              child: Padding(
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: _AvatarCircle(
                        initials: _initials(draft.fullName),
                        size: avatar,
                        bg: dark ? accent.withValues(alpha: 0.5) : accent,
                      ),
                    ),
                    SizedBox(height: compact ? 4 : 10),
                    block(
                      CvEditSection.fullName,
                      Text(
                        draft.fullName.isEmpty ? 'Your Name' : draft.fullName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: _fs(compact, 11),
                          fontWeight: FontWeight.w800,
                          color: draft.fullName.isEmpty
                              ? sidebarFg.withValues(alpha: 0.5)
                              : sidebarFg,
                          fontStyle: draft.fullName.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 4 : 8),
                    _SectionTitle(
                      text: labels.contact,
                      color: sidebarFg,
                      compact: compact,
                    ),
                    block(
                      CvEditSection.contact,
                      _BodyText(
                        text: draft.contact,
                        compact: compact,
                        color: sidebarMuted,
                        maxLines: compact ? 2 : 4,
                        placeholder: editable ? 'Tap to add contact' : null,
                      ),
                    ),
                    _SectionTitle(
                      text: labels.skills,
                      color: sidebarFg,
                      compact: compact,
                    ),
                    block(
                      CvEditSection.skills,
                      _BodyText(
                        text: draft.skills.join(' · '),
                        compact: compact,
                        color: sidebarMuted,
                        maxLines: compact ? 3 : 6,
                        placeholder: editable ? 'Tap to add skills' : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 62,
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    text: labels.aboutMe,
                    color: accent,
                    compact: compact,
                  ),
                  block(
                    CvEditSection.summary,
                    _BodyText(
                      text: draft.summary,
                      compact: compact,
                      placeholder: editable ? 'Tap to add summary' : null,
                    ),
                  ),
                  _SectionTitle(
                    text: labels.experience,
                    color: accent,
                    compact: compact,
                  ),
                  block(
                    CvEditSection.experience,
                    _BodyText(
                      text: draft.experience.join('\n'),
                      compact: compact,
                      placeholder: editable ? 'Tap to add experience' : null,
                    ),
                  ),
                  _SectionTitle(
                    text: labels.education,
                    color: accent,
                    compact: compact,
                  ),
                  block(
                    CvEditSection.education,
                    _BodyText(
                      text: draft.education.join('\n'),
                      compact: compact,
                      placeholder: editable ? 'Tap to add education' : null,
                    ),
                  ),
                  _SectionTitle(
                    text: labels.projects,
                    color: accent,
                    compact: compact,
                  ),
                  block(
                    CvEditSection.projects,
                    _BodyText(
                      text: draft.projects.join('\n'),
                      compact: compact,
                      placeholder: editable ? 'Tap to add projects' : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPhotoLayout extends StatelessWidget {
  const _HeaderPhotoLayout({
    required this.draft,
    required this.template,
    required this.compact,
    required this.editable,
    this.onEditSection,
    this.activeSection,
  });

  final AiCvDraft draft;
  final CvTemplate template;
  final bool compact;
  final bool editable;
  final ValueChanged<CvEditSection>? onEditSection;
  final CvEditSection? activeSection;

  @override
  Widget build(BuildContext context) {
    final accent = template.accentColor;
    final labels = template.labels;
    final pad = compact ? 6.0 : 14.0;
    final headerH = compact ? 36.0 : 72.0;
    final avatar = compact ? 28.0 : 58.0;

    Widget block(CvEditSection s, Widget child) => _EditableBlock(
          section: s,
          editable: editable,
          active: activeSection == s,
          onEdit: onEditSection,
          child: child,
        );

    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: headerH + avatar * 0.45,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: headerH,
                  child: ColoredBox(color: accent),
                ),
                Positioned(
                  top: headerH - avatar * 0.55,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _AvatarCircle(
                      initials: _initials(draft.fullName),
                      size: avatar,
                      bg: accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(pad, compact ? 2 : 6, pad, pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                block(
                  CvEditSection.fullName,
                  Text(
                    draft.fullName.isEmpty ? 'Your Name' : draft.fullName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _fs(compact, 12),
                      fontWeight: FontWeight.w800,
                      color: draft.fullName.isEmpty
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF111827),
                      fontStyle: draft.fullName.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 2 : 4),
                block(
                  CvEditSection.contact,
                  _BodyText(
                    text: draft.contact,
                    compact: compact,
                    color: const Color(0xFF6B7280),
                    maxLines: 1,
                    placeholder: editable ? 'Tap to add contact' : null,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                        text: labels.aboutMe,
                        color: accent,
                        compact: compact,
                      ),
                      block(
                        CvEditSection.summary,
                        _BodyText(
                          text: draft.summary,
                          compact: compact,
                          placeholder:
                              editable ? 'Tap to add summary' : null,
                        ),
                      ),
                      _SectionTitle(
                        text: labels.experience,
                        color: accent,
                        compact: compact,
                      ),
                      block(
                        CvEditSection.experience,
                        _BodyText(
                          text: draft.experience.join('\n'),
                          compact: compact,
                          placeholder:
                              editable ? 'Tap to add experience' : null,
                        ),
                      ),
                      _SectionTitle(
                        text: labels.education,
                        color: accent,
                        compact: compact,
                      ),
                      block(
                        CvEditSection.education,
                        _BodyText(
                          text: draft.education.join('\n'),
                          compact: compact,
                          placeholder:
                              editable ? 'Tap to add education' : null,
                        ),
                      ),
                      _SectionTitle(
                        text: labels.skills,
                        color: accent,
                        compact: compact,
                      ),
                      block(
                        CvEditSection.skills,
                        _BodyText(
                          text: draft.skills.join(' · '),
                          compact: compact,
                          placeholder:
                              editable ? 'Tap to add skills' : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStripLayout extends StatelessWidget {
  const _HeaderStripLayout({
    required this.draft,
    required this.template,
    required this.compact,
    required this.editable,
    this.onEditSection,
    this.activeSection,
  });

  final AiCvDraft draft;
  final CvTemplate template;
  final bool compact;
  final bool editable;
  final ValueChanged<CvEditSection>? onEditSection;
  final CvEditSection? activeSection;

  @override
  Widget build(BuildContext context) {
    final accent = template.accentColor;
    final labels = template.labels;
    final pad = compact ? 6.0 : 14.0;

    Widget block(CvEditSection s, Widget child) => _EditableBlock(
          section: s,
          editable: editable,
          active: activeSection == s,
          onEdit: onEditSection,
          child: child,
        );

    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: accent,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pad,
                vertical: compact ? 8 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  block(
                    CvEditSection.fullName,
                    Text(
                      draft.fullName.isEmpty ? 'Your Name' : draft.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _fs(compact, 13),
                        fontWeight: FontWeight.w800,
                        color: draft.fullName.isEmpty
                            ? Colors.white54
                            : Colors.white,
                        fontStyle: draft.fullName.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 2 : 4),
                  block(
                    CvEditSection.contact,
                    _BodyText(
                      text: draft.contact,
                      compact: compact,
                      color: Colors.white70,
                      maxLines: 1,
                      placeholder: editable ? 'Tap to add contact' : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(
                  text: labels.aboutMe,
                  color: accent,
                  compact: compact,
                ),
                block(
                  CvEditSection.summary,
                  _BodyText(
                    text: draft.summary,
                    compact: compact,
                    placeholder: editable ? 'Tap to add summary' : null,
                  ),
                ),
                _SectionTitle(
                  text: labels.experience,
                  color: accent,
                  compact: compact,
                ),
                block(
                  CvEditSection.experience,
                  _BodyText(
                    text: draft.experience.join('\n'),
                    compact: compact,
                    placeholder: editable ? 'Tap to add experience' : null,
                  ),
                ),
                _SectionTitle(
                  text: labels.education,
                  color: accent,
                  compact: compact,
                ),
                block(
                  CvEditSection.education,
                  _BodyText(
                    text: draft.education.join('\n'),
                    compact: compact,
                    placeholder: editable ? 'Tap to add education' : null,
                  ),
                ),
                _SectionTitle(
                  text: labels.skills,
                  color: accent,
                  compact: compact,
                ),
                block(
                  CvEditSection.skills,
                  _BodyText(
                    text: draft.skills.join(' · '),
                    compact: compact,
                    placeholder: editable ? 'Tap to add skills' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MinimalLayout extends StatelessWidget {
  const _MinimalLayout({
    required this.draft,
    required this.template,
    required this.compact,
    required this.editable,
    this.onEditSection,
    this.activeSection,
  });

  final AiCvDraft draft;
  final CvTemplate template;
  final bool compact;
  final bool editable;
  final ValueChanged<CvEditSection>? onEditSection;
  final CvEditSection? activeSection;

  @override
  Widget build(BuildContext context) {
    final accent = template.accentColor;
    final labels = template.labels;
    final pad = compact ? 8.0 : 16.0;

    Widget block(CvEditSection s, Widget child) => _EditableBlock(
          section: s,
          editable: editable,
          active: activeSection == s,
          onEdit: onEditSection,
          child: child,
        );

    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            block(
              CvEditSection.fullName,
              Text(
                draft.fullName.isEmpty ? 'Your Name' : draft.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: _fs(compact, 14),
                  fontWeight: FontWeight.w800,
                  color: draft.fullName.isEmpty
                      ? const Color(0xFF9CA3AF)
                      : accent,
                  fontStyle: draft.fullName.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
            SizedBox(height: compact ? 2 : 4),
            block(
              CvEditSection.contact,
              _BodyText(
                text: draft.contact,
                compact: compact,
                color: const Color(0xFF6B7280),
                maxLines: 1,
                placeholder: editable ? 'Tap to add contact' : null,
              ),
            ),
            Divider(
              height: compact ? 10 : 20,
              color: accent.withValues(alpha: 0.25),
            ),
            _SectionTitle(
              text: labels.aboutMe,
              color: accent,
              compact: compact,
            ),
            block(
              CvEditSection.summary,
              _BodyText(
                text: draft.summary,
                compact: compact,
                placeholder: editable ? 'Tap to add summary' : null,
              ),
            ),
            _SectionTitle(
              text: labels.experience,
              color: accent,
              compact: compact,
            ),
            block(
              CvEditSection.experience,
              _BodyText(
                text: draft.experience.join('\n'),
                compact: compact,
                placeholder: editable ? 'Tap to add experience' : null,
              ),
            ),
            _SectionTitle(
              text: labels.education,
              color: accent,
              compact: compact,
            ),
            block(
              CvEditSection.education,
              _BodyText(
                text: draft.education.join('\n'),
                compact: compact,
                placeholder: editable ? 'Tap to add education' : null,
              ),
            ),
            _SectionTitle(
              text: labels.skills,
              color: accent,
              compact: compact,
            ),
            block(
              CvEditSection.skills,
              _BodyText(
                text: draft.skills.join(' · '),
                compact: compact,
                placeholder: editable ? 'Tap to add skills' : null,
              ),
            ),
            if (editable || draft.projects.isNotEmpty) ...[
              _SectionTitle(
                text: labels.projects,
                color: accent,
                compact: compact,
              ),
              block(
                CvEditSection.projects,
                _BodyText(
                  text: draft.projects.join('\n'),
                  compact: compact,
                  placeholder: editable ? 'Tap to add projects' : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
