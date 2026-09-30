import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:flutter/material.dart';

/// Grouped card for notification preference rows — kit radius 18.
class NotificationPreferenceCard extends StatelessWidget {
  const NotificationPreferenceCard({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return VitheyCard(
      bordered: true,
      elevated: false,
      borderRadius: VitheyRadii.card,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
