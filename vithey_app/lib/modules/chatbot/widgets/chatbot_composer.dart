import 'dart:io';

import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';

/// ChatGPT-style expanding composer: text on top, `+` and send on a bottom row.
/// No voice / mic control.
class ChatbotComposer extends StatelessWidget {
  const ChatbotComposer({
    super.key,
    required this.controller,
    required this.isGenerating,
    required this.onSend,
    required this.onStop,
    required this.attachments,
    required this.onAddAttachment,
    required this.onRemoveAttachment,
  });

  final TextEditingController controller;
  final bool isGenerating;
  final VoidCallback onSend;
  final VoidCallback onStop;
  final List<ChatAttachment> attachments;
  final VoidCallback onAddAttachment;
  final ValueChanged<ChatAttachment> onRemoveAttachment;

  static const double _sendSize = 36;
  static const double _plusTap = 40;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final hasText = value.text.trim().isNotEmpty;
            final canSend =
                (hasText || attachments.isNotEmpty) && !isGenerating;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (attachments.isNotEmpty)
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                      itemCount: attachments.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final item = attachments[index];
                        return _AttachmentChip(
                          attachment: item,
                          onRemove: () => onRemoveAttachment(item),
                        );
                      },
                    ),
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.cardSurface,
                    borderRadius: BorderRadius.circular(VitheyRadii.sheet),
                    border: Border.all(
                      color: colors.border.withValues(alpha: 0.7),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.subtleShadow,
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 44,
                            maxHeight: 160,
                          ),
                          child: TextField(
                            controller: controller,
                            minLines: 1,
                            maxLines: 8,
                            enabled: !isGenerating,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            cursorColor: AppColors.primary,
                            style: context.text.bodyLarge
                                ?.copyWith(height: 1.35),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: 'Ask Vithey AI',
                              hintStyle: context.text.bodyLarge
                                  ?.copyWith(color: colors.muted),
                              contentPadding: const EdgeInsets.fromLTRB(
                                4,
                                6,
                                4,
                                8,
                              ),
                            ),
                            onSubmitted: canSend ? (_) => onSend() : null,
                          ),
                        ),
                        Row(
                          children: [
                            Tooltip(
                              message: 'Add photo, video, or file',
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: isGenerating ? null : onAddAttachment,
                                  customBorder: const CircleBorder(),
                                  child: SizedBox(
                                    width: _plusTap,
                                    height: _plusTap,
                                    child: VitheyIcon(
                                      LucideIcons.plus,
                                      size: 22,
                                      color: colors.heading,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            _SendCircle(
                              enabled: canSend || isGenerating,
                              isStop: isGenerating,
                              onPressed: isGenerating
                                  ? onStop
                                  : (canSend ? onSend : null),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SendCircle extends StatelessWidget {
  const _SendCircle({
    required this.enabled,
    required this.isStop,
    required this.onPressed,
  });

  final bool enabled;
  final bool isStop;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final active = enabled && onPressed != null;

    return Tooltip(
      message: isStop ? 'Stop' : 'Send',
      child: Material(
        color: active ? AppColors.primary : colors.inputFill,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: ChatbotComposer._sendSize,
            height: ChatbotComposer._sendSize,
            child: VitheyIcon(
              isStop ? LucideIcons.square : LucideIcons.arrowUp,
              size: isStop ? 14 : 20,
              color: active
                  ? context.scheme.onPrimary
                  : colors.muted.withValues(alpha: 0.5),
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
                        style:
                            context.text.labelMedium?.copyWith(fontSize: 9),
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
