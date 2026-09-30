import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';

/// Shared emoji sets for composer and message reactions.
class ChatEmojis {
  ChatEmojis._();

  static const quickReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏', '🔥'];

  static const composer = [
    '😀',
    '😃',
    '😄',
    '😁',
    '😆',
    '😅',
    '😂',
    '🤣',
    '😊',
    '😇',
    '🙂',
    '😉',
    '😌',
    '😍',
    '🥰',
    '😘',
    '😗',
    '😙',
    '😚',
    '😋',
    '😜',
    '😝',
    '😛',
    '🤑',
    '🤗',
    '🤭',
    '🤫',
    '🤔',
    '🤐',
    '🤨',
    '😐',
    '😑',
    '😶',
    '😏',
    '😒',
    '🙄',
    '😬',
    '😮',
    '😯',
    '😲',
    '😳',
    '🥺',
    '😢',
    '😭',
    '😤',
    '😠',
    '😡',
    '🤬',
    '👍',
    '👎',
    '👏',
    '🙌',
    '🤝',
    '🙏',
    '💪',
    '✌️',
    '🤞',
    '🤟',
    '🤘',
    '👌',
    '🤌',
    '👆',
    '👇',
    '👉',
    '❤️',
    '🧡',
    '💛',
    '💚',
    '💙',
    '💜',
    '🖤',
    '🤍',
    '💔',
    '❣️',
    '💕',
    '💞',
    '💓',
    '💗',
    '💖',
    '💘',
    '🔥',
    '⭐',
    '✨',
    '💫',
    '🎉',
    '🎊',
    '💯',
    '✅',
    '❌',
    '❗',
    '❓',
    '💬',
    '👀',
    '👻',
    '🤖',
    '🎃',
  ];
}

class ChatEmojiPanel extends StatelessWidget {
  const ChatEmojiPanel({
    super.key,
    required this.onEmojiSelected,
    this.height = 240,
  });

  final ValueChanged<String> onEmojiSelected;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: ChatEmojis.composer.length,
        itemBuilder: (context, index) {
          final emoji = ChatEmojis.composer[index];
          return InkWell(
            borderRadius: BorderRadius.circular(VitheyRadii.field),
            onTap: () => onEmojiSelected(emoji),
            child: Center(
              child: Text(
                emoji,
                style: context.text.headlineSmall?.copyWith(fontSize: 26),
              ),
            ),
          );
        },
      ),
    );
  }
}

class QuickReactionBar extends StatelessWidget {
  const QuickReactionBar({
    super.key,
    required this.onSelected,
    this.selectedEmoji,
  });

  final ValueChanged<String> onSelected;
  final String? selectedEmoji;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ChatEmojis.quickReactions.map((emoji) {
          final selected = selectedEmoji == emoji;
          return Material(
            color: selected ? context.appColors.inputFill : Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onSelected(emoji),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Text(
                    emoji,
                    style: context.text.headlineSmall?.copyWith(fontSize: 26),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
