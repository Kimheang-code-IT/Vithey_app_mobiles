import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

/// Collapsed ChatGPT-style thought process above the visible answer.
class AssistantReasoningBlock extends StatefulWidget {
  const AssistantReasoningBlock({super.key, required this.reasoning});

  final String reasoning;

  @override
  State<AssistantReasoningBlock> createState() =>
      _AssistantReasoningBlockState();
}

class _AssistantReasoningBlockState extends State<AssistantReasoningBlock> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VitheyIcon(
                    _open ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                    size: 16,
                    color: colors.muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _open ? 'Hide reasoning' : 'Thought for a few seconds',
                    style: context.text.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
              child: Text(
                widget.reasoning,
                style: context.text.bodySmall
                    ?.copyWith(height: 1.45, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}
