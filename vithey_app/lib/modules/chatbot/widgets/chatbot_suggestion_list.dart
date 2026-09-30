import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ChatbotSuggestionItem {
  const ChatbotSuggestionItem({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

/// Quick-prompt pills shown on the empty chat home (AI-BOT-06).
///
/// VitheyFilterChips pill language: radius 24, 48px tap targets, card
/// surface + subtle border, no Material checkmark. Mirrors
/// AiFixtures.suggestions — keep both in sync.
class ChatbotSuggestionList extends StatelessWidget {
  const ChatbotSuggestionList({
    super.key,
    required this.items,
    required this.onPromptTap,
  });

  final List<ChatbotSuggestionItem> items;
  final ValueChanged<String> onPromptTap;

  static const defaultItems = [
    ChatbotSuggestionItem(
      icon: LucideIcons.fileText,
      text: 'Help me write a CV',
    ),
    ChatbotSuggestionItem(
      icon: LucideIcons.briefcase,
      text: 'How do I apply for this job?',
    ),
    ChatbotSuggestionItem(
      icon: LucideIcons.terminal,
      text: 'Test my Flutter skills',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _SuggestionPill(
                item: items[i],
                onTap: () => onPromptTap(items[i].text),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SuggestionPill extends StatelessWidget {
  const _SuggestionPill({required this.item, required this.onTap});

  final ChatbotSuggestionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              VitheyIcon(item.icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                item.text,
                style: context.text.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
