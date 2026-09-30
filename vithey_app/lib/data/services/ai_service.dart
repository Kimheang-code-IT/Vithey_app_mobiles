import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/core/network/dio_client.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/data/models/ai_cv_draft.dart';

/// SSE event from `POST /ai/chat/stream`.
sealed class AiStreamEvent {
  const AiStreamEvent();
}

class AiStreamMeta extends AiStreamEvent {
  const AiStreamMeta({
    required this.sessionId,
    this.requestId,
    this.messageId,
    this.userMessageId,
    this.topic,
  });

  final String sessionId;
  final String? requestId;
  final String? messageId;
  final String? userMessageId;
  final String? topic;
}

class AiStreamToken extends AiStreamEvent {
  const AiStreamToken(this.text);

  final String text;
}

class AiStreamDone extends AiStreamEvent {
  const AiStreamDone({
    required this.sessionId,
    this.messageId,
    this.requestId,
    this.cancelled = false,
  });

  final String sessionId;
  final String? messageId;
  final String? requestId;
  final bool cancelled;
}

class AiStreamError extends AiStreamEvent {
  const AiStreamError(this.message, {this.code});

  final String message;
  final String? code;
}

class AiService {
  AiService(this._api, this._dioClient);

  final ApiService _api;
  final DioClient _dioClient;

  Future<AiChatResponse> sendChat({
    required String message,
    String? sessionId,
    AiTopic? topic,
  }) async {
    final response = await _api.post<AiChatResponse>(
      ApiEndpoints.aiChat,
      data: {
        'message': message,
        if (sessionId != null) 'session_id': sessionId,
        if (topic != null) 'topic': topic.name.toUpperCase(),
      },
      fromJson: (json) {
        final data = json as Map<String, dynamic>;
        return AiChatResponse(
          sessionId: data['session_id']?.toString() ?? sessionId ?? '',
          reply: data['reply'] as String? ?? '',
          reasoning: data['reasoning'] as String?,
          messageId: data['message_id']?.toString(),
          requestId: data['request_id']?.toString(),
        );
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw AiServiceException(response.error?.message ?? 'AI request failed');
    }
    return response.data!;
  }

  /// Live SSE stream for chatbot. Emits [AiStreamMeta], [AiStreamToken]*, then
  /// [AiStreamDone] or [AiStreamError].
  Stream<AiStreamEvent> streamChat({
    required String message,
    String? sessionId,
    AiTopic? topic,
    String? clientMessageId,
    CancelToken? cancelToken,
  }) async* {
    final response = await _dioClient.dio.post<ResponseBody>(
      ApiEndpoints.aiChatStream,
      data: {
        'message': message,
        if (sessionId != null) 'session_id': sessionId,
        if (topic != null) 'topic': topic.name.toUpperCase(),
        if (clientMessageId != null) 'client_message_id': clientMessageId,
      },
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream'},
        receiveTimeout: const Duration(minutes: 5),
      ),
      cancelToken: cancelToken,
    );

    final body = response.data;
    if (body == null) {
      yield const AiStreamError('Empty stream response');
      return;
    }

    final lines = utf8.decoder.bind(body.stream).transform(const LineSplitter());
    String? eventName;
    final dataBuffer = StringBuffer();

    await for (final line in lines) {
      if (line.isEmpty) {
        if (eventName == null && dataBuffer.isEmpty) continue;
        final data = dataBuffer.toString();
        dataBuffer.clear();
        final name = eventName ?? 'message';
        eventName = null;
        final event = _parseSseEvent(name, data);
        if (event != null) {
          yield event;
          if (event is AiStreamDone || event is AiStreamError) return;
        }
        continue;
      }
      if (line.startsWith('event:')) {
        eventName = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        if (dataBuffer.isNotEmpty) dataBuffer.writeln();
        dataBuffer.write(line.substring(5).trimLeft());
      }
    }
  }

  AiStreamEvent? _parseSseEvent(String name, String data) {
    switch (name) {
      case 'meta':
        final json = _tryDecodeMap(data);
        if (json == null) return null;
        return AiStreamMeta(
          sessionId: json['session_id']?.toString() ?? '',
          requestId: json['request_id']?.toString(),
          messageId: json['message_id']?.toString(),
          userMessageId: json['user_message_id']?.toString(),
          topic: json['topic']?.toString(),
        );
      case 'token':
        return AiStreamToken(data);
      case 'done':
        final json = _tryDecodeMap(data) ?? {};
        return AiStreamDone(
          sessionId: json['session_id']?.toString() ?? '',
          messageId: json['message_id']?.toString(),
          requestId: json['request_id']?.toString(),
          cancelled: json['cancelled'] as bool? ?? false,
        );
      case 'error':
        final json = _tryDecodeMap(data);
        return AiStreamError(
          json?['message']?.toString() ?? data,
          code: json?['code']?.toString(),
        );
      default:
        return null;
    }
  }

  Map<String, dynamic>? _tryDecodeMap(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  Future<void> cancelChatRequest(String requestId) async {
    final response = await _api.delete<void>(
      ApiEndpoints.aiCancelChatRequest(requestId),
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw AiServiceException(response.error?.message ?? 'Cancel failed');
    }
  }

  Future<AiChatResponse> regenerateMessage(String messageId) async {
    final response = await _api.post<AiChatResponse>(
      ApiEndpoints.aiRegenerateMessage(messageId),
      data: const {},
      fromJson: (json) {
        final data = json as Map<String, dynamic>;
        return AiChatResponse(
          sessionId: data['session_id']?.toString() ?? '',
          reply: data['reply'] as String? ?? '',
          reasoning: data['reasoning'] as String?,
          messageId: data['message_id']?.toString() ?? messageId,
          requestId: data['request_id']?.toString(),
        );
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw AiServiceException(response.error?.message ?? 'Regenerate failed');
    }
    return response.data!;
  }

  Future<List<AiSession>> fetchSessions({required int page, int limit = 20}) async {
    final response = await _api.get<List<AiSession>>(
      ApiEndpoints.aiSessions,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list.map((item) => _parseSession(item as Map<String, dynamic>)).toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw AiServiceException(response.error?.message ?? 'Failed to load sessions');
    }
    return response.data!;
  }

  Future<List<AiMessage>> fetchMessages({
    required String sessionId,
    required int page,
    int limit = 100,
  }) async {
    final response = await _api.get<List<AiMessage>>(
      ApiEndpoints.aiSessionMessages(sessionId),
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list.map((item) => _parseMessage(item as Map<String, dynamic>, sessionId)).toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw AiServiceException(response.error?.message ?? 'Failed to load messages');
    }
    return response.data!;
  }

  Future<void> deleteSession(String sessionId) async {
    final response = await _api.delete<void>(
      ApiEndpoints.aiSessionById(sessionId),
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw AiServiceException(response.error?.message ?? 'Failed to delete session');
    }
  }

  /// Auto-Create CV via gateway → ai-service → ai_core.
  Future<AiCvDraft> generateCvDraft({
    String? targetRole,
    String? language,
    String? templateId,
  }) async {
    final response = await _api.post<AiCvDraft>(
      ApiEndpoints.aiCvGenerate,
      data: {
        if (targetRole != null && targetRole.trim().isNotEmpty) 'target_role': targetRole.trim(),
        'language': language ?? 'en',
        if (templateId != null && templateId.trim().isNotEmpty) 'template_id': templateId.trim(),
      },
      fromJson: (json) => AiCvDraft.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw AiServiceException(response.error?.message ?? 'CV generate failed');
    }
    return response.data!;
  }

  /// Section rewrite via `POST /ai/cv/suggest`.
  Future<String> suggestCvSection({
    required String section,
    required String originalText,
    String? cvFileId,
  }) async {
    final response = await _api.post<String>(
      ApiEndpoints.aiCvSuggest,
      data: {
        'section': section,
        'original_text': originalText,
        if (cvFileId != null) 'cv_file_id': cvFileId,
      },
      fromJson: (json) {
        final data = json as Map<String, dynamic>;
        return data['suggested_text'] as String? ?? '';
      },
    );
    if (!response.isSuccess || response.data == null || response.data!.isEmpty) {
      throw AiServiceException(response.error?.message ?? 'CV suggest failed');
    }
    return response.data!;
  }

  AiSession _parseSession(Map<String, dynamic> json) {
    return AiSession(
      id: json['session_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Chat',
      topic: _parseTopic(json['topic'] as String?),
      isPinned: json['is_pinned'] as bool? ?? false,
      preview: json['preview'] as String? ?? '',
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  AiMessage _parseMessage(Map<String, dynamic> json, String sessionId) {
    return AiMessage(
      id: json['message_id']?.toString() ?? json['id']?.toString() ?? '',
      sessionId: sessionId,
      role: _parseRole(json['role']),
      content: json['content'] as String? ?? json['text'] as String? ?? '',
      reasoning: json['reasoning'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  AiMessageRole _parseRole(dynamic raw) {
    final value = raw?.toString().toLowerCase() ?? '';
    return value == 'user' ? AiMessageRole.user : AiMessageRole.assistant;
  }

  AiTopic? _parseTopic(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'CV':
        return AiTopic.cv;
      case 'JOB':
        return AiTopic.job;
      case 'INTERVIEW':
        return AiTopic.interview;
      case 'STUDENT':
        return AiTopic.student;
      case 'FINANCE':
        return AiTopic.finance;
      default:
        return null;
    }
  }
}

class AiServiceException implements Exception {
  AiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
