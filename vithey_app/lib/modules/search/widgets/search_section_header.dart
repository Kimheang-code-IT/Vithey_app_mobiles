import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_link.dart';

class SearchSectionHeader extends StatelessWidget {
  const SearchSectionHeader({
    super.key,
    required this.title,
    required this.showSeeAll,
    required this.onSeeAll,
  });

  final String title;
  final bool showSeeAll;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
      child: Row(
        children: [
          Text(
            title,
            style: context.text.titleMedium
                ?.copyWith(fontWeight: VitheyWeight.bold),
          ),
          const Spacer(),
          if (showSeeAll)
            VitheyTextLink(
              label: 'See all',
              onPressed: onSeeAll,
              color: colors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
        ],
      ),
    );
  }
}
