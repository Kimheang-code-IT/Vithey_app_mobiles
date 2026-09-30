import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';

class ChatDetailHeader extends StatelessWidget {
  const ChatDetailHeader({
    super.key,
    required this.participant,
    required this.isTyping,
    required this.isSearchActive,
    required this.searchController,
    required this.searchFocusNode,
    required this.hasSearchQuery,
    required this.onBack,
    required this.onProfileTap,
    required this.onToggleSearch,
    required this.onClearSearch,
    required this.onMenu,
  });

  final ChatParticipant? participant;
  final bool isTyping;
  final bool isSearchActive;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool hasSearchQuery;
  final VoidCallback onBack;
  final VoidCallback onProfileTap;
  final VoidCallback onToggleSearch;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onMenu;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppBar(
      elevation: 0,
      backgroundColor: colors.cardSurface,
      foregroundColor: colors.heading,
      leading: Center(
        child: VitheyIconButton(
          icon: LucideIcons.arrowLeft,
          onTap: onBack,
          tooltip: 'Back',
        ),
      ),
      title: isSearchActive
          ? _ThreadSearchField(
              controller: searchController,
              focusNode: searchFocusNode,
              hasQuery: hasSearchQuery,
              onClear: onClearSearch,
            )
          : _HeaderTitle(
              participant: participant,
              isTyping: isTyping,
              onProfileTap: onProfileTap,
            ),
      actions: [
        VitheyIconButton(
          icon: isSearchActive ? LucideIcons.x : LucideIcons.search,
          onTap: onToggleSearch,
          tooltip: AppStrings.chatThreadSearchHint,
        ),
        PopupMenuButton<String>(
          onSelected: onMenu,
          color: colors.cardSurface,
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'profile',
              child: Text('View profile', style: TextStyle(color: colors.heading)),
            ),
            PopupMenuItem(
              value: 'block',
              child: Text('Block', style: TextStyle(color: colors.heading)),
            ),
            PopupMenuItem(
              value: 'report',
              child: Text('Report', style: TextStyle(color: colors.heading)),
            ),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: colors.border),
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({
    required this.participant,
    required this.isTyping,
    required this.onProfileTap,
  });

  final ChatParticipant? participant;
  final bool isTyping;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final p = participant;
    if (p == null) return const Text('Chat');

    return InkWell(
      onTap: onProfileTap,
      child: Row(
        children: [
          UserAvatar(name: p.fullName, imageUrl: p.avatarUrl, radius: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium?.copyWith(
                    fontWeight: VitheyWeight.bold,
                    color: context.appColors.heading,
                  ),
                ),
                Text(
                  _subtitle(p),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium?.copyWith(
                    color: isTyping || p.isOnline
                        ? AppColors.primary
                        : context.appColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle(ChatParticipant p) {
    if (isTyping) return AppStrings.chatTyping;
    if (p.isOnline) return AppStrings.chatActiveNow;
    if (p.lastSeenAt != null) {
      return RelativeTime.formatLastSeen(p.lastSeenAt!);
    }
    return AppStrings.chatLastSeenRecently;
  }
}

class _ThreadSearchField extends StatelessWidget {
  const _ThreadSearchField({
    required this.controller,
    required this.focusNode,
    required this.hasQuery,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasQuery;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.search,
      style: context.text.titleSmall
          ?.copyWith(fontWeight: VitheyWeight.medium),
      decoration: InputDecoration(
        hintText: AppStrings.chatThreadSearchHint,
        hintStyle: context.text.titleSmall?.copyWith(
          fontWeight: VitheyWeight.medium,
          color: colors.muted,
        ),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: colors.inputFill,
        prefixIcon: VitheyIcon(LucideIcons.search, color: colors.muted, size: 20),
        suffixIcon: hasQuery
            ? IconButton(
                icon: VitheyIcon(LucideIcons.x, color: colors.muted, size: 18),
                onPressed: onClear,
                tooltip: AppStrings.clearSearch,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}
