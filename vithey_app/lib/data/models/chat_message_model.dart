import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';

enum ConversationStatus { active, pending, blocked, declined }

enum MessageDeliveryStatus { sending, sent, delivered, read, failed }

class MessageReaction {
  const MessageReaction({
    required this.emoji,
    this.count = 1,
    this.reactedByMe = false,
  });

  final String emoji;
  final int count;
  final bool reactedByMe;

  MessageReaction copyWith({
    int? count,
    bool? reactedByMe,
  }) {
    return MessageReaction(
      emoji: emoji,
      count: count ?? this.count,
      reactedByMe: reactedByMe ?? this.reactedByMe,
    );
  }
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.status = MessageDeliveryStatus.sent,
    this.isOwn = false,
    this.clientId,
    this.isFailed = false,
    this.replyToMessageId,
    this.replyToPreview,
    this.isDeleted = false,
    this.attachments = const [],
    this.reactions = const [],
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final MessageDeliveryStatus status;
  final bool isOwn;
  final String? clientId;
  final bool isFailed;
  final String? replyToMessageId;
  final String? replyToPreview;
  final bool isDeleted;
  final List<ChatAttachment> attachments;
  final List<MessageReaction> reactions;

  ChatMessage copyWith({
    String? id,
    String? text,
    MessageDeliveryStatus? status,
    bool? isFailed,
    DateTime? createdAt,
    bool? isDeleted,
    List<ChatAttachment>? attachments,
    List<MessageReaction>? reactions,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId,
      senderId: senderId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isOwn: isOwn,
      clientId: clientId,
      isFailed: isFailed ?? this.isFailed,
      replyToMessageId: replyToMessageId,
      replyToPreview: replyToPreview,
      isDeleted: isDeleted ?? this.isDeleted,
      attachments: attachments ?? this.attachments,
      reactions: reactions ?? this.reactions,
    );
  }
}

class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.participant,
    required this.lastMessagePreview,
    required this.updatedAt,
    this.unreadCount = 0,
    this.status = ConversationStatus.active,
    this.lastMessageIsOwn = false,
    this.lastMessageStatus = MessageDeliveryStatus.sent,
    this.isTyping = false,
  });

  final String id;
  final ChatParticipant participant;
  final String lastMessagePreview;
  final DateTime updatedAt;
  final int unreadCount;
  final ConversationStatus status;
  final bool lastMessageIsOwn;
  final MessageDeliveryStatus lastMessageStatus;
  final bool isTyping;

  ConversationModel copyWith({
    String? lastMessagePreview,
    DateTime? updatedAt,
    int? unreadCount,
    MessageDeliveryStatus? lastMessageStatus,
    bool? lastMessageIsOwn,
    bool? isTyping,
  }) {
    return ConversationModel(
      id: id,
      participant: participant,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      status: status,
      lastMessageIsOwn: lastMessageIsOwn ?? this.lastMessageIsOwn,
      lastMessageStatus: lastMessageStatus ?? this.lastMessageStatus,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class MessageRequestModel {
  const MessageRequestModel({
    required this.id,
    required this.requester,
    required this.initialMessage,
    required this.createdAt,
  });

  final String id;
  final ChatParticipant requester;
  final String initialMessage;
  final DateTime createdAt;
}
