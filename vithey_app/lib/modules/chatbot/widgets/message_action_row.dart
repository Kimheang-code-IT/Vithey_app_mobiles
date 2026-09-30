import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:intl/intl.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class MessageActionRow extends StatefulWidget {
  const MessageActionRow({
    super.key,
    required this.message,
    required this.onCopy,
    required this.onShare,
    this.onRegenerate,
  });

  final AiMessage message;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback? onRegenerate;

  @override
  State<MessageActionRow> createState() => _MessageActionRowState();
}

class _MessageActionRowState extends State<MessageActionRow> {
  /// null = none, true = liked, false = disliked
  bool? _feedback;

  void _setFeedback(bool liked) {
    setState(() {
      _feedback = _feedback == liked ? null : liked;
    });
  }

  Future<void> _showSources(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final sources = _defaultSources;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: context.appColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const AppLogo(size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Sources',
                      style: context.text.titleLarge?.copyWith(fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Reference resources used for this reply',
                  style: context.text.bodySmall,
                ),
                const SizedBox(height: 14),
                ...sources.map(
                  (source) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.appColors.inputFill,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              context.appColors.border.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.appColors.border
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: source.icon != null
                                ? VitheyIcon(
                                    source.icon!,
                                    size: 20,
                                    color: context.appColors.heading,
                                  )
                                : Image.asset(
                                    source.logoAsset!,
                                    fit: BoxFit.contain,
                                  ),
                          ),

                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  source.title,
                                  style: context.text.labelLarge,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  source.subtitle,
                                  style: context.text.labelMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          VitheyIconButton(
            icon: LucideIcons.copy,
            tooltip: 'Copy',
            variant: VitheyIconButtonVariant.neutral,
            iconSize: 20,
            onTap: widget.onCopy,
          ),
          if (widget.onRegenerate != null) ...[
            const SizedBox(width: 4),
            VitheyIconButton(
              icon: LucideIcons.refreshCw,
              tooltip: 'Regenerate',
              variant: VitheyIconButtonVariant.neutral,
              iconSize: 20,
              onTap: widget.onRegenerate,
            ),
          ],
          const SizedBox(width: 4),
          VitheyIconButton(
            icon: LucideIcons.share2,
            tooltip: 'Share',
            variant: VitheyIconButtonVariant.neutral,
            iconSize: 20,
            onTap: widget.onShare,
          ),
          const SizedBox(width: 4),
          VitheyIconButton(
            icon: _feedback == true
                ? LucideIcons.thumbsUp
                : LucideIcons.thumbsUp,
            tooltip: 'Like',
            variant: _feedback == true
                ? VitheyIconButtonVariant.primary
                : VitheyIconButtonVariant.neutral,
            iconSize: 20,
            onTap: () => _setFeedback(true),
          ),
          const SizedBox(width: 4),
          VitheyIconButton(
            icon: _feedback == false
                ? LucideIcons.thumbsDown
                : LucideIcons.thumbsDown,
            tooltip: 'Unlike',
            variant: _feedback == false
                ? VitheyIconButtonVariant.primary
                : VitheyIconButtonVariant.neutral,
            iconSize: 20,
            onTap: () => _setFeedback(false),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Sources',
            child: Material(
              color: context.appColors.inputFill,
              borderRadius: BorderRadius.circular(VitheyRadii.iconSquircle),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _showSources(context),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(child: AppLogo(size: 22)),
                ),
              ),
            ),
          ),
          if (widget.message.status == AiMessageStatus.stopped) ...[
            const SizedBox(width: 4),
            Text(
              'Stopped',
              style: context.text.labelMedium,
            ),
          ],
          const Spacer(),
          Text(
            _formatTimestamp(widget.message.createdAt),
            style: context.text.labelSmall,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inHours < 24 &&
        now.day == time.day &&
        now.month == time.month &&
        now.year == time.year) {
      return DateFormat('h:mm a').format(time);
    }
    return RelativeTime.format(time);
  }
}

class _ChatSourceRef {
  const _ChatSourceRef({
    required this.title,
    required this.subtitle,
    this.logoAsset,
    this.icon,
  }) : assert(logoAsset != null || icon != null);

  final String title;
  final String subtitle;
  final String? logoAsset;
  final IconData? icon;
}

const _defaultSources = [
  _ChatSourceRef(
    title: 'Vithey Career Guide',
    subtitle: 'Campus jobs, CV tips, and interview prep',
    logoAsset: AppAssets.logoApp,
  ),
  _ChatSourceRef(
    title: 'Vithey Finance',
    subtitle: 'Student verification and payment guidance',
    icon: LucideIcons.wallet,
  ),
  _ChatSourceRef(
    title: 'Vithey Knowledge Base',
    subtitle: 'In-app help and product documentation',
    logoAsset: AppAssets.logoApp,
  ),
];
