import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/core/widgets/vithey_switch.dart';
import 'package:flutter/material.dart';

/// Rounded grouped card holding option rows (Privacy / Security).
class SecurityOptionCard extends StatelessWidget {
  const SecurityOptionCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return VitheyCard(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

/// Switch row styled like the Privacy screen rows: primary outline icon,
/// bold title, muted subtitle, compact VitheySwitch.
class SecuritySwitchTile extends StatelessWidget {
  const SecuritySwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final opacity = enabled ? 1.0 : 0.55;
    return Opacity(
      opacity: opacity,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: context.scheme.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.text.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.text.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              VitheySwitch(
                value: value,
                enabled: enabled,
                onChanged: (v) => onChanged(v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
