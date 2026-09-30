import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/widgets/vithey_filter_chips.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';

/// Notification filter row built on the shared [VitheyFilterChips].
class NotificationFilterBar extends StatelessWidget {
  const NotificationFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: VitheyFilterChips(
        items: [
          for (final filter in NotificationFilter.values)
            VitheyFilterChipItem(
              id: filter.name,
              label: switch (filter) {
                NotificationFilter.all => 'All',
                NotificationFilter.read => 'Read',
                NotificationFilter.unread => 'Unread',
              },
              selected: filter == selected,
            ),
        ],
        onSelected: (id) => onSelected(
          NotificationFilter.values.firstWhere((f) => f.name == id),
        ),
      ),
    );
  }
}
