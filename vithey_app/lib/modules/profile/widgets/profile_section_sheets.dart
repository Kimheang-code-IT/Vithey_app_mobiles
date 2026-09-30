import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/data/models/ai_skill_scorer.dart';
import 'package:aub_connect_app/data/models/profile_skill_catalog.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/profile/widgets/edit_profile_bottom_sheet.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_skills.dart';
import 'package:aub_connect_app/modules/profile/widgets/skill_icon.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Typed Add/Edit sheets. Controllers live inside each form State so drag-dismiss
/// and Submit never dispose listeners while TextFields are still mounted.

/// Shared save / remove result for edit-profile section sheets.
class ProfileSheetResult<T> {
  const ProfileSheetResult.saved(this.value) : deleted = false;
  const ProfileSheetResult.deleted()
      : value = null,
        deleted = true;

  final T? value;
  final bool deleted;
}

/// Legacy alias used by skills wiring.
typedef SkillSheetResult = ProfileSheetResult<ProfileSkill>;

Widget Function(BuildContext) _removeTrailing<T>({
  required String title,
  required String message,
}) {
  return (ctx) => GestureDetector(
        onTap: () async {
          final confirmed = await showConfirmDialog(
            context: ctx,
            title: title,
            message: message,
            confirmLabel: 'Remove',
            variant: ConfirmDialogVariant.destructive,
          );
          if (confirmed != true || !ctx.mounted) return;
          Navigator.pop(ctx, ProfileSheetResult<T>.deleted());
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            'Remove',
            style: ctx.text.labelLarge?.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      );
}

Future<ProfileSheetResult<ProfileSkill>?> showSkillSheet(
  BuildContext context, {
  ProfileSkill? existing,
}) {
  return showEditProfileSheet<ProfileSheetResult<ProfileSkill>>(
    context: context,
    title: existing == null ? 'Add skill' : 'Edit skill',
    titleTrailing: existing == null
        ? null
        : _removeTrailing<ProfileSkill>(
            title: 'Remove skill',
            message: 'Are you sure you want to remove "${existing.name}"?',
          ),
    builder: (ctx) => _SkillForm(sheetContext: ctx, existing: existing),
  );
}

Future<ProfileSheetResult<String>?> showBioSheet(
  BuildContext context, {
  String? existing,
}) {
  final hasExisting = existing != null && existing.trim().isNotEmpty;
  return showEditProfileSheet<ProfileSheetResult<String>>(
    context: context,
    title: hasExisting ? 'Edit bio' : 'Add bio',
    titleTrailing: hasExisting
        ? _removeTrailing<String>(
            title: 'Remove bio',
            message: 'Are you sure you want to remove your bio?',
          )
        : null,
    builder: (ctx) => _BioForm(sheetContext: ctx, existing: existing ?? ''),
  );
}

class PersonalDetailsResult {
  const PersonalDetailsResult({
    required this.location,
    required this.gender,
    required this.dateOfBirth,
  });

  final String location;
  final String gender;
  final DateTime? dateOfBirth;
}

Future<ProfileSheetResult<PersonalDetailsResult>?> showPersonalDetailsSheet(
  BuildContext context, {
  String location = '',
  String gender = '',
  DateTime? dateOfBirth,
}) {
  final hasExisting = location.trim().isNotEmpty ||
      gender.trim().isNotEmpty ||
      dateOfBirth != null;
  return showEditProfileSheet<ProfileSheetResult<PersonalDetailsResult>>(
    context: context,
    title: 'Personal details',
    titleTrailing: hasExisting
        ? _removeTrailing<PersonalDetailsResult>(
            title: 'Remove personal details',
            message:
                'Are you sure you want to remove your personal details?',
          )
        : null,
    builder: (ctx) => _PersonalForm(
      sheetContext: ctx,
      location: location,
      gender: gender,
      dateOfBirth: dateOfBirth,
    ),
  );
}

Future<ProfileSheetResult<ProfileWorkEntry>?> showWorkSheet(
  BuildContext context, {
  ProfileWorkEntry? existing,
}) {
  return showEditProfileSheet<ProfileSheetResult<ProfileWorkEntry>>(
    context: context,
    title: existing == null ? 'Add work' : 'Edit work',
    titleTrailing: existing == null
        ? null
        : _removeTrailing<ProfileWorkEntry>(
            title: 'Remove work',
            message:
                'Are you sure you want to remove "${existing.displayLabel}"?',
          ),
    builder: (ctx) => _WorkForm(sheetContext: ctx, existing: existing),
  );
}

Future<ProfileSheetResult<ProfileEducationEntry>?> showEducationSheet(
  BuildContext context, {
  ProfileEducationEntry? existing,
}) {
  return showEditProfileSheet<ProfileSheetResult<ProfileEducationEntry>>(
    context: context,
    title: existing == null ? 'Add education' : 'Edit education',
    titleTrailing: existing == null
        ? null
        : _removeTrailing<ProfileEducationEntry>(
            title: 'Remove education',
            message: 'Are you sure you want to remove "${existing.school}"?',
          ),
    builder: (ctx) => _EducationForm(sheetContext: ctx, existing: existing),
  );
}

Future<ProfileSheetResult<ProfileLinkEntry>?> showLinkSheet(
  BuildContext context, {
  ProfileLinkEntry? existing,
}) {
  return showEditProfileSheet<ProfileSheetResult<ProfileLinkEntry>>(
    context: context,
    title: existing == null ? 'Add link' : 'Edit link',
    titleTrailing: existing == null
        ? null
        : _removeTrailing<ProfileLinkEntry>(
            title: 'Remove link',
            message: 'Are you sure you want to remove "${existing.platform}"?',
          ),
    builder: (ctx) => _LinkForm(sheetContext: ctx, existing: existing),
  );
}

Future<ProfileSheetResult<ProfileContactEntry>?> showContactSheet(
  BuildContext context, {
  ProfileContactEntry? existing,
}) {
  final label = existing == null
      ? ''
      : [
          if (existing.phone != null && existing.phone!.trim().isNotEmpty)
            existing.phone!,
          if (existing.email != null && existing.email!.trim().isNotEmpty)
            existing.email!,
        ].join(' / ');
  return showEditProfileSheet<ProfileSheetResult<ProfileContactEntry>>(
    context: context,
    title: existing == null ? 'Add contact' : 'Edit contact',
    titleTrailing: existing == null
        ? null
        : _removeTrailing<ProfileContactEntry>(
            title: 'Remove contact',
            message: label.isEmpty
                ? 'Are you sure you want to remove this contact?'
                : 'Are you sure you want to remove "$label"?',
          ),
    builder: (ctx) => _ContactForm(sheetContext: ctx, existing: existing),
  );
}

// ─── Forms (own controllers) ──────────────────────────────────────────

class _SkillForm extends StatefulWidget {
  const _SkillForm({required this.sheetContext, this.existing});
  final BuildContext sheetContext;
  final ProfileSkill? existing;

  @override
  State<_SkillForm> createState() => _SkillFormState();
}

class _SkillFormState extends State<_SkillForm> {
  static const _other = 'Other';

  late final TextEditingController _customName;
  String? _selected;
  String? _iconKey;
  String? _iconPath;
  final List<String> _attachmentPaths = [];

  /// `null` = Auto (random by skill name).
  int? _colorValue;

  bool get _isOther => _selected == _other;

  String get _skillName {
    if (_isOther) return _customName.text.trim();
    return _selected?.trim() ?? '';
  }

  ProfileSkill get _previewSkill {
    final name = _skillName;
    final attachments = List<String>.from(_attachmentPaths);
    return ProfileSkill(
      name: name.isEmpty ? 'Skill' : name,
      proficiency: AiSkillScorer.score(
        name: name.isEmpty ? 'Skill' : name,
        attachmentPaths: attachments,
      ),
      colorValue: _colorValue,
      iconKey: _iconKey,
      iconPath: _iconPath,
      attachmentPaths: attachments,
    );
  }

  Color get _previewColor => ProfileSkillRing.colorFor(_previewSkill);

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final existingName = existing?.name.trim() ?? '';
    _colorValue = existing?.colorValue;
    _iconPath = existing?.iconPath;
    if (existing != null) {
      _attachmentPaths.addAll(existing.attachmentPaths);
    }

    if (existingName.isEmpty) {
      _selected = null;
      _iconKey = null;
      _customName = TextEditingController();
    } else {
      final catalog = findCatalogSkill(
        iconKey: existing?.iconKey,
        label: existingName,
      );
      if (catalog != null && catalog.id != 'other') {
        _selected = catalog.label;
        _iconKey = catalog.id;
        _customName = TextEditingController();
      } else {
        _selected = _other;
        _iconKey = existing?.iconKey;
        _customName = TextEditingController(text: existingName);
      }
    }
    _customName.addListener(() {
      if (_isOther && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _customName.dispose();
    super.dispose();
  }

  Future<CatalogSkill?> _showCatalogPicker({
    required String title,
    required List<CatalogSkill> options,
    String? selectedLabel,
  }) {
    return showFullHeightEditProfileSheet<CatalogSkill>(
      context: context,
      title: title,
      builder: (sheetCtx) => _SkillPickerList(
        options: options,
        selectedLabel: selectedLabel,
        onPick: (value) => Navigator.pop(sheetCtx, value),
      ),
    );
  }

  Future<void> _pickSkill() async {
    final level1 = await _showCatalogPicker(
      title: 'Select skill',
      options: topLevelSkillCatalog,
      selectedLabel: _isOther ? null : _selected,
    );
    if (!mounted || level1 == null) return;

    if (level1.id == 'other') {
      setState(() {
        _selected = _other;
        _iconKey = null;
        _iconPath = null;
      });
      return;
    }

    if (isCodingTopLevel(level1.label)) {
      final level2 = await _showCatalogPicker(
        title: 'Select category',
        options: codingCategories,
      );
      if (!mounted || level2 == null) return;

      if (level2.id == 'other') {
        setState(() {
          _selected = _other;
          _iconKey = 'coding';
          _iconPath = null;
          if (_customName.text.isEmpty) _customName.clear();
        });
        return;
      }

      final techList = level2.id == 'frontend'
          ? codingFrontendSkills
          : codingBackendSkills;
      final level3 = await _showCatalogPicker(
        title: 'Select skill',
        options: techList,
        selectedLabel: _selected,
      );
      if (!mounted || level3 == null) return;

      if (level3.id == 'other') {
        setState(() {
          _selected = _other;
          _iconKey = null;
          _iconPath = null;
        });
        return;
      }

      setState(() {
        _selected = level3.label;
        _iconKey = level3.id;
        _iconPath = null;
        _customName.clear();
      });
      return;
    }

    setState(() {
      _selected = level1.label;
      _iconKey = level1.id;
      _iconPath = null;
      _customName.clear();
    });
  }

  Future<void> _pickCustomIconFromLibrary() async {
    final picked = await showFullHeightEditProfileSheet<CatalogSkill>(
      context: context,
      title: 'Choose icon',
      builder: (sheetCtx) => _SkillIconPickerGrid(
        options: pickableSkillIcons,
        selectedId: _iconPath == null ? _iconKey : null,
        onPick: (value) => Navigator.pop(sheetCtx, value),
      ),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _iconKey = picked.id;
      _iconPath = null;
    });
  }

  Future<void> _pickCustomImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (!mounted || file == null) return;
    setState(() {
      _iconPath = file.path;
      // Custom image overrides catalog icon key for display.
    });
  }

  void _clearCustomIcon() {
    setState(() {
      _iconPath = null;
      if (_isOther) _iconKey = null;
    });
  }

  Future<void> _linkAttachments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const [
        'pdf',
        'png',
        'jpg',
        'jpeg',
        'webp',
        'doc',
        'docx',
      ],
    );
    if (!mounted || result == null) return;
    final paths = result.paths.whereType<String>().where((p) => p.isNotEmpty);
    setState(() {
      for (final path in paths) {
        if (!_attachmentPaths.contains(path)) _attachmentPaths.add(path);
      }
    });
  }

  String _attachmentLabel(String path) {
    final parts = path.replaceAll('\\', '/').split('/');
    return parts.isEmpty ? path : parts.last;
  }

  Future<void> _openCustomColorPicker() async {
    final initial =
        _colorValue != null ? Color(_colorValue!) : _previewColor;
    final picked = await showEditProfileSheet<Color>(
      context: context,
      title: 'Pick color',
      builder: (sheetCtx) => _SkillHsvColorPicker(
        initial: initial,
        onCancel: () => Navigator.pop(sheetCtx),
        onDone: (color) => Navigator.pop(sheetCtx, color),
      ),
    );
    if (!mounted || picked == null) return;
    setState(() => _colorValue = picked.toARGB32());
  }

  @override
  Widget build(BuildContext context) {
    final muted = context.appColors.muted;
    final heading = context.appColors.heading;
    final fill = context.appColors.inputFill;
    final preview = _previewSkill;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Skill*',
                style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(VitheyRadii.field),
                child: InkWell(
                  onTap: _pickSkill,
                  borderRadius: BorderRadius.circular(VitheyRadii.field),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(VitheyRadii.field),
                      border: Border.all(color: context.appColors.border),
                    ),
                    child: Row(
                      children: [
                        if (_selected != null && !_isOther) ...[
                          SkillIcon.forSkill(preview, size: 22),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Text(
                            _selected ?? 'Select a skill',
                            style: context.text.bodyLarge?.copyWith(
                              fontSize: 15,
                              color: _selected == null ? muted : heading,
                            ),
                          ),
                        ),
                        VitheyIcon(
                          LucideIcons.chevronDown,
                          color: muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isOther) ...[
          EditProfileSheetField(
            label: 'Skill name',
            controller: _customName,
            required: true,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skill icon (optional)',
                  style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(VitheyRadii.field),
                        border: Border.all(color: context.appColors.border),
                      ),
                      alignment: Alignment.center,
                      child: SkillIcon.forSkill(preview, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          GestureDetector(
                            onTap: _pickCustomIconFromLibrary,
                            behavior: HitTestBehavior.opaque,
                            child: Text(
                              _iconKey != null && _iconPath == null
                                  ? 'Change icon'
                                  : 'Choose icon',
                              style: context.text.labelLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _pickCustomImage,
                            behavior: HitTestBehavior.opaque,
                            child: Text(
                              _iconPath == null
                                  ? 'Choose image'
                                  : 'Change image',
                              style: context.text.labelLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (_iconPath != null || _iconKey != null)
                            GestureDetector(
                              onTap: _clearCustomIcon,
                              behavior: HitTestBehavior.opaque,
                              child: Text(
                                'Remove',
                                style: context.text.labelLarge?.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Color',
                style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              _SkillColorPicker(
                colors: ProfileSkillRing.palette,
                selected: _colorValue,
                onChanged: (value) => setState(() => _colorValue = value),
                onCustomTap: _openCustomColorPicker,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Proof attachments',
                style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Link certificates or work samples — AI uses them to set your score.',
                style: context.text.labelMedium,
              ),
              const SizedBox(height: 10),
              for (final path in _attachmentPaths)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      VitheyIcon(
                        LucideIcons.paperclip,
                        size: 16,
                        color: muted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _attachmentLabel(path),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(color: heading),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _attachmentPaths.remove(path)),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            'Remove',
                            style: context.text.labelMedium?.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _linkAttachments,
                  icon: const VitheyIcon(
                    LucideIcons.link,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    _attachmentPaths.isEmpty
                        ? 'Link attachment'
                        : 'Add another',
                    style: context.text.labelLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI skill score',
                style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Updated automatically when you save this skill.',
                style: context.text.labelMedium,
              ),
              const SizedBox(height: 12),
              Center(
                child: ProfileSkillRing(
                  skill: preview,
                  size: 88,
                  showLabel: false,
                ),
              ),
            ],
          ),
        ),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () {
            final name = _skillName;
            if (name.isEmpty || name == _other) return;
            final attachments = List<String>.from(_attachmentPaths);
            final proficiency = AiSkillScorer.score(
              name: name,
              attachmentPaths: attachments,
            );
            Navigator.pop(
              widget.sheetContext,
              ProfileSheetResult.saved(
                ProfileSkill(
                  name: name,
                  proficiency: proficiency,
                  colorValue: _colorValue,
                  iconKey: _iconKey,
                  iconPath: _iconPath,
                  attachmentPaths: attachments,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Swatches + first “custom” circle that opens an HSV/HEX picker.
class _SkillColorPicker extends StatelessWidget {
  const _SkillColorPicker({
    required this.colors,
    required this.selected,
    required this.onChanged,
    required this.onCustomTap,
  });

  final List<Color> colors;
  final int? selected;
  final ValueChanged<int?> onChanged;
  final VoidCallback onCustomTap;

  bool get _isCustom {
    if (selected == null) return false;
    return !colors.any((c) => c.toARGB32() == selected);
  }

  @override
  Widget build(BuildContext context) {
    final border = context.appColors.border;
    final customColor = _isCustom ? Color(selected!) : null;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ColorSwatch(
          selected: _isCustom,
          border: border,
          onTap: onCustomTap,
          child: customColor != null
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: customColor,
                    shape: BoxShape.circle,
                  ),
                  child: const VitheyIcon(
                    LucideIcons.check,
                    color: Colors.white,
                    size: 18,
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Color(0xFF08B9B3),
                        Color(0xFFFF9800),
                        Color(0xFF4CAF50),
                        Color(0xFF9C27B0),
                        Color(0xFF2196F3),
                        Color(0xFFE91E63),
                        Color(0xFF08B9B3),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: VitheyIcon(
                        LucideIcons.pipette,
                        size: 12,
                        color: context.appColors.heading,
                      ),
                    ),
                  ),
                ),
        ),
        for (final color in colors)
          _ColorSwatch(
            selected: selected == color.toARGB32(),
            border: border,
            onTap: () => onChanged(color.toARGB32()),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: selected == color.toARGB32()
                  ? const VitheyIcon(LucideIcons.check, color: Colors.white, size: 18)
                  : null,
            ),
          ),
      ],
    );
  }
}

/// Figma-style HSV + HEX color picker for custom skill colors.
class _SkillHsvColorPicker extends StatefulWidget {
  const _SkillHsvColorPicker({
    required this.initial,
    required this.onCancel,
    required this.onDone,
  });

  final Color initial;
  final VoidCallback onCancel;
  final ValueChanged<Color> onDone;

  @override
  State<_SkillHsvColorPicker> createState() => _SkillHsvColorPickerState();
}

class _SkillHsvColorPickerState extends State<_SkillHsvColorPicker> {
  late HSVColor _hsv;
  late final TextEditingController _hex;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initial);
    _hex = TextEditingController(text: _toHex(_hsv.toColor()));
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  static String _toHex(Color c) {
    final rgb = c.toARGB32() & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  static Color? _parseHex(String raw) {
    var s = raw.trim();
    if (s.startsWith('#')) s = s.substring(1);
    if (s.length == 3) {
      s = '${s[0]}${s[0]}${s[1]}${s[1]}${s[2]}${s[2]}';
    }
    if (s.length != 6) return null;
    final rgb = int.tryParse(s, radix: 16);
    if (rgb == null) return null;
    return Color(0xFF000000 | rgb);
  }

  void _setHsv(HSVColor next, {bool syncHex = true}) {
    setState(() => _hsv = next);
    if (syncHex) {
      _hex.text = _toHex(next.toColor());
      _hex.selection = TextSelection.collapsed(offset: _hex.text.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _hsv.toColor();
    final heading = context.appColors.heading;
    final border = context.appColors.border;
    final hueColor = HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Saturation / value map
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 1.25,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanDown: (d) => _updateSv(d.localPosition, constraints.biggest),
                  onPanUpdate: (d) =>
                      _updateSv(d.localPosition, constraints.biggest),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, hueColor],
                          ),
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black],
                          ),
                        ),
                      ),
                      Positioned(
                        left: (_hsv.saturation * constraints.maxWidth) - 10,
                        top: ((1 - _hsv.value) * constraints.maxHeight) - 10,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Hue
        _GradientSlider(
          value: _hsv.hue / 360,
          thumbColor: hueColor,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF0000),
              Color(0xFFFFFF00),
              Color(0xFF00FF00),
              Color(0xFF00FFFF),
              Color(0xFF0000FF),
              Color(0xFFFF00FF),
              Color(0xFFFF0000),
            ],
          ),
          onChanged: (t) => _setHsv(_hsv.withHue((t * 360).clamp(0, 359.9))),
        ),
        const SizedBox(height: 12),
        // Opacity
        _GradientSlider(
          value: _hsv.alpha,
          thumbColor: color,
          showCheckerboard: true,
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0),
              color.withValues(alpha: 1),
            ],
          ),
          onChanged: (t) => _setHsv(_hsv.withAlpha(t.clamp(0, 1))),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(VitheyRadii.field),
                border: Border.all(color: border),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _hex,
                textCapitalization: TextCapitalization.characters,
                style: context.text.titleSmall?.copyWith(
                  color: heading,
                  letterSpacing: 0.5,
                ),
                decoration: InputDecoration(
                  labelText: 'HEX',
                  hintText: '#08B9B3',
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(VitheyRadii.field),
                    borderSide: BorderSide(color: border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(VitheyRadii.field),
                    borderSide: BorderSide(color: border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(VitheyRadii.field),
                    borderSide: BorderSide(color: color, width: 1.5),
                  ),
                ),
                onChanged: (raw) {
                  final parsed = _parseHex(raw);
                  if (parsed == null) return;
                  _setHsv(HSVColor.fromColor(parsed), syncHex: false);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Drag the square & sliders, or type a HEX value',
          style: context.text.labelMedium,
        ),
        EditProfileSheetActions(
          onCancel: widget.onCancel,
          onSubmit: () => widget.onDone(color),
          submitLabel: 'Done',
        ),
      ],
    );
  }

  void _updateSv(Offset pos, Size size) {
    final s = (pos.dx / size.width).clamp(0.0, 1.0);
    final v = (1 - pos.dy / size.height).clamp(0.0, 1.0);
    _setHsv(_hsv.withSaturation(s).withValue(v));
  }
}

class _GradientSlider extends StatelessWidget {
  const _GradientSlider({
    required this.value,
    required this.gradient,
    required this.thumbColor,
    required this.onChanged,
    this.showCheckerboard = false,
  });

  final double value;
  final Gradient gradient;
  final Color thumbColor;
  final ValueChanged<double> onChanged;
  final bool showCheckerboard;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (d) => onChanged((d.localPosition.dx / w).clamp(0, 1)),
          onPanUpdate: (d) => onChanged((d.localPosition.dx / w).clamp(0, 1)),
          child: SizedBox(
            height: 28,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 16,
                    width: w,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (showCheckerboard)
                          CustomPaint(painter: _CheckerboardPainter()),
                        DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: (value * w) - 11,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: thumbColor,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cell = 6.0;
    final light = Paint()..color = AppColors.borderLight;
    final dark = Paint()..color = const Color(0xFFBDBDBD);
    for (var y = 0.0; y < size.height; y += cell) {
      for (var x = 0.0; x < size.width; x += cell) {
        final odd = ((x / cell).floor() + (y / cell).floor()).isOdd;
        canvas.drawRect(
          Rect.fromLTWH(x, y, cell, cell),
          odd ? dark : light,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.selected,
    required this.border,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final Color border;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: selected ? 40 : 34,
          height: selected ? 40 : 34,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? primary : border,
              width: selected ? 2.5 : 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Bottom-aligned skill picker — same sheet chrome as Add/Edit, no actions.
class _SkillPickerList extends StatelessWidget {
  const _SkillPickerList({
    required this.options,
    required this.onPick,
    this.selectedLabel,
  });

  final List<CatalogSkill> options;
  final String? selectedLabel;
  final ValueChanged<CatalogSkill> onPick;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final heading = context.appColors.heading;
    final divider = context.appColors.border.withValues(alpha: 0.6);

    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      itemCount: options.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: divider),
      itemBuilder: (_, i) {
        final option = options[i];
        final isSelected = option.label == selectedLabel;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: SkillIcon(
                catalog: option,
                size: 26,
              ),
            ),
          ),
          title: Text(
            option.label,
            style: context.text.titleSmall?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? primary : heading,
            ),
          ),
          trailing: isSelected
              ? VitheyIcon(LucideIcons.check, color: primary, size: 22)
              : null,
          onTap: () => onPick(option),
        );
      },
    );
  }
}

/// Grid of Material + tech icons for custom “Other” skills.
class _SkillIconPickerGrid extends StatelessWidget {
  const _SkillIconPickerGrid({
    required this.options,
    required this.onPick,
    this.selectedId,
  });

  final List<CatalogSkill> options;
  final String? selectedId;
  final ValueChanged<CatalogSkill> onPick;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final fill = context.appColors.inputFill;
    final border = context.appColors.border;

    return GridView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.92,
      ),
      itemCount: options.length,
      itemBuilder: (_, i) {
        final option = options[i];
        final selected = option.id == selectedId;
        return Material(
          color: selected ? primary.withValues(alpha: 0.12) : fill,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => onPick(option),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? primary : border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkillIcon(catalog: option, size: 30),
                  const SizedBox(height: 6),
                  Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.text.labelSmall?.copyWith(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? primary : context.appColors.heading,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BioForm extends StatefulWidget {
  const _BioForm({required this.sheetContext, required this.existing});
  final BuildContext sheetContext;
  final String existing;

  @override
  State<_BioForm> createState() => _BioFormState();
}

class _BioFormState extends State<_BioForm> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.existing);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditProfileSheetField(label: 'Bio', controller: _ctrl, maxLines: 4),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () => Navigator.pop(
            widget.sheetContext,
            ProfileSheetResult.saved(_ctrl.text.trim()),
          ),
        ),
      ],
    );
  }
}

class _PersonalForm extends StatefulWidget {
  const _PersonalForm({
    required this.sheetContext,
    required this.location,
    required this.gender,
    required this.dateOfBirth,
  });

  final BuildContext sheetContext;
  final String location;
  final String gender;
  final DateTime? dateOfBirth;

  @override
  State<_PersonalForm> createState() => _PersonalFormState();
}

class _PersonalFormState extends State<_PersonalForm> {
  late final TextEditingController _location;
  late final TextEditingController _gender;
  late final TextEditingController _dob;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _dateOfBirth = widget.dateOfBirth;
    _location = TextEditingController(text: widget.location);
    _gender = TextEditingController(text: widget.gender);
    _dob = TextEditingController(
      text: _dateOfBirth == null
          ? ''
          : DateFormat('MMMM dd yyyy').format(_dateOfBirth!),
    );
  }

  @override
  void dispose() {
    _location.dispose();
    _gender.dispose();
    _dob.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: widget.sheetContext,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: Theme.of(c).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dateOfBirth = picked;
      _dob.text = DateFormat('MMMM dd yyyy').format(picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditProfileSheetField(label: 'Location', controller: _location),
        EditProfileSheetField(label: 'Gender', controller: _gender),
        EditProfileSheetField(
          label: 'Date of birth',
          controller: _dob,
          readOnly: true,
          suffix: const VitheyIcon(LucideIcons.calendar),
          onTap: _pickDob,
        ),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () => Navigator.pop(
            widget.sheetContext,
            ProfileSheetResult.saved(
              PersonalDetailsResult(
                location: _location.text.trim(),
                gender: _gender.text.trim(),
                dateOfBirth: _dateOfBirth,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkForm extends StatefulWidget {
  const _WorkForm({required this.sheetContext, this.existing});
  final BuildContext sheetContext;
  final ProfileWorkEntry? existing;

  @override
  State<_WorkForm> createState() => _WorkFormState();
}

class _WorkFormState extends State<_WorkForm> {
  late final TextEditingController _position;
  late final TextEditingController _workplace;
  late final TextEditingController _desc;

  @override
  void initState() {
    super.initState();
    _position = TextEditingController(text: widget.existing?.position ?? '');
    _workplace = TextEditingController(text: widget.existing?.workplace ?? '');
    _desc = TextEditingController(text: widget.existing?.description ?? '');
  }

  @override
  void dispose() {
    _position.dispose();
    _workplace.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditProfileSheetField(label: 'Position', controller: _position),
        EditProfileSheetField(
          label: 'Workplace',
          controller: _workplace,
          required: true,
        ),
        EditProfileSheetField(
          label: 'Description',
          controller: _desc,
          maxLines: 3,
        ),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () {
            final workplace = _workplace.text.trim();
            if (workplace.isEmpty) return;
            final desc = _desc.text.trim();
            Navigator.pop(
              widget.sheetContext,
              ProfileSheetResult.saved(
                ProfileWorkEntry(
                  position: _position.text.trim(),
                  workplace: workplace,
                  description: desc.isEmpty ? null : desc,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _EducationForm extends StatefulWidget {
  const _EducationForm({required this.sheetContext, this.existing});
  final BuildContext sheetContext;
  final ProfileEducationEntry? existing;

  @override
  State<_EducationForm> createState() => _EducationFormState();
}

class _EducationFormState extends State<_EducationForm> {
  late final TextEditingController _school;
  late final TextEditingController _major;
  late final TextEditingController _cert;
  late final TextEditingController _desc;

  @override
  void initState() {
    super.initState();
    _school = TextEditingController(text: widget.existing?.school ?? '');
    _major = TextEditingController(text: widget.existing?.major ?? '');
    _cert = TextEditingController(text: widget.existing?.certificate ?? '');
    _desc = TextEditingController(text: widget.existing?.description ?? '');
  }

  @override
  void dispose() {
    _school.dispose();
    _major.dispose();
    _cert.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditProfileSheetField(
          label: 'School / University',
          controller: _school,
          required: true,
        ),
        EditProfileSheetField(label: 'Major', controller: _major),
        EditProfileSheetField(label: 'Certificate', controller: _cert),
        EditProfileSheetField(
          label: 'Description',
          controller: _desc,
          maxLines: 3,
        ),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () {
            final school = _school.text.trim();
            if (school.isEmpty) return;
            final major = _major.text.trim();
            final cert = _cert.text.trim();
            final desc = _desc.text.trim();
            Navigator.pop(
              widget.sheetContext,
              ProfileSheetResult.saved(
                ProfileEducationEntry(
                  school: school,
                  major: major.isEmpty ? null : major,
                  certificate: cert.isEmpty ? null : cert,
                  description: desc.isEmpty ? null : desc,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LinkForm extends StatefulWidget {
  const _LinkForm({required this.sheetContext, this.existing});
  final BuildContext sheetContext;
  final ProfileLinkEntry? existing;

  @override
  State<_LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends State<_LinkForm> {
  late final TextEditingController _platform;
  late final TextEditingController _url;

  @override
  void initState() {
    super.initState();
    _platform = TextEditingController(text: widget.existing?.platform ?? '');
    _url = TextEditingController(text: widget.existing?.url ?? '');
  }

  @override
  void dispose() {
    _platform.dispose();
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditProfileSheetField(
          label: 'Platform name',
          controller: _platform,
          required: true,
        ),
        EditProfileSheetField(
          label: 'URL',
          controller: _url,
          required: true,
          keyboardType: TextInputType.url,
        ),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () {
            final platform = _platform.text.trim();
            final url = _url.text.trim();
            if (platform.isEmpty || url.isEmpty) return;
            Navigator.pop(
              widget.sheetContext,
              ProfileSheetResult.saved(
                ProfileLinkEntry(platform: platform, url: url),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ContactForm extends StatefulWidget {
  const _ContactForm({required this.sheetContext, this.existing});
  final BuildContext sheetContext;
  final ProfileContactEntry? existing;

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  late final TextEditingController _phone;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(text: widget.existing?.phone ?? '');
    _email = TextEditingController(text: widget.existing?.email ?? '');
  }

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditProfileSheetField(
          label: 'Phone number',
          controller: _phone,
          keyboardType: TextInputType.phone,
        ),
        EditProfileSheetField(
          label: 'Email address',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () {
            final phone = _phone.text.trim();
            final email = _email.text.trim();
            if (phone.isEmpty && email.isEmpty) return;
            Navigator.pop(
              widget.sheetContext,
              ProfileSheetResult.saved(
                ProfileContactEntry(
                  phone: phone.isEmpty ? null : phone,
                  email: email.isEmpty ? null : email,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
