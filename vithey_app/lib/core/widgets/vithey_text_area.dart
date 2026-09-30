import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/widgets/vithey_field.dart';

/// Multi-line [VitheyField] alias for longer text (create post, reports…).
class VitheyTextArea extends VitheyField {
  const VitheyTextArea({
    super.key,
    required super.controller,
    super.label,
    super.hint,
    super.minLines = 4,
    super.maxLines = 8,
    super.maxLength,
    super.focusNode,
    super.keyboardType = TextInputType.multiline,
    super.onChanged,
    super.onSubmitted,
    super.errorText,
    super.enabled,
    super.autofocus,
  });
}
