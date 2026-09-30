import 'package:aub_connect_app/data/models/ai_chat_model.dart';

/// Typed navigation arguments for `/chatbot`.
///
/// Deep-link contract (used by Profile / Apply "Improve" CTAs):
///
/// ```dart
/// Get.toNamed(
///   AppRoutes.chatbot,
///   arguments: ChatbotArgs(
///     initialPrompt: 'Help me improve my CV for this job',
///     topic: AiTopic.cv,
///   ),
/// );
/// ```
///
/// - [initialPrompt] — prefilled (not auto-sent) into the composer so the
///   user can review and edit before sending.
/// - [topic] — preselects the chat topic (CV / JOB / INTERVIEW / STUDENT /
///   FINANCE / MEDIA); may be omitted for general chats.
///
/// Back-compat: passing a plain `String` as arguments still works and is
/// treated as [initialPrompt].
class ChatbotArgs {
  const ChatbotArgs({this.initialPrompt, this.topic});

  final String? initialPrompt;
  final AiTopic? topic;
}
