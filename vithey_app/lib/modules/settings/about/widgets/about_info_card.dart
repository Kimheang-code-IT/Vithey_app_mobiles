import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';

/// Rounded surface card shared by all About screen sections (kit radius 18).
class AboutSectionCard extends StatelessWidget {
  const AboutSectionCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        boxShadow: [
          BoxShadow(
            color: context.appColors.subtleShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Section card with a text body and an optional primary-colored link.
class AboutInfoCard extends StatelessWidget {
  const AboutInfoCard({
    super.key,
    required this.title,
    required this.body,
    this.linkLabel,
    this.onLinkTap,
  });

  final String title;
  final String body;
  final String? linkLabel;
  final VoidCallback? onLinkTap;

  @override
  Widget build(BuildContext context) {
    return AboutSectionCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(body, style: TextStyle(color: context.appColors.heading, height: 1.4)),
          if (linkLabel != null && onLinkTap != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onLinkTap,
              child: Text(
                linkLabel!,
                style: context.text.bodyMedium?.copyWith(
                  color: context.scheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
