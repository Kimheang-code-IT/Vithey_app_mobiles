import 'dart:async';
import 'dart:convert';

import 'package:aub_connect_app/core/config/app_config.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:aub_connect_app/data/models/chat_stomp_payload.dart';

enum ChatConnectionState { disconnected, connecting, connected }

class ChatStompService {
  ChatStompService(this._flags);

  final FeatureFlags _flags;

  final _events = StreamController<ChatStompPayload>.broadcast();
  final _connection = StreamController<ChatConnectionState>.broadcast();

  StompClient? _client;
  ChatConnectionState _state = ChatConnectionState.disconnected;
  String? _activeConversationId;

  Stream<ChatStompPayload> get events => _events.stream;
  Stream<ChatConnectionState> get connectionState => _connection.stream;
  ChatConnectionState get state => _state;

  bool get useMockChat => _flags.useMockChat;

  void setActiveConversation(String? conversationId) {
    _activeConversationId = conversationId;
  }

  Future<void> connect({String? jwt}) async {
    if (useMockChat) {
      _setState(ChatConnectionState.connected);
      return;
    }
    if (_state == ChatConnectionState.connected) return;

    _setState(ChatConnectionState.connecting);
    final wsBase = AppConfig.instance.wsBaseUrl;

    _client = StompClient(
      config: StompConfig(
        url: wsBase,
        onConnect: (frame) {
          _setState(ChatConnectionState.connected);
          _client?.subscribe(
            destination: '/user/queue/messages',
            callback: (frame) {
              final body = frame.body;
              if (body == null || body.isEmpty) return;
              try {
                final json = jsonDecode(body) as Map<String, dynamic>;
                _events.add(ChatStompPayload.fromJson(json));
              } catch (_) {}
            },
          );
        },
        onWebSocketError: (_) => _setState(ChatConnectionState.disconnected),
        onDisconnect: (_) => _setState(ChatConnectionState.disconnected),
        stompConnectHeaders: jwt != null ? {'Authorization': 'Bearer $jwt'} : {},
        webSocketConnectHeaders: jwt != null ? {'Authorization': 'Bearer $jwt'} : {},
        reconnectDelay: const Duration(seconds: 5),
      ),
    );
    _client?.activate();
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
    _setState(ChatConnectionState.disconnected);
  }

  void sendMessage({
    required String conversationId,
    required String text,
    required String clientMessageId,
    String? replyToMessageId,
  }) {
    if (useMockChat) return;
    _client?.send(
      destination: '/app/chat.send',
      body: jsonEncode({
        'conversation_id': conversationId,
        'text': text,
        'client_message_id': clientMessageId,
        if (replyToMessageId != null) 'reply_to_message_id': replyToMessageId,
      }),
    );
  }

  /// Simulates an inbound message in mock mode (e.g. auto-reply).
  void simulateInbound(ChatStompPayload payload) {
    if (!useMockChat) return;
    _events.add(payload);
  }

  void simulateTyping({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) {
    if (!useMockChat) return;
    _events.add(
      ChatStompPayload(
        type: ChatStompEventType.typing,
        conversationId: conversationId,
        senderId: userId,
        isTyping: isTyping,
      ),
    );
  }

  void simulateIncomingCall({
    required String conversationId,
    required String senderId,
    bool isVideo = false,
  }) {
    if (!useMockChat) return;
    _events.add(
      ChatStompPayload(
        type: ChatStompEventType.callInvite,
        conversationId: conversationId,
        senderId: senderId,
        isVideoCall: isVideo,
        createdAt: DateTime.now(),
      ),
    );
  }

  bool shouldIncrementUnread(String conversationId) {
    return _activeConversationId != conversationId;
  }

  void _setState(ChatConnectionState value) {
    _state = value;
    _connection.add(value);
  }

  void dispose() {
    disconnect();
    _events.close();
    _connection.close();
  }
}
