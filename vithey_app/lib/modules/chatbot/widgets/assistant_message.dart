import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/assistant_reasoning_block.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/assistant_thinking_indicator.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/chatbot_state_views.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/markdown_message_body.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/message_action_row.dart';

/// Flat ChatGPT-style assistant reply (no card / border / shadow).
class AssistantMessage extends StatelessWidget {
  const AssistantMessage({
    super.key,
    required this.message,
    required this.onCopy,
    required this.onShare,
    this.onRegenerate,
    this.onCodeCopied,
  });

  final AiMessage message;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback? onRegenerate;
  final void Function(String code)? onCodeCopied;

  @override
  Widget build(BuildContext context) {
    final showActions = message.isTerminal && message.content.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isThinking)
            AssistantThinkingIndicator(reasoning: message.reasoning)
          else if (message.status == AiMessageStatus.failed)
            ChatbotErrorBubble(message: message.content)
          else ...[
            if (message.reasoning != null &&
                message.reasoning!.trim().isNotEmpty &&
                !message.isThinking)
              AssistantReasoningBlock(reasoning: message.reasoning!),
            if (message.content.isNotEmpty)
              MarkdownMessageBody(
                content: message.content,
                streaming: message.isStreaming,
                onCodeCopied: onCodeCopied,
              ),
            if (message.isStreaming) const _StreamingCaret(),
          ],
          if (showActions)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: MessageActionRow(
                message: message,
                onCopy: onCopy,
                onShare: onShare,
                onRegenerate: onRegenerate,
              ),
            ),
        ],
      ),
    );
  }
}

class _StreamingCaret extends StatefulWidget {
  const _StreamingCaret();

  @override
  State<_StreamingCaret> createState() => _StreamingCaretState();
}

class _StreamingCaretState extends State<_StreamingCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _pulse,
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        width: 8,
        height: 16,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
