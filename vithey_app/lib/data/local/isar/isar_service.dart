import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:aub_connect_app/data/local/isar/local_chat_message.dart';
import 'package:aub_connect_app/data/local/isar/local_conversation.dart';
import 'package:aub_connect_app/data/local/isar/pending_outbox_message.dart';

class IsarService {
  Isar? _isar;

  Future<void> init() async {
    if (_isar != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [LocalConversationSchema, LocalChatMessageSchema, PendingOutboxMessageSchema],
      directory: dir.path,
      name: 'vithey_chat',
    );
  }

  Isar get isar {
    final db = _isar;
    if (db == null) throw StateError('IsarService not initialized');
    return db;
  }

  Future<void> clearAll() async {
    await isar.writeTxn(() async {
      await isar.localConversations.clear();
      await isar.localChatMessages.clear();
      await isar.pendingOutboxMessages.clear();
    });
  }

  Stream<List<LocalConversation>> watchConversations() {
    return isar.localConversations
        .where()
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true);
  }

  Future<void> upsertConversation(LocalConversation conversation) async {
    await isar.writeTxn(() async {
      await isar.localConversations.put(conversation);
    });
  }

  Future<void> upsertConversations(List<LocalConversation> conversations) async {
    await isar.writeTxn(() async {
      await isar.localConversations.putAll(conversations);
    });
  }

  Future<void> setUnreadCount(String conversationId, int count) async {
    final existing = await isar.localConversations
        .filter()
        .conversationIdEqualTo(conversationId)
        .findFirst();
    if (existing == null) return;
    existing.unreadCount = count;
    await upsertConversation(existing);
  }

  Future<void> setTyping(String conversationId, bool isTyping) async {
    final existing = await isar.localConversations
        .filter()
        .conversationIdEqualTo(conversationId)
        .findFirst();
    if (existing == null) return;
    existing.isTyping = isTyping;
    await upsertConversation(existing);
  }

  Stream<List<LocalChatMessage>> watchMessages(String conversationId) {
    return isar.localChatMessages
        .filter()
        .conversationIdEqualTo(conversationId)
        .sortByCreatedAt()
        .watch(fireImmediately: true);
  }

  Future<List<LocalChatMessage>> getMessages(
    String conversationId, {
    int limit = 100,
  }) async {
    return isar.localChatMessages
        .filter()
        .conversationIdEqualTo(conversationId)
        .sortByCreatedAt()
        .limit(limit)
        .findAll();
  }

  Future<void> upsertMessage(LocalChatMessage message) async {
    await isar.writeTxn(() async {
      await isar.localChatMessages.put(message);
    });
  }

  Future<void> upsertMessages(List<LocalChatMessage> messages) async {
    await isar.writeTxn(() async {
      await isar.localChatMessages.putAll(messages);
    });
  }

  Future<void> markMessageDeleted(String messageId) async {
    final existing = await isar.localChatMessages
        .filter()
        .messageIdEqualTo(messageId)
        .findFirst();
    if (existing == null) return;
    existing.isDeleted = true;
    existing.text = '';
    await upsertMessage(existing);
  }

  Future<void> enqueueOutbox(PendingOutboxMessage message) async {
    await isar.writeTxn(() async {
      await isar.pendingOutboxMessages.put(message);
    });
  }

  Future<List<PendingOutboxMessage>> pendingOutbox() async {
    return isar.pendingOutboxMessages.where().sortByCreatedAt().findAll();
  }

  Future<void> removeOutbox(String clientId) async {
    await isar.writeTxn(() async {
      await isar.pendingOutboxMessages.filter().clientIdEqualTo(clientId).deleteAll();
    });
  }

  Future<List<LocalChatMessage>> findMessagesByMessageId(String messageId) async {
    return isar.localChatMessages.filter().messageIdEqualTo(messageId).findAll();
  }

  Future<LocalConversation?> getConversationById(String conversationId) async {
    return isar.localConversations.filter().conversationIdEqualTo(conversationId).findFirst();
  }

  Future<List<LocalConversation>> getAllConversations() async {
    return isar.localConversations.where().findAll();
  }

  Future<void> deleteConversation(String conversationId) async {
    await isar.writeTxn(() async {
      await isar.localConversations
          .filter()
          .conversationIdEqualTo(conversationId)
          .deleteAll();
      await isar.localChatMessages
          .filter()
          .conversationIdEqualTo(conversationId)
          .deleteAll();
    });
  }

  Future<List<LocalChatMessage>> searchMessagesByText(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    return isar.localChatMessages
        .filter()
        .isDeletedEqualTo(false)
        .textContains(trimmed, caseSensitive: false)
        .findAll();
  }
}
