import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_field.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/data/repositories/ai_repository.dart';
import 'package:aub_connect_app/data/services/ai_service.dart';
import 'package:aub_connect_app/modules/chatbot/chatbot_args.dart';
import 'package:aub_connect_app/modules/chatbot/utils/ai_api_error.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/streaming_markdown.dart';

class ChatbotController extends GetxController {
  ChatbotController(this._aiRepository);

  final AiRepository _aiRepository;
  final _imagePicker = ImagePicker();
  GlobalKey<ScaffoldState>? scaffoldKey;

  final sessions = <AiSession>[].obs;
  final messages = <AiMessage>[].obs;
  final isLoadingSessions = false.obs;
  final isLoadingMessages = false.obs;
  final isGenerating = false.obs;
  final showJumpToLatest = false.obs;
  final pendingAttachments = <ChatAttachment>[].obs;

  final inputController = TextEditingController();
  final scrollController = ScrollController();

  String? _currentSessionId;
  AiTopic? _selectedTopic;
  final _drafts = <String, String>{};
  int _requestToken = 0;
  bool _sendLocked = false;
  String? _activeStreamRequestId;
  CancelToken? _streamCancelToken;

  static const starterPrompts = [
    'Help me write a CV',
    'How do I apply for this job?',
    'Test my Flutter skills',
  ];

  bool get hasMessages => messages.isNotEmpty;
  String? get currentSessionId => _currentSessionId;
  bool get hasPendingAttachments => pendingAttachments.isNotEmpty;

  List<AiSession> get pinnedSessions =>
      sessions.where((s) => s.isPinned).toList();
  List<AiSession> get recentSessions =>
      sessions.where((s) => !s.isPinned).toList();

  List<AiSession> get sortedSessions {
    final list = List<AiSession>.from(sessions);
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    loadSessions();
    scrollController.addListener(_onScroll);
    _applyNavigationArguments(Get.arguments);
  }

  /// Accepts [ChatbotArgs] (typed deep-link from Profile/Apply "Improve")
  /// or a plain String prompt for backwards compatibility.
  void _applyNavigationArguments(dynamic args) {
    String? prompt;
    AiTopic? topic;
    if (args is ChatbotArgs) {
      prompt = args.initialPrompt?.trim();
      topic = args.topic;
    } else if (args is String) {
      prompt = args.trim();
    }
    if (topic != null) _selectedTopic = topic;
    if (prompt != null && prompt.isNotEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => fillStarterPrompt(prompt!));
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final max = scrollController.position.maxScrollExtent;
    final offset = scrollController.offset;
    showJumpToLatest.value = max - offset > 120;
  }

  bool get _isNearBottom {
    if (!scrollController.hasClients) return true;
    final max = scrollController.position.maxScrollExtent;
    final offset = scrollController.offset;
    return max - offset < 120;
  }

  Future<void> loadSessions() async {
    isLoadingSessions.value = true;
    try {
      sessions.assignAll(await _aiRepository.fetchSessions());
    } catch (e) {
      Get.snackbar(AppStrings.appName, aiApiErrorMessage(e));
    } finally {
      isLoadingSessions.value = false;
    }
  }

  void bindScaffold(GlobalKey<ScaffoldState> key) => scaffoldKey = key;

  void unbindScaffold(GlobalKey<ScaffoldState> key) {
    if (identical(scaffoldKey, key)) scaffoldKey = null;
  }

  void openDrawer() => scaffoldKey?.currentState?.openDrawer();

  void closeDrawer() => scaffoldKey?.currentState?.closeDrawer();

  Future<void> openAttachmentMenu() async {
    if (isGenerating.value) return;
    final choice = await Get.bottomSheet<String>(
      SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Get.theme.dividerColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              ListTile(
                leading: const VitheyIcon(LucideIcons.image),
                title: const Text('Photo'),
                onTap: () => Get.back(result: 'photo'),
              ),
              ListTile(
                leading: const VitheyIcon(LucideIcons.video),
                title: const Text('Video'),
                onTap: () => Get.back(result: 'video'),
              ),
              ListTile(
                leading: const VitheyIcon(LucideIcons.paperclip),
                title: const Text('File'),
                onTap: () => Get.back(result: 'file'),
              ),
            ],
          ),
        ),
      ),
    );

    switch (choice) {
      case 'photo':
        await pickPhoto();
      case 'video':
        await pickVideo();
      case 'file':
        await pickFile();
    }
  }

  Future<void> pickPhoto() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      _addAttachment(
        ChatAttachment(
          path: picked.path,
          name: picked.name,
          kind: ChatAttachmentKind.photo,
        ),
      );
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not pick photo');
    }
  }

  Future<void> pickVideo() async {
    try {
      final picked = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (picked == null) return;
      _addAttachment(
        ChatAttachment(
          path: picked.path,
          name: picked.name,
          kind: ChatAttachmentKind.video,
        ),
      );
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not pick video');
    }
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final path = file.path;
      if (path == null || path.isEmpty) {
        Get.snackbar(AppStrings.appName, 'Could not read that file');
        return;
      }
      final name = file.name;
      final lower = name.toLowerCase();
      final kind = (lower.endsWith('.png') ||
              lower.endsWith('.jpg') ||
              lower.endsWith('.jpeg') ||
              lower.endsWith('.gif') ||
              lower.endsWith('.webp'))
          ? ChatAttachmentKind.photo
          : (lower.endsWith('.mp4') ||
                  lower.endsWith('.mov') ||
                  lower.endsWith('.avi') ||
                  lower.endsWith('.mkv'))
              ? ChatAttachmentKind.video
              : ChatAttachmentKind.file;
      _addAttachment(ChatAttachment(path: path, name: name, kind: kind));
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not pick file');
    }
  }

  void _addAttachment(ChatAttachment attachment) {
    if (pendingAttachments.length >= 5) {
      Get.snackbar(AppStrings.appName, 'You can attach up to 5 items');
      return;
    }
    if (pendingAttachments.any((a) => a.path == attachment.path)) return;
    pendingAttachments.add(attachment);
  }

  void removePendingAttachment(ChatAttachment attachment) {
    pendingAttachments.removeWhere((a) => a.path == attachment.path);
  }

  void clearPendingAttachments() => pendingAttachments.clear();

  void newChat() {
    // Cancel any in-flight stream so the empty chat can send again.
    if (isGenerating.value) {
      _requestToken++;
      isGenerating.value = false;
      _sendLocked = false;
    }
    _saveDraft();
    _currentSessionId = null;
    _selectedTopic = null;
    messages.clear();
    inputController.clear();
    clearPendingAttachments();
    isLoadingMessages.value = false;
    closeDrawer();
  }

  Future<void> selectSession(String sessionId) async {
    if (_currentSessionId == sessionId) {
      closeDrawer();
      return;
    }
    _saveDraft();
    _currentSessionId = sessionId;
    final token = ++_requestToken;
    isLoadingMessages.value = true;
    messages.clear();
    clearPendingAttachments();
    inputController.text = _drafts[sessionId] ?? '';
    closeDrawer();
    try {
      final loaded = await _aiRepository.fetchMessages(sessionId: sessionId);
      if (token != _requestToken) return;
      messages.assignAll(loaded);
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    } catch (e) {
      if (token != _requestToken) return;
      Get.snackbar(AppStrings.appName, aiApiErrorMessage(e));
    } finally {
      if (token == _requestToken) isLoadingMessages.value = false;
    }
  }

  void fillStarterPrompt(String prompt) {
    inputController.text = prompt;
    inputController.selection = TextSelection.collapsed(offset: prompt.length);
  }

  Future<void> sendStarterPrompt(String prompt) async {
    fillStarterPrompt(prompt);
    await sendMessage();
  }

  Future<void> sendMessage() async {
    final text = inputController.text.trim();
    final attachments = List<ChatAttachment>.from(pendingAttachments);
    if ((text.isEmpty && attachments.isEmpty) ||
        _sendLocked ||
        isGenerating.value) {
      return;
    }

    _sendLocked = true;
    isGenerating.value = true;
    final clientId = 'client-${DateTime.now().millisecondsSinceEpoch}';
    final token = ++_requestToken;

    final displayContent = text;
    final apiMessage = _buildApiMessage(text, attachments);

    final userMessage = AiMessage(
      id: clientId,
      sessionId: _currentSessionId ?? 'draft',
      role: AiMessageRole.user,
      content: displayContent,
      status: AiMessageStatus.complete,
      createdAt: DateTime.now(),
      clientId: clientId,
      attachments: attachments,
    );
    messages.add(userMessage);

    final thinking = AiMessage(
      id: 'thinking-$clientId',
      sessionId: _currentSessionId ?? 'draft',
      role: AiMessageRole.assistant,
      content: '',
      status: AiMessageStatus.thinking,
      createdAt: DateTime.now(),
    );
    messages.add(thinking);
    inputController.clear();
    clearPendingAttachments();
    _drafts.remove(_currentSessionId ?? 'draft');
    scrollToBottom();

    try {
      if (_aiRepository.useMockApi) {
        final response = await _aiRepository.sendMessage(
          message: apiMessage,
          sessionId: _currentSessionId,
          topic: _selectedTopic,
        );
        if (token != _requestToken) return;

        _currentSessionId = response.sessionId;
        final streamed = await _playChatGptStream(
          token: token,
          index: messages.indexWhere((m) => m.id == thinking.id),
          messageId: response.messageId ?? 'a-$clientId',
          sessionId: response.sessionId,
          reasoning: response.reasoning,
          reply: response.reply,
        );
        if (token != _requestToken || !streamed) return;
      } else {
        await _consumeLiveStream(
          token: token,
          thinkingId: thinking.id,
          clientId: clientId,
          apiMessage: apiMessage,
        );
        if (token != _requestToken) return;
      }
      await loadSessions();
      scrollToBottom();
    } catch (e) {
      if (token != _requestToken) return;
      messages.removeWhere((m) => m.id == thinking.id);
      messages.add(
        AiMessage(
          id: 'err-$clientId',
          sessionId: _currentSessionId ?? 'draft',
          role: AiMessageRole.assistant,
          content: aiApiErrorMessage(e),
          status: AiMessageStatus.failed,
          createdAt: DateTime.now(),
        ),
      );
      inputController.text = text;
      pendingAttachments.assignAll(attachments);
    } finally {
      _activeStreamRequestId = null;
      _streamCancelToken = null;
      if (token == _requestToken) {
        isGenerating.value = false;
        _sendLocked = false;
      }
    }
  }

  Future<void> _consumeLiveStream({
    required int token,
    required String thinkingId,
    required String clientId,
    required String apiMessage,
  }) async {
    _streamCancelToken = CancelToken();
    var assistantId = thinkingId;
    var index = messages.indexWhere((m) => m.id == assistantId);
    if (index < 0) return;

    var buffer = '';
    await for (final event in _aiRepository.streamMessage(
      message: apiMessage,
      sessionId: _currentSessionId,
      topic: _selectedTopic,
      clientMessageId: clientId,
      cancelToken: _streamCancelToken,
    )) {
      if (token != _requestToken || isClosed) return;
      index = messages.indexWhere((m) => m.id == assistantId);
      if (index < 0) return;

      switch (event) {
        case AiStreamMeta(:final sessionId, :final requestId, :final messageId):
          _currentSessionId = sessionId.isNotEmpty ? sessionId : _currentSessionId;
          _activeStreamRequestId = requestId;
          final current = messages[index];
          assistantId = messageId ?? current.id;
          messages[index] = current.copyWith(
            id: assistantId,
            status: AiMessageStatus.streaming,
          );
        case AiStreamToken(:final text):
          buffer += text;
          final current = messages[index];
          messages[index] = current.copyWith(
            content: buffer,
            status: AiMessageStatus.streaming,
          );
          scrollToBottom();
        case AiStreamDone(:final sessionId, :final messageId, :final cancelled):
          if (sessionId.isNotEmpty) _currentSessionId = sessionId;
          final current = messages[index];
          messages[index] = current.copyWith(
            id: messageId ?? current.id,
            content: buffer.isEmpty ? current.content : buffer,
            status: cancelled ? AiMessageStatus.stopped : AiMessageStatus.complete,
          );
          return;
        case AiStreamError(:final message):
          throw AiServiceException(message);
      }
    }
  }

  String _buildApiMessage(String text, List<ChatAttachment> attachments) {
    if (attachments.isEmpty) return text;
    final labels = attachments.map((a) {
      return switch (a.kind) {
        ChatAttachmentKind.photo => 'Photo: ${a.name}',
        ChatAttachmentKind.video => 'Video: ${a.name}',
        ChatAttachmentKind.file => 'File: ${a.name}',
      };
    }).join('\n');
    if (text.isEmpty) {
      return 'I attached:\n$labels\nPlease review and help me with this.';
    }
    return '$text\n\nAttached:\n$labels';
  }

  /// Streams reasoning (the “dream”) then the reply, one word at a time.
  /// Returns false if the user stopped or navigated away.
  Future<bool> _playChatGptStream({
    required int token,
    required int index,
    required String messageId,
    required String sessionId,
    required String? reasoning,
    required String reply,
  }) async {
    if (index < 0) return false;
    final createdAt = messages[index].createdAt;

    messages[index] = AiMessage(
      id: messageId,
      sessionId: sessionId,
      role: AiMessageRole.assistant,
      content: '',
      reasoning: '',
      status: AiMessageStatus.thinking,
      createdAt: createdAt,
    );

    final thought = reasoning?.trim() ?? '';
    if (thought.isNotEmpty) {
      final ok = await _streamField(
        token: token,
        index: index,
        fullText: thought,
        intoReasoning: true,
        status: AiMessageStatus.thinking,
      );
      if (!ok) return false;
      await Future<void>.delayed(const Duration(milliseconds: 180));
    }

    if (token != _requestToken || !isGenerating.value || isClosed) return false;
    messages[index] = messages[index].copyWith(
      status: AiMessageStatus.streaming,
    );

    final ok = await _streamField(
      token: token,
      index: index,
      fullText: reply,
      intoReasoning: false,
      status: AiMessageStatus.streaming,
    );
    if (!ok) return false;

    messages[index] = messages[index].copyWith(
      content: reply,
      reasoning: thought.isEmpty ? null : thought,
      status: AiMessageStatus.complete,
    );
    return true;
  }

  Future<bool> _streamField({
    required int token,
    required int index,
    required String fullText,
    required bool intoReasoning,
    required AiMessageStatus status,
  }) async {
    final units = tokenizeForStream(fullText);
    final buffer = StringBuffer();
    var emitted = 0;
    for (final unit in units) {
      if (token != _requestToken || !isGenerating.value || isClosed) {
        return false;
      }
      buffer.write(unit);
      emitted++;
      final snapshot = buffer.toString();
      final current = messages[index];
      messages[index] = current.copyWith(
        reasoning: intoReasoning ? snapshot : current.reasoning,
        content: intoReasoning ? current.content : snapshot,
        status: status,
      );
      if (emitted % 3 == 0) scrollToBottom();
      final isTable = isGfmTableStreamUnit(unit);
      if (isTable || unit.trim().isEmpty) continue;
      await Future<void>.delayed(const Duration(milliseconds: 22));
    }
    scrollToBottom();
    return token == _requestToken && isGenerating.value && !isClosed;
  }

  void stopGenerating() {
    if (!isGenerating.value) return;
    final requestId = _activeStreamRequestId;
    _streamCancelToken?.cancel('stopped');
    _streamCancelToken = null;
    _requestToken++;
    isGenerating.value = false;
    _sendLocked = false;
    final index = messages.indexWhere(
      (m) => m.isThinking || m.isStreaming,
    );
    if (index >= 0) {
      final current = messages[index];
      messages[index] = current.copyWith(
        content: current.content.trim().isEmpty
            ? 'Response stopped.'
            : current.content,
        status: AiMessageStatus.stopped,
      );
    }
    if (requestId != null && !_aiRepository.useMockApi) {
      _aiRepository.cancelChatRequest(requestId).catchError((_) {});
    }
    _activeStreamRequestId = null;
  }

  Future<void> regenerateMessage(AiMessage assistantMessage) async {
    if (_currentSessionId == null || isGenerating.value) return;
    final index = messages.indexWhere((m) => m.id == assistantMessage.id);
    if (index < 0) return;

    _sendLocked = true;
    isGenerating.value = true;
    final token = ++_requestToken;

    messages[index] = assistantMessage.copyWith(
      content: '',
      status: AiMessageStatus.thinking,
    );
    scrollToBottom();

    try {
      final response = await _aiRepository.regenerateMessage(
        sessionId: _currentSessionId!,
        assistantMessageId: assistantMessage.id,
      );
      if (token != _requestToken) return;

      final streamed = await _playChatGptStream(
        token: token,
        index: index,
        messageId: response.messageId ?? assistantMessage.id,
        sessionId: response.sessionId,
        reasoning: response.reasoning,
        reply: response.reply,
      );
      if (token != _requestToken || !streamed) return;
      await loadSessions();
      scrollToBottom();
    } catch (_) {
      if (token != _requestToken) return;
      messages[index] = assistantMessage;
      Get.snackbar(AppStrings.appName, 'Could not regenerate response');
    } finally {
      if (token == _requestToken) {
        isGenerating.value = false;
        _sendLocked = false;
      }
    }
  }

  Future<void> renameSession(AiSession session) async {
    final titleController = TextEditingController(text: session.title);
    final saved = await Get.dialog<String>(
      Builder(
        builder: (dialogContext) {
          final colors = dialogContext.appColors;
          return Dialog(
            backgroundColor: colors.cardSurface,
            surfaceTintColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Rename chat',
                      textAlign: TextAlign.center,
                      style: dialogContext.text.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    VitheyField(
                      controller: titleController,
                      label: 'Title',
                      hint: 'Chat title',
                      maxLength: 80,
                      autofocus: true,
                      onSubmitted: (value) {
                        final title = value.trim();
                        if (title.isNotEmpty) {
                          Navigator.of(dialogContext).pop(title);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: AppStrings.cancel,
                            variant: CustomButtonVariant.outline,
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            label: 'Save',
                            onPressed: () {
                              final title = titleController.text.trim();
                              if (title.isEmpty) return;
                              Navigator.of(dialogContext).pop(title);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    titleController.dispose();
    if (saved == null || saved.isEmpty) return;
    await _aiRepository.renameSession(session.id, saved);
    await loadSessions();
  }

  Future<void> togglePin(AiSession session) async {
    await _aiRepository.togglePinSession(session.id);
    await loadSessions();
  }

  Future<void> deleteSession(AiSession session) async {
    final context = Get.context;
    if (context == null) return;
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete this chat?',
      message:
          '“${session.title}” and all its messages will be permanently deleted. This can’t be undone.',
      confirmLabel: 'Delete',
      variant: ConfirmDialogVariant.destructive,
    );
    if (confirmed != true) return;
    await _aiRepository.deleteSession(session.id);
    if (_currentSessionId == session.id) newChat();
    await loadSessions();
  }

  void scrollToBottom() {
    if (isClosed) return;
    if (!_isNearBottom && messages.length > 2) return;
    if (!scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed || !scrollController.hasClients) return;
      final max = scrollController.position.maxScrollExtent;
      scrollController.jumpTo(max);
      showJumpToLatest.value = false;
    });
  }

  void forceScrollToBottom() {
    if (isClosed || !scrollController.hasClients) return;
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    showJumpToLatest.value = false;
  }

  void _saveDraft() {
    final key = _currentSessionId ?? 'draft';
    final text = inputController.text;
    if (text.trim().isEmpty) {
      _drafts.remove(key);
    } else {
      _drafts[key] = text;
    }
  }

  Future<void> copyMessage(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    Get.snackbar(AppStrings.appName, 'Copied to clipboard');
  }

  Future<void> copyCodeBlock(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(AppStrings.appName, 'Code copied');
  }

  Future<void> shareMessage(String content) async {
    await Share.share(content, subject: 'Vithey AI response');
  }

  @override
  void onClose() {
    _requestToken++;
    isGenerating.value = false;
    _sendLocked = false;
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
