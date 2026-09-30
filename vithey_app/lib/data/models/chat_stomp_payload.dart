enum ChatStompEventType { message, readReceipt, typing, callInvite }

class ChatStompPayload {
  const ChatStompPayload({
    required this.type,
    required this.conversationId,
    this.messageId,
    this.senderId,
    this.text,
    this.status,
    this.createdAt,
    this.isTyping,
    this.readerId,
    this.isVideoCall,
  });

  final ChatStompEventType type;
  final String conversationId;
  final String? messageId;
  final String? senderId;
  final String? text;
  final String? status;
  final DateTime? createdAt;
  final bool? isTyping;
  final String? readerId;
  final bool? isVideoCall;

  factory ChatStompPayload.fromJson(Map<String, dynamic> json) {
    final typeRaw = json['type'] as String? ?? 'MESSAGE';
    final type = switch (typeRaw.toUpperCase()) {
      'READ_RECEIPT' => ChatStompEventType.readReceipt,
      'TYPING' => ChatStompEventType.typing,
      'CALL_INVITE' || 'INCOMING_CALL' => ChatStompEventType.callInvite,
      _ => ChatStompEventType.message,
    };
    return ChatStompPayload(
      type: type,
      conversationId: json['conversation_id']?.toString() ?? '',
      messageId: json['message_id']?.toString(),
      senderId: json['sender_id']?.toString(),
      text: json['text'] as String?,
      status: json['status'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      isTyping: json['is_typing'] as bool?,
      readerId: json['reader_id']?.toString(),
      isVideoCall: json['is_video'] as bool? ?? json['is_video_call'] as bool?,
    );
  }
}
