import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class LanguageOption {
  const LanguageOption({
    required this.code,
    required this.label,
    required this.subtitle,
    required this.flagAsset,
  });

  final String code;
  final String label;
  final String subtitle;
  final String flagAsset;
}

const languageOptions = [
  LanguageOption(
    code: 'en',
    label: 'English (US)',
    subtitle: 'English',
    flagAsset: AppAssets.englishLanguage,
  ),
  LanguageOption(
    code: 'km',
    label: 'Khmer',
    subtitle: 'ភាសាខ្មែរ',
    flagAsset: AppAssets.khmerLanguage,
  ),
];

/// Settings language picker — same option rows as auth Select Language.
class LanguagePickerSheet extends StatefulWidget {
  const LanguagePickerSheet({
    super.key,
    required this.selectedCode,
    required this.onSelect,
  });

  final String selectedCode;
  final ValueChanged<String> onSelect;

  @override
  State<LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<LanguagePickerSheet> {
  late String _selectedCode;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.selectedCode;
  }

  Color _secondary(BuildContext context) => context.appColors.muted;

  Future<void> _handleSelect(String code) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _selectedCode = code;
    });
    // Let the checkmark paint before the sheet closes.
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    final onSelect = widget.onSelect;
    // Pop this sheet via its own navigator (Get.back is unreliable
    // after snackbars / repeated opens).
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
    onSelect(code);
  }

  @override
  Widget build(BuildContext context) {
    final secondary = _secondary(context);
    final border = context.appColors.border;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Language',
              textAlign: TextAlign.start,
              style: context.text.headlineSmall?.copyWith(height: 1.25),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose your preferred language for the app.',
              textAlign: TextAlign.start,
              style: context.text.bodyMedium?.copyWith(
                height: 1.4,
                color: secondary,
              ),
            ),
            const SizedBox(height: 28),
            Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < languageOptions.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: border),
                    _LanguageRow(
                      option: languageOptions[i],
                      selected: _selectedCode == languageOptions[i].code,
                      secondary: secondary,
                      onTap: _busy
                          ? null
                          : () => _handleSelect(languageOptions[i].code),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.option,
    required this.selected,
    required this.secondary,
    required this.onTap,
  });

  final LanguageOption option;
  final bool selected;
  final Color secondary;
  final VoidCallback? onTap;

  static const _flagSize = 28.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withValues(alpha: 0.12),
      highlightColor: AppColors.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                option.flagAsset,
                width: _flagSize,
                height: _flagSize,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.subtitle,
                    style: context.text.bodySmall?.copyWith(color: secondary),
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: selected
                  ? const Icon(
                      LucideIcons.check,
                      key: ValueKey('check'),
                      color: AppColors.primary,
                      size: 24,
                    )
                  : const SizedBox(
                      key: ValueKey('empty'),
                      width: 24,
                      height: 24,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
