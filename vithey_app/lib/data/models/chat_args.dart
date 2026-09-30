class ChatDetailArgs {
  const ChatDetailArgs({required this.conversationId});

  final String conversationId;

  static ChatDetailArgs from(dynamic arguments) {
    if (arguments is ChatDetailArgs) return arguments;
    if (arguments is String && arguments.isNotEmpty) {
      return ChatDetailArgs(conversationId: arguments);
    }
    throw ArgumentError('ChatDetailArgs requires conversationId');
  }
}

class ChatProfileArgs {
  const ChatProfileArgs({
    required this.conversationId,
    required this.participantId,
  });

  final String conversationId;
  final String participantId;
}

class NewChatArgs {
  const NewChatArgs({required this.participantId, this.participantName});

  final String participantId;
  final String? participantName;
}
