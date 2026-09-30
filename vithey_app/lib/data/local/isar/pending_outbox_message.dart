import 'package:isar/isar.dart';

part 'pending_outbox_message.g.dart';

@collection
class PendingOutboxMessage {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String clientId;

  late String conversationId;
  late String text;
  String? replyToMessageId;
  late DateTime createdAt;
  int attemptCount = 0;
}
