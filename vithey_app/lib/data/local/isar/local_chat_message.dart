import 'package:isar/isar.dart';

part 'local_chat_message.g.dart';

@collection
class LocalChatMessage {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String messageId;

  @Index()
  late String conversationId;

  late String senderId;
  late String text;
  late DateTime createdAt;
  late String status;
  bool isOwn = false;
  String? clientId;
  String? replyToMessageId;
  String? replyToPreview;
  bool isDeleted = false;
  bool isFailed = false;
}
