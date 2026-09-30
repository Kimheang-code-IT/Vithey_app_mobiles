import 'dart:async';

import 'package:get/get.dart';
import 'package:aub_connect_app/core/alerts/in_app_alert_service.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/data/local/isar/chat_isar_mapper.dart';
import 'package:aub_connect_app/data/local/isar/isar_service.dart';
import 'package:aub_connect_app/data/fixtures/chat_fixtures.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/models/chat_shared_content_model.dart';
import 'package:aub_connect_app/data/models/chat_stomp_payload.dart';
import 'package:aub_connect_app/data/services/chat_service.dart';
import 'package:aub_connect_app/data/services/chat_stomp_service.dart';

class ChatRepository {
  ChatRepository(
    this._chatService,
    this._isar,
    this._stomp,
    this._flags,
  );

  final ChatService _chatService;
  final IsarService _isar;
  final ChatStompService _stomp;
  final FeatureFlags _flags;

  static String get currentUserId {
    if (Get.isRegistered<CurrentUserService>()) {
      return Get.find<CurrentUserService>().userId;
    }
    return MockIdentities.mockUserId;
  }
  String? activeConversationId;

  bool get useMockApi => _flags.useMockChat;

  final _mockMessages = <String, List<ChatMessage>>{};
  final _mockConversations = <ConversationModel>[];

  /// Total unread messages across conversations (home chat icon badge).
  final unreadCount = 0.obs;

  void _refreshUnreadCount([List<ConversationModel>? conversations]) {
    final list = conversations ?? _mockConversations;
    unreadCount.value = list.fold<int>(0, (sum, c) => sum + c.unreadCount);
  }

  /// Seeds mock (if needed) and refreshes [unreadCount] for the home badge.
  Future<void> ensureUnreadBadge() async {
    if (useMockApi) {
      await _ensureMockSeed();
      _refreshUnreadCount();
      return;
    }
    try {
      final list = await fetchConversations();
      _refreshUnreadCount(list);
    } catch (_) {
      // Keep last known count on failure.
    }
  }

  Stream<List<ConversationModel>> watchConversations() {
    return _isar.watchConversations().map(
          (list) => list.map(ChatIsarMapper.fromLocalConversation).toList(),
        );
  }

  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return _isar.watchMessages(conversationId).map(
          (list) => list.map(ChatIsarMapper.fromLocalMessage).toList(),
        );
  }

  Future<void> connectRealtime({String? jwt}) async {
    await _stomp.connect(jwt: jwt);
  }

  void setActiveConversation(String? conversationId) {
    activeConversationId = conversationId;
    _stomp.setActiveConversation(conversationId);
  }

  Future<void> handleStompPayload(ChatStompPayload payload) async {
    switch (payload.type) {
      case ChatStompEventType.typing:
        if (payload.conversationId.isEmpty) return;
        await _isar.setTyping(payload.conversationId, payload.isTyping ?? false);
        return;
      case ChatStompEventType.readReceipt:
        if (payload.messageId == null) return;
        await _markMessageStatus(payload.messageId!, MessageDeliveryStatus.read);
        return;
      case ChatStompEventType.message:
        await _ingestInboundMessage(payload);
        return;
      case ChatStompEventType.callInvite:
        await _handleIncomingCall(payload);
        return;
    }
  }

  Future<void> _ingestInboundMessage(ChatStompPayload payload) async {
    if (payload.conversationId.isEmpty || payload.messageId == null) return;
    final isOwn = payload.senderId == currentUserId;
    final message = ChatMessage(
      id: payload.messageId!,
      conversationId: payload.conversationId,
      senderId: payload.senderId ?? '',
      text: payload.text ?? '',
      createdAt: payload.createdAt ?? DateTime.now(),
      status: _parseStatus(payload.status),
      isOwn: isOwn,
    );
    await _isar.upsertMessage(ChatIsarMapper.toLocalMessage(message));
    final shouldAlert =
        !isOwn && _stomp.shouldIncrementUnread(payload.conversationId);
    await _upsertConversationPreview(
      payload.conversationId,
      preview: message.text,
      isOwn: isOwn,
      incrementUnread: shouldAlert,
    );
    if (shouldAlert) {
      await _showMessageAlert(payload);
    }
  }

  Future<void> _showMessageAlert(ChatStompPayload payload) async {
    if (!Get.isRegistered<InAppAlertService>()) return;
    final conversation = await getConversation(payload.conversationId);
    final participant = conversation?.participant;
    final senderName = participant?.fullName ??
        (payload.senderId != null && payload.senderId!.isNotEmpty
            ? payload.senderId!
            : 'New message');
    await Get.find<InAppAlertService>().showChatMessage(
      conversationId: payload.conversationId,
      senderName: senderName,
      text: payload.text ?? '',
      senderAvatarUrl: participant?.avatarUrl,
      participantId: participant?.id ?? payload.senderId,
      createdAt: payload.createdAt,
    );
  }

  Future<void> _handleIncomingCall(ChatStompPayload payload) async {
    if (payload.conversationId.isEmpty) return;
    if (!Get.isRegistered<InAppAlertService>()) return;
    final conversation = await getConversation(payload.conversationId);
    final participant = conversation?.participant ??
        ChatParticipant(
          id: payload.senderId ?? 'unknown',
          fullName: 'Incoming call',
        );
    await Get.find<InAppAlertService>().showIncomingCall(
      participant: participant,
      conversationId: payload.conversationId,
      isVideo: payload.isVideoCall ?? false,
    );
  }

  /// Mock helper — rings an incoming call banner for [conversationId].
  Future<void> simulateIncomingCall(
    String conversationId, {
    bool isVideo = false,
  }) async {
    if (!useMockApi) return;
    await _ensureMockSeed();
    final conversation = await getConversation(conversationId);
    if (conversation == null) return;
    _stomp.simulateIncomingCall(
      conversationId: conversationId,
      senderId: conversation.participant.id,
      isVideo: isVideo,
    );
  }

  MessageDeliveryStatus _parseStatus(String? raw) {
    return switch (raw?.toUpperCase()) {
      'READ' => MessageDeliveryStatus.read,
      'DELIVERED' => MessageDeliveryStatus.delivered,
      'SENT' => MessageDeliveryStatus.sent,
      _ => MessageDeliveryStatus.delivered,
    };
  }

  Future<void> _markMessageStatus(String messageId, MessageDeliveryStatus status) async {
    final messages = await _isar.findMessagesByMessageId(messageId);
    for (final local in messages) {
      local.status = status.name;
      await _isar.upsertMessage(local);
    }
  }

  Future<List<ConversationModel>> fetchConversations({int page = 1}) async {
    List<ConversationModel> remote;
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      await _ensureMockSeed();
      remote = List<ConversationModel>.from(_mockConversations);
    } else {
      remote = await _chatService.fetchConversations(page: page);
    }
    await _isar.upsertConversations(remote.map(ChatIsarMapper.toLocalConversation).toList());
    _refreshUnreadCount(remote);
    return remote;
  }

  Future<List<MessageRequestModel>> fetchMessageRequests() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return ChatFixtures.buildMessageRequests();
    }
    return _chatService.fetchMessageRequests();
  }

  Future<List<ChatParticipant>> fetchRecentContacts() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return ChatFixtures.recentContacts();
    }
    return [];
  }

  Future<List<ChatMessage>> fetchMessages({
    required String conversationId,
    int page = 1,
  }) async {
    List<ChatMessage> remote;
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await _ensureMockSeed();
      remote = List<ChatMessage>.from(_mockMessages[conversationId] ?? []);
    } else {
      remote = await _chatService.fetchMessages(conversationId: conversationId, page: page);
    }
    await _isar.upsertMessages(remote.map(ChatIsarMapper.toLocalMessage).toList());
    return remote;
  }

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    String? clientId,
    String? replyToMessageId,
    String? replyToPreview,
  }) async {
    final cid = clientId ?? 'client-${DateTime.now().millisecondsSinceEpoch}';
    await _isar.enqueueOutbox(
      ChatIsarMapper.toOutbox(
        clientId: cid,
        conversationId: conversationId,
        text: text,
        replyToMessageId: replyToMessageId,
      ),
    );

    ChatMessage saved;
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      saved = ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: currentUserId,
        text: text,
        createdAt: DateTime.now(),
        status: MessageDeliveryStatus.sent,
        isOwn: true,
        clientId: cid,
        replyToMessageId: replyToMessageId,
        replyToPreview: replyToPreview,
      );
      _mockMessages.putIfAbsent(conversationId, () => []).add(saved);
      _updateMockConversationPreview(conversationId, text, isOwn: true);
      _simulateMockReply(conversationId);
    } else {
      saved = await _chatService.sendMessage(
        conversationId: conversationId,
        text: text,
        clientId: cid,
        replyToMessageId: replyToMessageId,
      );
      _stomp.sendMessage(
        conversationId: conversationId,
        text: text,
        clientMessageId: cid,
        replyToMessageId: replyToMessageId,
      );
    }

    await _isar.upsertMessage(ChatIsarMapper.toLocalMessage(saved));
    await _isar.removeOutbox(cid);
    await _upsertConversationPreview(conversationId, preview: text, isOwn: true);
    return saved;
  }

  void _simulateMockReply(String conversationId) {
    final conv = _mockConversations.where((c) => c.id == conversationId).toList();
    if (conv.isEmpty) return;
    final participant = conv.first.participant;
    _stomp.simulateTyping(
      conversationId: conversationId,
      userId: participant.id,
      isTyping: true,
    );
    Future<void>.delayed(const Duration(seconds: 2), () async {
      _stomp.simulateTyping(
        conversationId: conversationId,
        userId: participant.id,
        isTyping: false,
      );
      final replyText = 'Thanks for your message! I will get back to you soon.';
      final reply = ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: participant.id,
        text: replyText,
        createdAt: DateTime.now(),
        status: MessageDeliveryStatus.delivered,
      );
      _mockMessages.putIfAbsent(conversationId, () => []).add(reply);
      _updateMockConversationPreview(conversationId, replyText, isOwn: false);
      _stomp.simulateInbound(
        ChatStompPayload(
          type: ChatStompEventType.message,
          conversationId: conversationId,
          messageId: reply.id,
          senderId: participant.id,
          text: replyText,
          status: 'DELIVERED',
          createdAt: reply.createdAt,
        ),
      );
    });
    // Second ping after the user likely left the thread — guarantees a heads-up demo.
    Future<void>.delayed(const Duration(seconds: 6), () {
      if (!_stomp.shouldIncrementUnread(conversationId)) return;
      _stomp.simulateInbound(
        ChatStompPayload(
          type: ChatStompEventType.message,
          conversationId: conversationId,
          messageId: 'msg-${DateTime.now().millisecondsSinceEpoch}-ping',
          senderId: participant.id,
          text: 'Are you free for a quick call?',
          status: 'DELIVERED',
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  Future<void> deleteMessage(String messageId) async {
    await _isar.markMessageDeleted(messageId);
    if (useMockApi) {
      for (final list in _mockMessages.values) {
        final index = list.indexWhere((m) => m.id == messageId);
        if (index >= 0) {
          list[index] = list[index].copyWith(isDeleted: true, text: '');
        }
      }
    }
  }

  Future<void> markMessageRead(String messageId) async {
    await _markMessageStatus(messageId, MessageDeliveryStatus.read);
    if (!useMockApi) {
      await _chatService.markMessageRead(messageId);
    }
  }

  Future<ConversationModel?> getConversation(String conversationId) async {
    if (useMockApi) {
      await _ensureMockSeed();
      try {
        return _mockConversations.firstWhere((c) => c.id == conversationId);
      } catch (_) {
        return null;
      }
    }
    final local = await _isar.getConversationById(conversationId);
    if (local != null) return ChatIsarMapper.fromLocalConversation(local);
    return null;
  }

  Future<ChatParticipant?> getParticipant({
    required String conversationId,
    required String participantId,
  }) async {
    final conversation = await getConversation(conversationId);
    if (conversation != null && conversation.participant.id == participantId) {
      final p = conversation.participant;
      return ChatParticipant(
        id: p.id,
        fullName: p.fullName,
        avatarUrl: p.avatarUrl,
        bio: _bioFor(p.id),
        phone: _phoneFor(p.id),
        location: p.id == 'author-1' ? 'Phnom Penh' : null,
        isOnline: p.isOnline,
        lastSeenAt: p.lastSeenAt,
      );
    }
    return null;
  }

  String? _bioFor(String id) {
    switch (id) {
      case 'author-1':
        return 'Main character of my life is no one else but me.';
      case 'author-5':
        return 'Business student at AUB.';
      case 'author-6':
        return 'Software engineering student.';
      case 'author-7':
        return 'Campus ambassador and event volunteer.';
      default:
        return null;
    }
  }

  String? _phoneFor(String id) {
    if (id == 'author-1') return '+855 123 4442';
    return null;
  }

  Future<void> markConversationRead(String conversationId) async {
    await _isar.setUnreadCount(conversationId, 0);
    if (useMockApi) {
      final index = _mockConversations.indexWhere((c) => c.id == conversationId);
      if (index >= 0) {
        _mockConversations[index] = _mockConversations[index].copyWith(unreadCount: 0);
      }
      _refreshUnreadCount();
    } else {
      await ensureUnreadBadge();
    }
  }

  Future<String> findOrCreateConversation(String participantId) async {
    if (useMockApi) {
      await _ensureMockSeed();
      final existing = _mockConversations.where((c) => c.participant.id == participantId);
      if (existing.isNotEmpty) return existing.first.id;
      final contact = (await fetchRecentContacts()).firstWhere(
        (c) => c.id == participantId,
        orElse: () => ChatParticipant(id: participantId, fullName: 'New Contact'),
      );
      final id = 'conv-new-${DateTime.now().millisecondsSinceEpoch}';
      final conv = ConversationModel(
        id: id,
        participant: contact,
        lastMessagePreview: '',
        updatedAt: DateTime.now(),
      );
      _mockConversations.insert(0, conv);
      _mockMessages[id] = [];
      await _isar.upsertConversation(ChatIsarMapper.toLocalConversation(conv));
      return id;
    }
    final existing = await _isar.getAllConversations();
    for (final local in existing) {
      if (local.participantId == participantId) return local.conversationId;
    }
    try {
      final remote = await _chatService.fetchConversations(page: 1);
      final match = remote.where((c) => c.participant.id == participantId);
      if (match.isNotEmpty) {
        final conv = match.first;
        await _isar.upsertConversation(ChatIsarMapper.toLocalConversation(conv));
        return conv.id;
      }
    } catch (_) {
      // Fall through to create a request.
    }
    final created = await _chatService.createConversationRequest(
      toUserId: participantId,
      initialMessage: 'Hi',
    );
    await _isar.upsertConversation(ChatIsarMapper.toLocalConversation(created));
    return created.id;
  }

  Future<void> acceptMessageRequest(String requestId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return;
    }
    await _chatService.acceptConversation(requestId);
  }

  Future<void> declineMessageRequest(String requestId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return;
    }
    await _chatService.declineConversation(requestId);
  }

  Future<void> blockConversation(String conversationId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _mockConversations.removeWhere((c) => c.id == conversationId);
      return;
    }
    await _chatService.blockConversation(conversationId);
    await _isar.deleteConversation(conversationId);
  }

  Future<void> reportUser(String userId, String reason) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return;
    }
    await _chatService.reportUser(userId, reason: reason);
  }

  Future<void> clearCache() => _isar.clearAll();

  Future<void> _upsertConversationPreview(
    String conversationId, {
    required String preview,
    required bool isOwn,
    bool incrementUnread = false,
  }) async {
    final existing = await _isar.getConversationById(conversationId);
    if (existing != null) {
      existing.lastMessagePreview = preview;
      existing.updatedAt = DateTime.now();
      existing.lastMessageIsOwn = isOwn;
      existing.lastMessageStatus = isOwn ? MessageDeliveryStatus.sent.name : MessageDeliveryStatus.delivered.name;
      existing.isTyping = false;
      if (incrementUnread) existing.unreadCount += 1;
      await _isar.upsertConversation(existing);
      if (incrementUnread) {
        if (useMockApi) {
          final index =
              _mockConversations.indexWhere((c) => c.id == conversationId);
          if (index >= 0) {
            _mockConversations[index] = _mockConversations[index].copyWith(
              unreadCount: _mockConversations[index].unreadCount + 1,
              lastMessagePreview: preview,
              updatedAt: DateTime.now(),
              lastMessageIsOwn: isOwn,
            );
          }
          _refreshUnreadCount();
        } else {
          unreadCount.value = unreadCount.value + 1;
        }
      }
      return;
    }
    if (useMockApi) {
      _updateMockConversationPreview(conversationId, preview, isOwn: isOwn);
    }
  }

  void _updateMockConversationPreview(String conversationId, String preview, {required bool isOwn}) {
    final index = _mockConversations.indexWhere((c) => c.id == conversationId);
    if (index >= 0) {
      _mockConversations[index] = _mockConversations[index].copyWith(
        lastMessagePreview: preview,
        updatedAt: DateTime.now(),
        lastMessageIsOwn: isOwn,
        lastMessageStatus: MessageDeliveryStatus.sent,
        unreadCount: isOwn ? 0 : _mockConversations[index].unreadCount,
      );
      final item = _mockConversations.removeAt(index);
      _mockConversations.insert(0, item);
    }
  }

  Future<void> _ensureMockSeed() async {
    final fixtures = ChatFixtures.buildConversations();
    final seededMessages =
        ChatFixtures.buildMessages(currentUserId: currentUserId);

    if (_mockConversations.isEmpty) {
      _mockConversations.addAll(fixtures);
    } else {
      for (final conv in fixtures) {
        if (!_mockConversations.any((c) => c.id == conv.id)) {
          _mockConversations.add(conv);
        }
      }
    }

    for (final entry in seededMessages.entries) {
      _mockMessages.putIfAbsent(
        entry.key,
        () => List<ChatMessage>.from(entry.value),
      );
    }

    await _isar.upsertConversations(
      _mockConversations.map(ChatIsarMapper.toLocalConversation).toList(),
    );
    for (final entry in _mockMessages.entries) {
      await _isar.upsertMessages(
        entry.value.map(ChatIsarMapper.toLocalMessage).toList(),
      );
    }
  }

  Future<ChatSharedContent> fetchSharedContent(String conversationId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final parsed = _parseSharedContentFromMessages(
        List<ChatMessage>.from(_mockMessages[conversationId] ?? []),
      );
      if (_hasSharedItems(parsed)) return parsed;
      return _mockSharedContent();
    }

    final messages = await fetchMessages(conversationId: conversationId);
    return _parseSharedContentFromMessages(messages);
  }

  bool _hasSharedItems(ChatSharedContent content) {
    return content.imageUrls.isNotEmpty ||
        content.videoUrls.isNotEmpty ||
        content.files.isNotEmpty ||
        content.links.isNotEmpty;
  }

  ChatSharedContent _mockSharedContent() => ChatFixtures.sharedContent();

  ChatSharedContent _parseSharedContentFromMessages(List<ChatMessage> messages) {
    final imageUrls = <String>{};
    final videoUrls = <String>{};
    final files = <ChatSharedFile>[];
    final links = <ChatSharedLink>[];
    final urlPattern = RegExp(r'https?://[^\s]+', caseSensitive: false);

    for (final message in messages) {
      if (message.isDeleted || message.text.trim().isEmpty) continue;
      final text = message.text.trim();
      final matches = urlPattern.allMatches(text);
      if (matches.isEmpty) {
        if (text.toLowerCase().endsWith('.pdf')) {
          files.add(
            ChatSharedFile(
              name: text.split('/').last,
              sizeLabel: '—',
              sharedAt: message.createdAt,
            ),
          );
        }
        continue;
      }

      for (final match in matches) {
        final url = match.group(0)!.replaceAll(RegExp(r'[),.;]+$'), '');
        final lower = url.toLowerCase();
        if (_isImageUrl(lower)) {
          imageUrls.add(url);
        } else if (_isVideoUrl(lower)) {
          videoUrls.add(url);
        } else if (lower.contains('.pdf')) {
          files.add(
            ChatSharedFile(
              name: Uri.parse(url).pathSegments.isNotEmpty ? Uri.parse(url).pathSegments.last : 'document.pdf',
              sizeLabel: '—',
              sharedAt: message.createdAt,
              downloadUrl: url,
            ),
          );
        } else {
          links.add(
            ChatSharedLink(
              url: url,
              sharedAt: message.createdAt,
              title: Uri.tryParse(url)?.host ?? 'Link',
              description: text.length > url.length ? text.replaceAll(url, '').trim() : null,
            ),
          );
        }
      }
    }

    return ChatSharedContent(
      imageUrls: imageUrls.toList(),
      videoUrls: videoUrls.toList(),
      files: files,
      links: links,
    );
  }

  bool _isImageUrl(String lowerUrl) {
    return lowerUrl.contains('.png') ||
        lowerUrl.contains('.jpg') ||
        lowerUrl.contains('.jpeg') ||
        lowerUrl.contains('.webp') ||
        lowerUrl.contains('.gif');
  }

  bool _isVideoUrl(String lowerUrl) {
    return lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('youtube.com') ||
        lowerUrl.contains('youtu.be');
  }

  /// Latest matching message snippet per conversation for chat list search.
  Future<Map<String, String>> searchMessageSnippets(String query) async {
    final q = query.trim();
    if (q.isEmpty) return {};

    List<ChatMessage> matches;
    if (useMockApi) {
      await _ensureMockSeed();
      matches = <ChatMessage>[];
      for (final messages in _mockMessages.values) {
        matches.addAll(
          messages.where((m) => !m.isDeleted && _textMatches(m.text, q)),
        );
      }
    } else {
      final local = await _isar.searchMessagesByText(q);
      matches = local.map(ChatIsarMapper.fromLocalMessage).toList();
    }

    matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final snippets = <String, String>{};
    for (final message in matches) {
      snippets.putIfAbsent(
        message.conversationId,
        () => _messageSearchSnippet(message.text, q),
      );
    }
    return snippets;
  }

  bool _textMatches(String text, String query) {
    return text.toLowerCase().contains(query.toLowerCase());
  }

  String _messageSearchSnippet(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);
    if (index < 0) return text;

    const window = 28;
    final start = (index - window).clamp(0, text.length);
    final end = (index + lowerQuery.length + window).clamp(0, text.length);
    var snippet = text.substring(start, end).trim();
    if (start > 0) snippet = '…$snippet';
    if (end < text.length) snippet = '$snippet…';
    return snippet;
  }
}
