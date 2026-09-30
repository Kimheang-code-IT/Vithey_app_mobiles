import 'package:aub_connect_app/core/widgets/vithey_filter_chips.dart';
import 'package:flutter/material.dart';

/// Filter ids shared by [SearchFilterBar] and the results view.
abstract final class SearchResultFilters {
  static const all = 'all';
  static const people = 'people';
  static const posts = 'posts';
  static const jobs = 'jobs';
  static const videos = 'videos';
}

/// Horizontal section filter chips for search results, built on the shared
/// [VitheyFilterChips] pill style.
class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: VitheyFilterChips(
        items: [
          const VitheyFilterChipItem(id: SearchResultFilters.all, label: 'All'),
          const VitheyFilterChipItem(
              id: SearchResultFilters.people, label: 'People'),
          const VitheyFilterChipItem(
              id: SearchResultFilters.posts, label: 'Posts'),
          const VitheyFilterChipItem(
              id: SearchResultFilters.jobs, label: 'Jobs'),
          const VitheyFilterChipItem(
              id: SearchResultFilters.videos, label: 'Videos'),
        ]
            .map((item) => VitheyFilterChipItem(
                  id: item.id,
                  label: item.label,
                  selected: item.id == selected,
                ))
            .toList(),
        onSelected: onSelected,
      ),
    );
  }
}
