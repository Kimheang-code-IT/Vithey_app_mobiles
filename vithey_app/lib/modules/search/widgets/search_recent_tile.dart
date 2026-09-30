import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/core/widgets/vithey_action_sheet.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class SearchRecentTile extends StatelessWidget {
  const SearchRecentTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onTogglePin,
    required this.onRemove,
    this.showActions = true,
  });

  final SearchRecentItem item;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onRemove;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subtitle =
        item.isUser ? 'Followers ${_formatCount(item.followerCount)}' : null;

    return Semantics(
      label: [
        item.isUser ? 'Person' : 'Recent search',
        item.title,
        if (subtitle != null) subtitle,
        if (item.isPinned) 'Pinned',
      ].join(', '),
      button: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 7, 12, 7),
            child: Row(
              children: [
                if (item.isUser)
                  UserAvatar(
                    name: item.title,
                    imageUrl: item.avatarUrl,
                    radius: 20,
                  )
                else
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.inputFill,
                    child: VitheyIcon(
                      LucideIcons.history,
                      color: colors.muted,
                      size: 21,
                    ),
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium?.copyWith(
                          fontSize: 15.5,
                          fontWeight: VitheyWeight.medium,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: context.text.bodySmall
                              ?.copyWith(fontSize: 12.5),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showActions)
                  VitheyIconButton(
                    icon: item.isPinned
                        ? LucideIcons.pin
                        : LucideIcons.ellipsisVertical,
                    variant: VitheyIconButtonVariant.neutral,
                    tooltip: 'More options for ${item.title}',
                    onTap: () => _showActions(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context) {
    return showVitheyActionSheet<void>(
      context: context,
      title: item.title,
      message: item.isUser ? 'Followers ${_formatCount(item.followerCount)}' : null,
      actions: [
        VitheyActionSheetItem(
          label: item.isPinned ? 'Unpin' : 'Pin',
          icon: item.isPinned ? LucideIcons.pin : LucideIcons.pin,
          onTap: onTogglePin,
        ),
        VitheyActionSheetItem(
          label: 'Remove from recent',
          icon: LucideIcons.trash2,
          isDestructive: true,
          onTap: onRemove,
        ),
      ],
      cancelLabel: 'Cancel',
    );
  }

  String _formatCount(int? count) {
    if (count == null) return '—';
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(count % 1000000 == 0 ? 0 : 1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}K';
    }
    return '$count';
  }
}
