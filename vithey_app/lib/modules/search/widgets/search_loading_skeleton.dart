import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/widgets/shimmer_list_tile.dart';

class SearchLoadingSkeleton extends StatelessWidget {
  const SearchLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: 6,
      itemBuilder: (_, __) => const ShimmerListTile(),
    );
  }
}
