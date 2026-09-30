import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/code_block_card.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/streaming_markdown.dart';

/// ChatGPT-style auto preview of assistant replies.
///
/// Renders markdown as a formatted preview (headings, lists, tables, code,
/// links) — users never see raw `**` / `#` source. Works for both streaming
/// and finished messages via [GptMarkdown.isStreaming].
class MarkdownMessageBody extends StatelessWidget {
  const MarkdownMessageBody({
    super.key,
    required this.content,
    this.streaming = false,
    this.onCodeCopied,
  });

  final String content;
  final bool streaming;
  final void Function(String code)? onCodeCopied;

  @override
  Widget build(BuildContext context) {
    final raw = content.trimRight();
    final text = streaming ? stabilizeStreamingMarkdown(raw) : raw;
    if (text.isEmpty) return const SizedBox.shrink();

    final colors = context.appColors;
    final scheme = context.scheme;
    final base = context.text.bodyLarge?.copyWith(
      fontSize: 15,
      height: 1.5,
      color: scheme.onSurface,
    );

    return GptMarkdown(
      text,
      style: base,
      // Stream + final both preview as formatted UI (not raw markdown).
      isStreaming: streaming,
      animation: GptMarkdownAnimation.none,
      followLinkColor: true,
      onLinkTap: (url, title) async {
        final uri = Uri.tryParse(url);
        if (uri == null) return;
        if (uri.scheme == 'javascript') return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      onCodeCopy: (code) => onCodeCopied?.call(code),
      codeBuilder: (context, name, code, closed) {
        return CodeBlockCard(
          code: code.trimRight(),
          language: name.isEmpty ? null : name,
          onCopied: () => onCodeCopied?.call(code.trimRight()),
        );
      },
      styleSheet: GptMarkdownStyleSheet(
        codeBlock: CodeBlockStyle(
          backgroundColor: colors.inputFill,
          borderColor: colors.border,
          showCopyButton: false,
        ),
        table: TableStyle(
          borderColor: colors.border,
          borderWidth: 0.6,
          headerBackground: colors.inputFill,
          rowStripeColor: colors.cardSurface,
        ),
        link: LinkStyle(color: scheme.primary),
        blockQuote: BlockQuoteStyle(
          backgroundColor: colors.inputFill,
          barColor: colors.border,
          barWidth: 3,
        ),
      ),
    );
  }
}
