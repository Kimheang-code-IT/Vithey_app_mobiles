import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_switch.dart';
import 'package:flutter/material.dart';

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: context.scheme.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
          VitheySwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
