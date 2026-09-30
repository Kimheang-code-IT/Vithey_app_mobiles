import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';

class AboutHeader extends StatelessWidget {
  const AboutHeader({super.key, required this.version, required this.isLoading});

  final String version;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppLogo(size: 80, onWhiteCircle: true),
        const SizedBox(height: 12),
        Text(
          'Vithey',
          style: context.text.headlineSmall?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          'AUB Student Community App',
          style: TextStyle(color: context.appColors.muted),
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
        else
          Text(version, style: context.text.bodySmall),
      ],
    );
  }
}
