import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_emoji_panel.dart';

/// Telegram-style message composer:
/// `[ attach | text… | emoji | send ]` — all icons live inside the pill, no fills.
class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.attachments,
    required this.onAddAttachment,
    required this.onRemoveAttachment,
    required this.showEmojiPanel,
    required this.onToggleEmoji,
    this.onEmojiSelected,
    this.onTyping,
    this.onFocusText,
  });

  final TextEditingController controller;
  final RxBool isSending;
  final VoidCallback onSend;
  final List<ChatAttachment> attachments;
  final VoidCallback onAddAttachment;
  final ValueChanged<ChatAttachment> onRemoveAttachment;
  final bool showEmojiPanel;
  final VoidCallback onToggleEmoji;
  final ValueChanged<String>? onEmojiSelected;
  final ValueChanged<String>? onTyping;
  final VoidCallback? onFocusText;

  static const int _maxInputLines = 6;
  static const double _iconTap = 42;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.cardSurface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10, 8, 10, showEmojiPanel ? 6 : 8),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final hasText = value.text.trim().isNotEmpty;
                  return Obx(() {
                    final sending = isSending.value;
                    final canSend =
                        (hasText || attachments.isNotEmpty) && !sending;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (attachments.isNotEmpty)
                          SizedBox(
                            height: 64,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                              itemCount: attachments.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (_, index) {
                                final item = attachments[index];
                                return _AttachmentChip(
                                  attachment: item,
                                  onRemove: () => onRemoveAttachment(item),
                                );
                              },
                            ),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            color: colors.inputFill,
                            borderRadius:
                                BorderRadius.circular(VitheyRadii.pill),
                            border: Border.all(
                              color: colors.border.withValues(alpha: 0.6),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _PlainIcon(
                                tooltip: 'Add photo, video, or file',
                                icon: LucideIcons.paperclip,
                                color: colors.heading,
                                onPressed:
                                    sending ? null : onAddAttachment,
                              ),
                              Expanded(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: _iconTap,
                                    maxHeight: 132,
                                  ),
                                  child: TextField(
                                    controller: controller,
                                    enabled: !sending,
                                    minLines: 1,
                                    maxLines: _maxInputLines,
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    cursorColor: AppColors.primary,
                                    onChanged: onTyping,
                                    onTap: onFocusText,
                                    style: context.text.bodyLarge
                                        ?.copyWith(height: 1.3),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      filled: false,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      hintText: AppStrings.chatComposerHint,
                                      hintStyle: context.text.bodyLarge
                                          ?.copyWith(color: colors.muted),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _PlainIcon(
                                tooltip: showEmojiPanel
                                    ? 'Hide emoji'
                                    : 'Emoji',
                                icon: showEmojiPanel
                                    ? LucideIcons.keyboard
                                    : LucideIcons.smile,
                                color: showEmojiPanel
                                    ? AppColors.primary
                                    : colors.heading,
                                onPressed:
                                    sending ? null : onToggleEmoji,
                              ),
                              _PlainIcon(
                                tooltip: 'Send',
                                icon: LucideIcons.send,
                                color: canSend
                                    ? AppColors.primary
                                    : colors.muted.withValues(alpha: 0.45),
                                onPressed: canSend ? onSend : null,
                                loading: sending,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  });
                },
              ),
            ),
            if (showEmojiPanel && onEmojiSelected != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: ChatEmojiPanel(onEmojiSelected: onEmojiSelected!),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlainIcon extends StatelessWidget {
  const _PlainIcon({
    required this.tooltip,
    required this.icon,
    required this.color,
    this.onPressed,
    this.loading = false,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: ChatComposer._iconTap,
            height: ChatComposer._iconTap,
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : VitheyIcon(icon, size: ChatComposer._iconSize, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({
    required this.attachment,
    required this.onRemove,
  });

  final ChatAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: context.appColors.cardSurface,
            borderRadius: BorderRadius.circular(VitheyRadii.media),
            border: Border.all(
              color: context.appColors.border.withValues(alpha: 0.7),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: attachment.isImage
              ? Image.file(
                  File(attachment.path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => VitheyIcon(
                    LucideIcons.imageOff,
                    color: context.appColors.muted,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VitheyIcon(
                      attachment.isVideo
                          ? LucideIcons.video
                          : LucideIcons.fileText,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        attachment.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: context.text.labelSmall
                            ?.copyWith(fontSize: 9),
                      ),
                    ),
                  ],
                ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Material(
            color: context.appColors.heading,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: const SizedBox(
                width: 20,
                height: 20,
                child: VitheyIcon(LucideIcons.x, size: 12, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
