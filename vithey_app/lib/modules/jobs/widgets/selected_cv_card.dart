import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/cv_file_model.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class SavedCvOption extends StatelessWidget {
  const SavedCvOption({
    super.key,
    required this.savedCv,
    required this.selected,
    required this.enabled,
    required this.onSelect,
  });

  final CvMetadataModel savedCv;
  final bool selected;
  final bool enabled;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: CustomButton(
        label: 'Use saved CV: ${savedCv.fileName}',
        onPressed: enabled ? onSelect : null,
        icon: selected ? LucideIcons.circleCheck : LucideIcons.fileText,
        variant: CustomButtonVariant.outline,
      ),
    );
  }
}

class SelectedCvCard extends StatelessWidget {
  const SelectedCvCard({
    super.key,
    required this.label,
    required this.fileName,
    required this.sizeLabel,
    required this.errorText,
    required this.enabled,
    required this.onReplace,
    required this.onRemove,
    this.showSaveAsDefault = false,
    this.saveAsDefault = false,
    this.onSaveAsDefaultChanged,
  });

  final String label;
  final String fileName;
  final String sizeLabel;
  final String errorText;
  final bool enabled;
  final VoidCallback onReplace;
  final VoidCallback onRemove;
  final bool showSaveAsDefault;
  final bool saveAsDefault;
  final ValueChanged<bool>? onSaveAsDefaultChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: enabled ? 1 : 0.55,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.appColors.inputFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: errorText.isEmpty ? context.appColors.border : AppColors.error),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const VitheyIcon(LucideIcons.fileText, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: context.text.bodySmall?.copyWith(fontSize: 12)),
                        Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.labelLarge),
                        Text(sizeLabel, style: context.text.bodySmall?.copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                  VitheyIconButton(
                    icon: LucideIcons.arrowLeftRight,
                    variant: VitheyIconButtonVariant.neutral,
                    tooltip: 'Replace',
                    onTap: enabled ? onReplace : null,
                  ),
                  VitheyIconButton(
                    icon: LucideIcons.x,
                    variant: VitheyIconButtonVariant.destructive,
                    tooltip: 'Remove',
                    onTap: enabled ? onRemove : null,
                  ),
                ],
              ),
            ),
          ),
          if (errorText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(errorText, style: context.text.bodySmall?.copyWith(color: AppColors.error)),
            ),
          if (showSaveAsDefault)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: saveAsDefault,
              onChanged: enabled && onSaveAsDefaultChanged != null
                  ? (value) => onSaveAsDefaultChanged!(value ?? false)
                  : null,
              title: const Text('Save as my default CV'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
        ],
      ),
    );
  }
}

class LocalSelectedCvCard extends StatelessWidget {
  const LocalSelectedCvCard({
    super.key,
    required this.file,
    required this.errorText,
    required this.enabled,
    required this.showSaveAsDefault,
    required this.saveAsDefault,
    required this.onReplace,
    required this.onRemove,
    required this.onSaveAsDefaultChanged,
  });

  final LocalCvFile file;
  final String errorText;
  final bool enabled;
  final bool showSaveAsDefault;
  final bool saveAsDefault;
  final VoidCallback onReplace;
  final VoidCallback onRemove;
  final ValueChanged<bool> onSaveAsDefaultChanged;

  @override
  Widget build(BuildContext context) {
    return SelectedCvCard(
      label: 'Selected for this application',
      fileName: file.displayName,
      sizeLabel: file.formattedSize,
      errorText: errorText,
      enabled: enabled,
      onReplace: onReplace,
      onRemove: onRemove,
      showSaveAsDefault: showSaveAsDefault,
      saveAsDefault: saveAsDefault,
      onSaveAsDefaultChanged: onSaveAsDefaultChanged,
    );
  }
}

class SavedSelectedCvCard extends StatelessWidget {
  const SavedSelectedCvCard({
    super.key,
    required this.savedCv,
    required this.enabled,
    required this.onReplace,
    required this.onRemove,
  });

  final CvMetadataModel savedCv;
  final bool enabled;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SelectedCvCard(
      label: 'Saved CV',
      fileName: savedCv.fileName,
      sizeLabel: savedCv.mimeType,
      errorText: '',
      enabled: enabled,
      onReplace: onReplace,
      onRemove: onRemove,
    );
  }
}
