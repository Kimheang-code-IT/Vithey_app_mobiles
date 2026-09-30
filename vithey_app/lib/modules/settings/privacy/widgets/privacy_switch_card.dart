import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:flutter/material.dart';

class PrivacySwitchCard extends StatelessWidget {
  const PrivacySwitchCard({super.key, required this.children});

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
