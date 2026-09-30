/// Chat topics (AI-BOT-02). MEDIA covers poster / video / job-post explainers.
enum AiTopic { cv, job, interview, student, finance, media }

enum AiMessageRole { user, assistant }

enum AiMessageStatus { sending, thinking, streaming, complete, failed, stopped }

enum ChatAttachmentKind { photo, video, file }

class ChatAttachment {
  const ChatAttachment({
    required this.path,
    required this.name,
    required this.kind,
  });

  final String path;
  final String name;
  final ChatAttachmentKind kind;

  bool get isImage => kind == ChatAttachmentKind.photo;
  bool get isVideo => kind == ChatAttachmentKind.video;
}

class AiSession {
  AiSession({
    required this.id,
    required this.title,
    this.topic,
    this.isPinned = false,
    this.preview = '',
    required this.updatedAt,
  });

  final String id;
  final String title;
  final AiTopic? topic;
  final bool isPinned;
  final String preview;
  final DateTime updatedAt;

  AiSession copyWith({
    String? title,
    bool? isPinned,
    String? preview,
    DateTime? updatedAt,
  }) {
    return AiSession(
      id: id,
      title: title ?? this.title,
      topic: topic,
      isPinned: isPinned ?? this.isPinned,
      preview: preview ?? this.preview,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AiMessage {
  AiMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.reasoning,
    this.status = AiMessageStatus.complete,
    required this.createdAt,
    this.clientId,
    this.attachments = const [],
  });

  final String id;
  final String sessionId;
  final AiMessageRole role;
  final String content;
  /// ChatGPT-style hidden thought process shown above the visible reply.
  final String? reasoning;
  final AiMessageStatus status;
  final DateTime createdAt;
  final String? clientId;
  final List<ChatAttachment> attachments;

  bool get isThinking => status == AiMessageStatus.thinking;
  bool get isStreaming => status == AiMessageStatus.streaming;
  bool get isTerminal =>
      status == AiMessageStatus.complete ||
      status == AiMessageStatus.failed ||
      status == AiMessageStatus.stopped;

  AiMessage copyWith({
    String? id,
    String? content,
    String? reasoning,
    AiMessageStatus? status,
    List<ChatAttachment>? attachments,
  }) {
    return AiMessage(
      id: id ?? this.id,
      sessionId: sessionId,
      role: role,
      content: content ?? this.content,
      reasoning: reasoning ?? this.reasoning,
      status: status ?? this.status,
      createdAt: createdAt,
      clientId: clientId,
      attachments: attachments ?? this.attachments,
    );
  }
}

class AiChatResponse {
  const AiChatResponse({
    required this.sessionId,
    required this.reply,
    this.reasoning,
    this.messageId,
    this.requestId,
  });

  final String sessionId;
  final String reply;
  final String? reasoning;
  final String? messageId;
  final String? requestId;
}
