import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/shimmer_list_tile.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_link.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/modules/search/widgets/search_recent_tile.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class SearchRecentSection extends StatelessWidget {
  const SearchRecentSection({
    super.key,
    required this.items,
    required this.isLoading,
    required this.onItemTap,
    required this.onTogglePin,
    required this.onRemove,
    this.onClearAll,
    this.header,
    this.showActions = true,
  });

  final List<SearchRecentItem> items;
  final bool isLoading;
  final ValueChanged<SearchRecentItem> onItemTap;
  final ValueChanged<SearchRecentItem> onTogglePin;
  final ValueChanged<SearchRecentItem> onRemove;
  final VoidCallback? onClearAll;
  final Widget? header;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (isLoading) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (_, __) => const ShimmerListTile(),
      );
    }

    if (items.isEmpty) {
      return const EmptyStateWidget(
        title: 'No recent searches',
        subtitle: 'Try searching for people, posts, or jobs',
        icon: LucideIcons.history,
      );
    }

    return ListView(
      children: [
        if (header != null) header!,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          child: Row(
            children: [
              Text('Recent', style: context.text.titleMedium),
              const Spacer(),
              if (onClearAll != null)
                VitheyTextLink(
                  label: 'Clear all',
                  onPressed: onClearAll,
                  color: colors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
            ],
          ),
        ),
        ...items.map(
          (item) => SearchRecentTile(
            item: item,
            onTap: () => onItemTap(item),
            onTogglePin: () => onTogglePin(item),
            onRemove: () => onRemove(item),
            showActions: showActions,
          ),
        ),
      ],
    );
  }
}
