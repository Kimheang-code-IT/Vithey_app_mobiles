import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/fixtures/ai_cv_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/ai_feed_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/ai_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/ai_job_match_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/ai_skill_fixtures.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/data/models/ai_cv_draft.dart';
import 'package:aub_connect_app/data/models/ai_career_readiness.dart';
import 'package:aub_connect_app/data/models/ai_feed_recommendation.dart';
import 'package:aub_connect_app/data/models/ai_job_match_result.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';

import 'package:aub_connect_app/data/services/ai_service.dart';

class AiRepository {
  AiRepository(this._aiService, this._flags);

  final AiService _aiService;
  final FeatureFlags _flags;

  bool get useMockApi => _flags.useMockAi;

  /// AI-BOT-04: finance answers may use user context only when the current
  /// user is student-verified (mock: StudentVerificationRepository.isVerified).
  bool get _studentVerified {
    if (!Get.isRegistered<StudentVerificationRepository>()) return false;
    return Get.find<StudentVerificationRepository>().isVerified.value;
  }

  final _mockSessions = <AiSession>[];
  final _mockMessages = <String, List<AiMessage>>{};
  int _sessionCounter = 0;

  /// Auto-Create CV. Live: `POST /ai/cv/generate` via ai-service → ai_core.
  Future<AiCvDraft> generateCvDraft({
    String? targetRole,
    String? language,
    String? templateId,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      return AiCvFixtures.draftForCurrentUser();
    }
    return _aiService.generateCvDraft(
      targetRole: targetRole,
      language: language,
      templateId: templateId,
    );
  }

  /// Mock “Regenerate summary”: reshuffles fixture wording built only from
  /// profile facts (AI-CV-07). Live: `POST /ai/cv/suggest` with section summary.
  Future<String> regenerateCvSummary({
    required int variant,
    String? originalText,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return AiCvFixtures.regeneratedSummary(variant: variant);
    }
    final text = (originalText ?? '').trim();
    if (text.isEmpty) {
      throw AiServiceException('Summary text is required to regenerate');
    }
    return _aiService.suggestCvSection(
      section: 'summary',
      originalText: text,
    );
  }

  /// Block 5 — Job Apply Match Score (AI-JOB-01…06, mock rule-based overlap).
  /// Uses the current user as applicant; `cvFileId` reserved for live matching.
  /// Live: POST /ai/jobs/{jobPostId}/match
  ///
  /// `applicantUserId` targets another applicant (poster-side applicants
  /// list / detail — AI-JOB-08/09); omit it to match the current user.
  Future<AiJobMatchResult> matchJob({
    required String jobPostId,
    String? cvFileId,
    String? applicantUserId,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (applicantUserId != null && applicantUserId != MockIds.currentUser) {
        return AiJobMatchFixtures.match(
          jobPostId: jobPostId,
          applicantUserId: applicantUserId,
        );
      }
      return AiJobMatchFixtures.matchForJob(
        jobPostId: jobPostId,
        cvFileId: cvFileId,
      );
    }
    // Backend POST /ai/jobs/{id}/match not shipped yet — no fake scores in live mode.
    return AiJobMatchResult(
      jobPostId: jobPostId,
      applicantUserId: applicantUserId,
      cvFileId: cvFileId,
      score: 0,
      label: AiJobMatchResult.labelForScore(0),
      matchedSkills: const [],
      gapSkills: const [],
      reasons: const ['Job match scoring is not available on the live API yet.'],
      incompleteProfile: true,
    );
  }

  /// Block 4 — Skill Score / Career readiness (AI-SK-02…04, mock rules).
  /// Live: GET /ai/skills/score (not shipped yet).
  Future<AiCareerReadiness> skillScores({List<ProfileSkill>? skills}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return AiSkillFixtures.readinessForCurrentUser(skills);
    }
    return const AiCareerReadiness(
      overallScore: 0,
      topSkills: [],
      suggestions: [],
    );
  }

  /// Block 2 — Personalized feed ranking (AI-FEED-02…06).
  /// Live: GET /ai/feed/recommendations (not shipped yet).
  Future<List<AiFeedRecommendation>> feedRecommendations({int limit = 20}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return AiFeedFixtures.forYou(limit: limit);
    }
    return const [];
  }

  Future<List<AiSession>> fetchSessions({int page = 1}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      _ensureMockSeed();
      final sorted = List<AiSession>.from(_mockSessions)
        ..sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
      return sorted;
    }
    return _aiService.fetchSessions(page: page);
  }

  Future<List<AiMessage>> fetchMessages({required String sessionId, int page = 1}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _ensureMockSeed();
      return List<AiMessage>.from(_mockMessages[sessionId] ?? []);
    }
    return _aiService.fetchMessages(sessionId: sessionId, page: page);
  }

  Future<AiChatResponse> sendMessage({
    required String message,
    String? sessionId,
    AiTopic? topic,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final sid = sessionId ?? _createMockSession(message, topic);
      final userMsg = AiMessage(
        id: 'u-${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sid,
        role: AiMessageRole.user,
        content: message,
        createdAt: DateTime.now(),
      );
      _mockMessages.putIfAbsent(sid, () => []).add(userMsg);
      final reply = AiFixtures.mockReply(
        message,
        topic,
        isStudentVerified: _studentVerified,
      );
      final reasoning = AiFixtures.mockReasoning(message, topic);
      final assistantMsg = AiMessage(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sid,
        role: AiMessageRole.assistant,
        content: reply,
        reasoning: reasoning,
        createdAt: DateTime.now(),
      );
      _mockMessages[sid]!.add(assistantMsg);
      _updateSessionPreview(sid, message, reply);
      return AiChatResponse(
        sessionId: sid,
        reply: reply,
        reasoning: reasoning,
        messageId: assistantMsg.id,
      );
    }
    return _aiService.sendChat(
      message: message,
      sessionId: sessionId,
      topic: topic ?? _inferTopic(message),
    );
  }

  Future<void> deleteSession(String sessionId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _mockSessions.removeWhere((s) => s.id == sessionId);
      _mockMessages.remove(sessionId);
      return;
    }
    await _aiService.deleteSession(sessionId);
  }

  Future<void> renameSession(String sessionId, String title) async {
    if (useMockApi) {
      final index = _mockSessions.indexWhere((s) => s.id == sessionId);
      if (index >= 0) {
        _mockSessions[index] = _mockSessions[index].copyWith(title: title.trim());
      }
      return;
    }
  }

  Future<void> togglePinSession(String sessionId) async {
    if (useMockApi) {
      final index = _mockSessions.indexWhere((s) => s.id == sessionId);
      if (index >= 0) {
        _mockSessions[index] = _mockSessions[index].copyWith(
          isPinned: !_mockSessions[index].isPinned,
        );
      }
      return;
    }
  }

  Future<AiChatResponse> regenerateMessage({
    required String sessionId,
    required String assistantMessageId,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final history = _mockMessages[sessionId];
      if (history == null) throw AiServiceException('Session not found');
      final index = history.indexWhere((m) => m.id == assistantMessageId);
      if (index < 0) throw AiServiceException('Message not found');
      AiMessage? userMessage;
      for (var i = index - 1; i >= 0; i--) {
        if (history[i].role == AiMessageRole.user) {
          userMessage = history[i];
          break;
        }
      }
      if (userMessage == null) throw AiServiceException('No user message to regenerate from');
      final reply = AiFixtures.mockRegenerateReply(
        userMessage.content,
        isStudentVerified: _studentVerified,
      );
      final reasoning = AiFixtures.mockReasoning(userMessage.content, null);
      final assistantMsg = AiMessage(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        role: AiMessageRole.assistant,
        content: reply,
        reasoning: reasoning,
        createdAt: DateTime.now(),
      );
      history[index] = assistantMsg;
      _updateSessionPreview(sessionId, userMessage.content, reply);
      return AiChatResponse(
        sessionId: sessionId,
        reply: reply,
        reasoning: reasoning,
        messageId: assistantMsg.id,
      );
    }
    return _aiService.regenerateMessage(assistantMessageId);
  }

  /// Live SSE chat stream. Mock callers should keep using [sendMessage].
  Stream<AiStreamEvent> streamMessage({
    required String message,
    String? sessionId,
    AiTopic? topic,
    String? clientMessageId,
    CancelToken? cancelToken,
  }) {
    return _aiService.streamChat(
      message: message,
      sessionId: sessionId,
      topic: topic ?? _inferTopic(message),
      clientMessageId: clientMessageId,
      cancelToken: cancelToken,
    );
  }

  Future<void> cancelChatRequest(String requestId) async {
    if (useMockApi) return;
    await _aiService.cancelChatRequest(requestId);
  }

  String _createMockSession(String firstMessage, AiTopic? topic) {
    _sessionCounter++;
    final id = 'ai-session-$_sessionCounter';
    final title = firstMessage.length > 40 ? '${firstMessage.substring(0, 40)}…' : firstMessage;
    _mockSessions.insert(
      0,
      AiSession(
        id: id,
        title: title.isEmpty ? 'New Chat' : title,
        topic: topic,
        updatedAt: DateTime.now(),
      ),
    );
    _mockMessages[id] = [];
    return id;
  }

  void _updateSessionPreview(String sessionId, String userText, String reply) {
    final index = _mockSessions.indexWhere((s) => s.id == sessionId);
    if (index >= 0) {
      _mockSessions[index] = _mockSessions[index].copyWith(
        preview: reply.length > 60 ? '${reply.substring(0, 60)}…' : reply,
        updatedAt: DateTime.now(),
      );
    }
  }

  AiTopic? _inferTopic(String message) {
    final lower = message.toLowerCase();
    if (RegExp(r'\b(cv|resume)\b').hasMatch(lower)) return AiTopic.cv;
    if (lower.contains('interview')) return AiTopic.interview;
    if (lower.contains('poster') || lower.contains('media') || lower.contains('video')) {
      return AiTopic.media;
    }
    if (RegExp(r'\b(job|apply|application)\b').hasMatch(lower)) return AiTopic.job;
    if (RegExp(r'\b(finance|fee|payment|balance)\b').hasMatch(lower)) return AiTopic.finance;
    if (lower.contains('student')) return AiTopic.student;
    return null;
  }

  void _ensureMockSeed() {
    if (_mockSessions.isNotEmpty) return;
    _mockSessions.addAll(AiFixtures.buildSessions());
    _mockMessages.addAll(
      AiFixtures.buildMessages().map(
        (key, value) => MapEntry(key, List<AiMessage>.from(value)),
      ),
    );
    _sessionCounter = 3;
  }
}
