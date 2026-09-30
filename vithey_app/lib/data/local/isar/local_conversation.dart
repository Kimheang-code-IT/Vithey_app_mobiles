import 'package:isar/isar.dart';

part 'local_conversation.g.dart';

@collection
class LocalConversation {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String conversationId;

  late String participantId;
  late String participantName;
  String? participantAvatarUrl;
  bool participantIsOnline = false;
  DateTime? participantLastSeenAt;

  late String lastMessagePreview;
  late DateTime updatedAt;
  int unreadCount = 0;
  late String status;
  bool lastMessageIsOwn = false;
  late String lastMessageStatus;
  bool isTyping = false;
  DateTime? lastSyncedAt;
}
