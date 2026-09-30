import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/about/widgets/about_info_card.dart';
import 'package:aub_connect_app/modules/settings/widgets/squircle_icon.dart';

class AboutContactItem {
  const AboutContactItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
}

class AboutContactCard extends StatelessWidget {
  const AboutContactCard({super.key, required this.items});

  final List<AboutContactItem> items;

  @override
  Widget build(BuildContext context) {
    return AboutSectionCard(
      title: 'Contact',
      child: Column(
        children: [
          for (final item in items)
            InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SquircleIcon(icon: item.icon, radius: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: context.text.bodySmall?.copyWith(fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            style: context.text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: item.onTap != null
                                  ? context.scheme.primary
                                  : context.appColors.heading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
