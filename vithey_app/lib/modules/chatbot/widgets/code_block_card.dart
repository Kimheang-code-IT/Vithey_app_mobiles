import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Code answer card: soft radius-18 card with a header chrome bar and a
/// ghost copy button.
class CodeBlockCard extends StatelessWidget {
  const CodeBlockCard({
    super.key,
    required this.code,
    this.language,
    this.onCopied,
  });

  final String code;
  final String? language;
  final VoidCallback? onCopied;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: code));
    onCopied?.call();
  }

  @override
  Widget build(BuildContext context) {
    final label = (language == null || language!.isEmpty) ? 'code' : language!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: context.appColors.inputFill,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        border: Border.all(color: context.appColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
            decoration: BoxDecoration(
              color: context.appColors.cardSurface,
              border: Border(
                bottom: BorderSide(color: context.appColors.border),
              ),
            ),
            child: Row(
              children: [
                VitheyIcon(
                  LucideIcons.terminal,
                  size: 15,
                  color: context.appColors.muted,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: context.text.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                _GhostCopyButton(onTap: _copy),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(14),
            child: SelectableText(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ghost icon button with chrome — soft surface wash + subtle border.
class _GhostCopyButton extends StatelessWidget {
  const _GhostCopyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Copy code',
      child: Material(
        color: context.appColors.inputFill,
        borderRadius: BorderRadius.circular(VitheyRadii.iconSquircle),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox(
            width: 44,
            height: 44,
            child: VitheyIcon(LucideIcons.copy, size: 20),
          ),
        ),
      ),
    );
  }
}
