import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class AddChatContactsRow extends StatelessWidget {
  const AddChatContactsRow({
    super.key,
    required this.contacts,
    required this.onAddChat,
    required this.onContactTap,
  });

  final List<ChatParticipant> contacts;
  final VoidCallback onAddChat;
  final ValueChanged<ChatParticipant> onContactTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _AddChatChip(onTap: onAddChat),
          ...contacts.map(
            (c) => _ContactAvatarChip(contact: c, onTap: () => onContactTap(c)),
          ),
        ],
      ),
    );
  }
}

class _AddChatChip extends StatelessWidget {
  const _AddChatChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const VitheyIcon(LucideIcons.plus,
                  color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.chatAddChat,
              style: context.text.labelMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactAvatarChip extends StatelessWidget {
  const _ContactAvatarChip({required this.contact, required this.onTap});

  final ChatParticipant contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: contact.isOnline
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: UserAvatar(
                name: contact.fullName,
                imageUrl: contact.avatarUrl,
                radius: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              contact.fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelMedium
                  ?.copyWith(color: context.appColors.heading),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
