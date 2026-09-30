import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/core/widgets/vithey_action_sheet.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/modules/search/widgets/search_highlight_text.dart';
import 'package:aub_connect_app/modules/search/widgets/search_result_tile_shell.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class SearchPersonTile extends StatelessWidget {
  const SearchPersonTile({
    super.key,
    required this.person,
    required this.query,
    required this.onTap,
    required this.onMessage,
  });

  final UserSearchResult person;
  final String query;
  final VoidCallback onTap;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return SearchResultTileCard(
      onTap: onTap,
      onLongPress: () => _showActionSheet(context),
      child: Row(
        children: [
          UserAvatar(
              name: person.fullName, imageUrl: person.avatarUrl, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchHighlightText(
                  text: person.fullName,
                  query: query,
                  style: context.text.titleSmall!
                ),
                const SizedBox(height: 2),
                Text(
                  person.subtitle,
                  style: context.text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SearchResultRoundAction(
            icon: LucideIcons.messageCircle,
            tooltip: 'Message',
            onTap: onMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _showActionSheet(BuildContext context) {
    return showVitheyActionSheet<void>(
      context: context,
      title: person.fullName,
      message: person.subtitle,
      actions: [
        VitheyActionSheetItem(
          label: 'View profile',
          icon: LucideIcons.user,
          onTap: onTap,
        ),
        VitheyActionSheetItem(
          label: 'Send message',
          icon: LucideIcons.messageCircle,
          onTap: onMessage,
        ),
      ],
      cancelLabel: 'Cancel',
    );
  }
}
