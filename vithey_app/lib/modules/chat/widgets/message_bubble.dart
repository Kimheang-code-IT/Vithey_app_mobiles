import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.participantName,
    this.participantAvatarUrl,
    this.onRetry,
    this.onLongPress,
    this.onReactionTap,
    this.showSeenLabel = false,
  });

  final ChatMessage message;
  final bool showAvatar;
  final String participantName;
  final String? participantAvatarUrl;
  final VoidCallback? onRetry;
  final VoidCallback? onLongPress;
  final ValueChanged<String>? onReactionTap;
  final bool showSeenLabel;

  String _formatBubbleTime(DateTime time) {
    return DateFormat('h:mma').format(time).replaceAll(' ', '');
  }

  @override
  Widget build(BuildContext context) {
    final isOwn = message.isOwn;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;
    final colors = context.appColors;
    final incomingBubbleColor = colors.inputFill;
    final bubbleColor = isOwn ? AppColors.primary : incomingBubbleColor;
    final onPrimary = context.scheme.onPrimary;
    final textColor = isOwn ? onPrimary : colors.heading;
    final displayText =
        message.isDeleted ? 'This message was deleted' : message.text;
    final timeColor =
        isOwn ? onPrimary.withValues(alpha: 0.75) : colors.muted;
    final timeLabel = _formatBubbleTime(message.createdAt);

    return Padding(
      padding: EdgeInsets.only(bottom: showSeenLabel ? 4 : 8),
      child: Row(
        mainAxisAlignment:
            isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwn && showAvatar)
            UserAvatar(
              name: participantName,
              imageUrl: participantAvatarUrl,
              radius: 16,
            )
          else if (!isOwn)
            const SizedBox(width: 32),
          if (!isOwn) const SizedBox(width: 6),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: GestureDetector(
              onLongPress: message.isDeleted ? null : onLongPress,
              child: Column(
                crossAxisAlignment:
                    isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!message.isDeleted && message.attachments.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment:
                          isOwn ? WrapAlignment.end : WrapAlignment.start,
                      children: message.attachments
                          .map(
                            (a) => _BubbleAttachment(
                              attachment: a,
                              isOwn: isOwn,
                            ),
                          )
                          .toList(),
                    ),
                    if (displayText.trim().isNotEmpty)
                      const SizedBox(height: 6),
                  ],
                  if (message.isDeleted || displayText.trim().isNotEmpty)
                    IntrinsicWidth(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 8, 10, 6),
                        decoration: BoxDecoration(
                          color: message.isDeleted
                              ? bubbleColor.withValues(alpha: 0.7)
                              : bubbleColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isOwn ? 18 : 16),
                            bottomRight: Radius.circular(isOwn ? 16 : 18),
                          ),
                          boxShadow: isOwn
                              ? null
                              : [
                                  BoxShadow(
                                    color: colors.subtleShadow,
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (message.replyToPreview != null &&
                                message.replyToPreview!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: _ReplyPreview(
                                  preview: message.replyToPreview!,
                                  isOwn: isOwn,
                                ),
                              ),
                            _TelegramBubbleBody(
                              text: displayText,
                              timeLabel: timeLabel,
                              textColor: message.isDeleted
                                  ? textColor.withValues(alpha: 0.7)
                                  : textColor,
                              timeColor: timeColor,
                              isDeleted: message.isDeleted,
                              isFailed: message.isFailed,
                              onRetry: onRetry,
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (message.attachments.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeLabel,
                            style: context.text.labelSmall,
                          ),
                          if (message.isFailed) ...[
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: onRetry,
                              child: Text(
                                'Retry',
                                style: context.text.labelSmall
                                    ?.copyWith(color: AppColors.error),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  if (!message.isDeleted && message.reactions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      alignment:
                          isOwn ? WrapAlignment.end : WrapAlignment.start,
                      children: message.reactions.map((reaction) {
                        return GestureDetector(
                          onTap: onReactionTap == null
                              ? null
                              : () => onReactionTap!(reaction.emoji),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: reaction.reactedByMe
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : context.appColors.cardSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: reaction.reactedByMe
                                    ? AppColors.primary.withValues(alpha: 0.5)
                                    : context.appColors.border,
                              ),
                            ),
                            child: Text(
                              reaction.count > 1
                                  ? '${reaction.emoji} ${reaction.count}'
                                  : reaction.emoji,
                              style: context.text.bodyMedium
                                  ?.copyWith(fontSize: 13),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (showSeenLabel &&
                      isOwn &&
                      message.status == MessageDeliveryStatus.read)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 4),
                      child: Text(
                        AppStrings.chatSeen,
                        style: context.text.labelSmall,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Telegram-style text + inline timestamp that wraps on the last line.
class _TelegramBubbleBody extends StatelessWidget {
  const _TelegramBubbleBody({
    required this.text,
    required this.timeLabel,
    required this.textColor,
    required this.timeColor,
    required this.isDeleted,
    required this.isFailed,
    this.onRetry,
  });

  final String text;
  final String timeLabel;
  final Color textColor;
  final Color timeColor;
  final bool isDeleted;
  final bool isFailed;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 0,
      runSpacing: 2,
      children: [
        Text(
          text,
          style: context.text.bodyMedium?.copyWith(
            color: textColor,
            fontSize: VitheyType.titleSm,
            height: 1.35,
            fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        const SizedBox(width: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(
                timeLabel,
                style: context.text.labelSmall?.copyWith(color: timeColor),
              ),
            ),
            if (isFailed) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onRetry,
                child: Text(
                  'Retry',
                  style: context.text.labelSmall
                      ?.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({
    required this.preview,
    required this.isOwn,
  });

  final String preview;
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isOwn
            ? context.scheme.onPrimary.withValues(alpha: 0.15)
            : context.appColors.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: isOwn
                ? context.scheme.onPrimary.withValues(alpha: 0.7)
                : AppColors.primary,
            width: 3,
          ),
        ),
      ),
      child: Text(
        preview,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.text.labelMedium?.copyWith(
          color: isOwn
              ? context.scheme.onPrimary.withValues(alpha: 0.7)
              : context.appColors.muted,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _BubbleAttachment extends StatelessWidget {
  const _BubbleAttachment({
    required this.attachment,
    required this.isOwn,
  });

  final ChatAttachment attachment;
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: isOwn
            ? context.scheme.onPrimary.withValues(alpha: 0.15)
            : context.appColors.inputFill,
        borderRadius: BorderRadius.circular(VitheyRadii.media),
        border: Border.all(
          color: isOwn
              ? context.scheme.onPrimary.withValues(alpha: 0.25)
              : context.appColors.border.withValues(alpha: 0.7),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: attachment.isImage
          ? Image.file(
              File(attachment.path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => VitheyIcon(
                LucideIcons.imageOff,
                color: isOwn
                    ? context.scheme.onPrimary.withValues(alpha: 0.7)
                    : context.appColors.muted,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VitheyIcon(
                  attachment.isVideo
                      ? LucideIcons.video
                      : LucideIcons.fileText,
                  color: isOwn
                      ? context.scheme.onPrimary
                      : AppColors.primary,
                  size: 26,
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    attachment.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.text.labelSmall?.copyWith(
                      color: isOwn
                          ? context.scheme.onPrimary
                          : context.appColors.heading,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
