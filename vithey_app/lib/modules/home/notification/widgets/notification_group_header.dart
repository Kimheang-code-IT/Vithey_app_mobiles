import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class NotificationGroupHeader extends StatelessWidget {
  const NotificationGroupHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.text.titleSmall,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
