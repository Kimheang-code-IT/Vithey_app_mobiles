import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/modules/profile/widgets/edit_profile_bottom_sheet.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_section_sheets.dart';

/// Bottom sheets for Account / Edit Account personal fields.
/// Same chrome as Edit Profile (`showEditProfileSheet`).

Future<ProfileSheetResult<String>?> showAccountTextSheet(
  BuildContext context, {
  required String title,
  required String label,
  String existing = '',
  TextInputType? keyboardType,
  bool required = false,
}) {
  return showEditProfileSheet<ProfileSheetResult<String>>(
    context: context,
    title: title,
    builder: (ctx) => _AccountTextForm(
      sheetContext: ctx,
      label: label,
      existing: existing,
      keyboardType: keyboardType,
      required: required,
    ),
  );
}

Future<ProfileSheetResult<DateTime?>?> showAccountDateOfBirthSheet(
  BuildContext context, {
  DateTime? existing,
}) {
  return showEditProfileSheet<ProfileSheetResult<DateTime?>>(
    context: context,
    title: existing == null ? 'Add date of birth' : 'Edit date of birth',
    builder: (ctx) => _AccountDobForm(
      sheetContext: ctx,
      existing: existing,
    ),
  );
}

class _AccountTextForm extends StatefulWidget {
  const _AccountTextForm({
    required this.sheetContext,
    required this.label,
    required this.existing,
    this.keyboardType,
    this.required = false,
  });

  final BuildContext sheetContext;
  final String label;
  final String existing;
  final TextInputType? keyboardType;
  final bool required;

  @override
  State<_AccountTextForm> createState() => _AccountTextFormState();
}

class _AccountTextFormState extends State<_AccountTextForm> {
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

  void _submit() {
    final value = _ctrl.text.trim();
    if (widget.required && value.isEmpty) return;
    Navigator.pop(
      widget.sheetContext,
      ProfileSheetResult.saved(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EditProfileSheetField(
          label: widget.label,
          controller: _ctrl,
          required: widget.required,
          keyboardType: widget.keyboardType,
        ),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: _submit,
        ),
      ],
    );
  }
}

class _AccountDobForm extends StatefulWidget {
  const _AccountDobForm({
    required this.sheetContext,
    this.existing,
  });

  final BuildContext sheetContext;
  final DateTime? existing;

  @override
  State<_AccountDobForm> createState() => _AccountDobFormState();
}

class _AccountDobFormState extends State<_AccountDobForm> {
  late final TextEditingController _dob;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _dateOfBirth = widget.existing;
    _dob = TextEditingController(
      text: _dateOfBirth == null
          ? ''
          : DateFormat('MMMM dd yyyy').format(_dateOfBirth!),
    );
  }

  @override
  void dispose() {
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
        EditProfileSheetField(
          label: 'Date of birth',
          controller: _dob,
          readOnly: true,
          suffix: const Icon(LucideIcons.calendar),
          onTap: _pickDob,
        ),
        EditProfileSheetActions(
          onCancel: () => Navigator.pop(widget.sheetContext),
          onSubmit: () => Navigator.pop(
            widget.sheetContext,
            ProfileSheetResult.saved(_dateOfBirth),
          ),
        ),
      ],
    );
  }
}
