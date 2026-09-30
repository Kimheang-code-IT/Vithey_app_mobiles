import 'package:aub_connect_app/data/local/isar/local_chat_message.dart';
import 'package:aub_connect_app/data/local/isar/local_conversation.dart';
import 'package:aub_connect_app/data/local/isar/pending_outbox_message.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';

class ChatIsarMapper {
  static LocalConversation toLocalConversation(ConversationModel model) {
    return LocalConversation()
      ..conversationId = model.id
      ..participantId = model.participant.id
      ..participantName = model.participant.fullName
      ..participantAvatarUrl = model.participant.avatarUrl
      ..participantIsOnline = model.participant.isOnline
      ..lastMessagePreview = model.lastMessagePreview
      ..updatedAt = model.updatedAt
      ..unreadCount = model.unreadCount
      ..status = model.status.name
      ..lastMessageIsOwn = model.lastMessageIsOwn
      ..lastMessageStatus = model.lastMessageStatus.name
      ..isTyping = model.isTyping
      ..lastSyncedAt = DateTime.now();
  }

  static ConversationModel fromLocalConversation(LocalConversation local) {
    return ConversationModel(
      id: local.conversationId,
      participant: ChatParticipant(
        id: local.participantId,
        fullName: local.participantName,
        avatarUrl: local.participantAvatarUrl,
        isOnline: local.participantIsOnline,
      ),
      lastMessagePreview: local.isTyping ? 'Typing…' : local.lastMessagePreview,
      updatedAt: local.updatedAt,
      unreadCount: local.unreadCount,
      status: ConversationStatus.values.firstWhere(
        (s) => s.name == local.status,
        orElse: () => ConversationStatus.active,
      ),
      lastMessageIsOwn: local.lastMessageIsOwn,
      lastMessageStatus: MessageDeliveryStatus.values.firstWhere(
        (s) => s.name == local.lastMessageStatus,
        orElse: () => MessageDeliveryStatus.sent,
      ),
      isTyping: local.isTyping,
    );
  }

  static LocalChatMessage toLocalMessage(ChatMessage message) {
    return LocalChatMessage()
      ..messageId = message.id
      ..conversationId = message.conversationId
      ..senderId = message.senderId
      ..text = message.isDeleted ? '' : message.text
      ..createdAt = message.createdAt
      ..status = message.status.name
      ..isOwn = message.isOwn
      ..clientId = message.clientId
      ..replyToMessageId = message.replyToMessageId
      ..replyToPreview = message.replyToPreview
      ..isDeleted = message.isDeleted
      ..isFailed = message.isFailed;
  }

  static ChatMessage fromLocalMessage(LocalChatMessage local) {
    return ChatMessage(
      id: local.messageId,
      conversationId: local.conversationId,
      senderId: local.senderId,
      text: local.isDeleted ? 'This message was deleted' : local.text,
      createdAt: local.createdAt,
      status: MessageDeliveryStatus.values.firstWhere(
        (s) => s.name == local.status,
        orElse: () => MessageDeliveryStatus.sent,
      ),
      isOwn: local.isOwn,
      clientId: local.clientId,
      replyToMessageId: local.replyToMessageId,
      replyToPreview: local.replyToPreview,
      isDeleted: local.isDeleted,
      isFailed: local.isFailed,
    );
  }

  static PendingOutboxMessage toOutbox({
    required String clientId,
    required String conversationId,
    required String text,
    String? replyToMessageId,
  }) {
    return PendingOutboxMessage()
      ..clientId = clientId
      ..conversationId = conversationId
      ..text = text
      ..replyToMessageId = replyToMessageId
      ..createdAt = DateTime.now();
  }
}
