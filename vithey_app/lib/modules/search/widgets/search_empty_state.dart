import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No results for "$query"',
      subtitle: 'Try different keywords or check spelling',
      icon: LucideIcons.searchX,
    );
  }
}
