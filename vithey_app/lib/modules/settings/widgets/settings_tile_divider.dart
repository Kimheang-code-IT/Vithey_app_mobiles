import 'package:flutter/material.dart';

/// Inset divider between settings rows — starts after the leading icon column.
class SettingsTileDivider extends StatelessWidget {
  const SettingsTileDivider({super.key});

  /// Starts after leading icon (16 pad + 22 icon + 14 gap).
  static const double _indent = 16 + 22 + 14;

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, indent: _indent);
  }
}
