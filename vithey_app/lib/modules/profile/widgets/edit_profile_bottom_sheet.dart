import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_field.dart';

/// Shared Add/Edit bottom sheet chrome matching `Edited Content.png`.
///
/// Controllers must be owned by [builder]'s State (or disposed only after the
/// sheet route is fully removed) — never dispose them immediately on await return.
Future<T?> showEditProfileSheet<T>({
  required BuildContext context,
  required String title,
  required Widget Function(BuildContext sheetContext) builder,
  Widget Function(BuildContext sheetContext)? titleTrailing,
  bool enableDrag = true,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: _EditProfileSheetScaffold(
          title: title,
          titleTrailing: titleTrailing?.call(ctx),
          child: builder(ctx),
        ),
      );
    },
  );
}

/// Full-height sheet (same chrome as [showEditProfileSheet]).
/// Drag down dismisses and returns to the previous route (e.g. Add Skill).
Future<T?> showFullHeightEditProfileSheet<T>({
  required BuildContext context,
  required String title,
  required Widget Function(BuildContext sheetContext) builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
    ),
    builder: (ctx) {
      final height = MediaQuery.sizeOf(ctx).height;
      return SizedBox(
        height: height,
        child: _EditProfileSheetScaffold(
          title: title,
          expandChild: true,
          child: builder(ctx),
        ),
      );
    },
  );
}

class _EditProfileSheetScaffold extends StatelessWidget {
  const _EditProfileSheetScaffold({
    required this.title,
    required this.child,
    this.titleTrailing,
    this.expandChild = false,
  });

  final String title;
  final Widget? titleTrailing;
  final Widget child;
  final bool expandChild;

  Widget _header(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.appColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: context.text.titleLarge?.copyWith(fontSize: 20),
              ),
            ),
            if (titleTrailing != null) titleTrailing!,
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (expandChild) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    // Non-scroll primary axis so drag-to-dismiss works; keyboard growth is
    // handled by parent viewInsets padding. Nested scroll only if needed.
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(context),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfileSheetField extends StatelessWidget {
  const EditProfileSheetField({
    super.key,
    required this.label,
    required this.controller,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: VitheyField(
        controller: controller,
        label: required ? '$label*' : label,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        suffix: suffix,
      ),
    );
  }
}

class EditProfileSheetActions extends StatelessWidget {
  const EditProfileSheetActions({
    super.key,
    required this.onSubmit,
    required this.onCancel,
    this.submitLabel = 'Submit',
  });

  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final String submitLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              label: submitLabel,
              onPressed: onSubmit,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              label: 'Cancel',
              variant: CustomButtonVariant.outline,
              onPressed: onCancel,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header with **Add** (create-only).
class ProfileSectionAddHeader extends StatelessWidget {
  const ProfileSectionAddHeader({
    super.key,
    required this.title,
    required this.onAdd,
    this.titleSize = 18,
  });

  final String title;
  final VoidCallback onAdd;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: context.text.titleLarge?.copyWith(fontSize: titleSize),
          ),
        ),
        GestureDetector(
          onTap: onAdd,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'Add',
              style: context.text.labelLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
