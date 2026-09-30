import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class ConversationListTile extends StatelessWidget {
  const ConversationListTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.onLongPress,
    this.searchQuery = '',
    this.searchSubtitle,
  });

  final ConversationModel conversation;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String searchQuery;
  final String? searchSubtitle;

  String get _defaultSubtitle {
    if (conversation.isTyping) return AppStrings.chatTyping;
    if (conversation.lastMessageIsOwn) {
      return 'You: ${conversation.lastMessagePreview}';
    }
    return conversation.lastMessagePreview;
  }

  String get _subtitleText => searchSubtitle ?? _defaultSubtitle;

  bool get _showReadCheck =>
      searchSubtitle == null &&
      !conversation.isTyping &&
      conversation.unreadCount == 0 &&
      conversation.lastMessageIsOwn &&
      conversation.lastMessageStatus == MessageDeliveryStatus.read;

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;
    final query = searchQuery.trim();

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: conversation.participant.isOnline
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: UserAvatar(
                name: conversation.participant.fullName,
                imageUrl: conversation.participant.avatarUrl,
                radius: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightedText(
                    text: conversation.participant.fullName,
                    query: query,
                    maxLines: 1,
                    style: context.text.titleMedium?.copyWith(
                      fontWeight:
                          hasUnread ? VitheyWeight.bold : VitheyWeight.semibold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _HighlightedText(
                    text: _subtitleText,
                    query: query,
                    maxLines: 1,
                    style: context.text.bodyMedium?.copyWith(
                      color: conversation.isTyping && searchSubtitle == null
                          ? AppColors.primary
                          : context.appColors.muted,
                      fontWeight:
                          conversation.isTyping && searchSubtitle == null
                              ? VitheyWeight.medium
                              : VitheyWeight.regular,
                    ),
                    highlightColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasUnread)
                  Container(
                    constraints: const BoxConstraints(minWidth: 26),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(VitheyRadii.pill),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      conversation.unreadCount > 99
                          ? '99+'
                          : '${conversation.unreadCount}',
                      style: context.text.labelSmall?.copyWith(
                        color: context.scheme.onPrimary,
                        fontWeight: VitheyWeight.bold,
                        height: 1,
                      ),
                    ),
                  )
                else if (_showReadCheck)
                  const VitheyIcon(LucideIcons.checkCheck,
                      size: 18, color: AppColors.primary),
                const SizedBox(height: 6),
                Text(
                  RelativeTime.formatChatList(conversation.updatedAt),
                  style: context.text.labelMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    this.maxLines = 1,
    this.highlightColor = AppColors.primary,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final int maxLines;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = trimmed.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start)));
        }
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + trimmed.length),
          style: style?.copyWith(
            color: highlightColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      start = index + trimmed.length;
    }

    if (spans.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
