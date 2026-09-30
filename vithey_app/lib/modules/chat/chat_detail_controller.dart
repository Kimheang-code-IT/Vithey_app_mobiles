import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_emoji_panel.dart';
import 'package:aub_connect_app/modules/chat/widgets/date_separator.dart';
import 'package:aub_connect_app/modules/chat/widgets/delete_message_dialog.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/core/widgets/report_reason_dialog.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ChatDetailController extends GetxController {
  ChatDetailController(this._chatRepository);

  final ChatRepository _chatRepository;

  final messages = <ChatMessage>[].obs;
  final participant = Rxn<ChatParticipant>();
  final isLoading = true.obs;
  final isSending = false.obs;
  final isTyping = false.obs;
  final showJumpToLatest = false.obs;
  final replyToMessage = Rxn<ChatMessage>();
  final threadSearchQuery = ''.obs;
  final isThreadSearchActive = false.obs;
  final threadSearchController = TextEditingController();
  final threadSearchFocusNode = FocusNode();
  final pendingAttachments = <ChatAttachment>[].obs;
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  final showEmojiPanel = false.obs;
  final _reactionsByKey = <String, List<MessageReaction>>{};

  String? _conversationId;
  bool _sendLocked = false;
  StreamSubscription<List<ChatMessage>>? _messageSub;
  StreamSubscription<List<ConversationModel>>? _conversationSub;
  final _pendingReadIds = <String>{};

  @override
  void onInit() {
    super.onInit();
    final args = ChatDetailArgs.from(Get.arguments);
    _conversationId = args.conversationId;
    _chatRepository.setActiveConversation(_conversationId);
    scrollController.addListener(_onScroll);
    threadSearchController.addListener(() {
      threadSearchQuery.value = threadSearchController.text;
    });
    _messageSub = _chatRepository
        .watchMessages(_conversationId!)
        .listen(_onMessagesUpdated);
    _conversationSub =
        _chatRepository.watchConversations().listen((conversations) {
      final match =
          conversations.where((c) => c.id == _conversationId).toList();
      if (match.isEmpty) return;
      isTyping.value = match.first.isTyping;
      participant.value = match.first.participant;
    });
    _loadThread();
  }

  void _onMessagesUpdated(List<ChatMessage> updated) {
    final wasAtBottom = _isNearBottom();
    messages.assignAll(
      updated.map(_withLocalReactions).toList(),
    );
    if (wasAtBottom) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => forceScrollToBottom());
    } else if (updated.isNotEmpty) {
      showJumpToLatest.value = true;
    }
    _markVisibleMessagesRead();
  }

  String _reactionKey(ChatMessage message) => message.clientId ?? message.id;

  ChatMessage _withLocalReactions(ChatMessage message) {
    final key = _reactionKey(message);
    final local = _reactionsByKey[key] ??
        _reactionsByKey[message.id] ??
        message.reactions;
    if (local.isEmpty) return message;
    _reactionsByKey[key] = local;
    if (message.clientId != null) {
      _reactionsByKey[message.id] = local;
    }
    return message.copyWith(reactions: local);
  }

  void toggleEmojiPanel() {
    showEmojiPanel.value = !showEmojiPanel.value;
  }

  void hideEmojiPanel() {
    if (showEmojiPanel.value) showEmojiPanel.value = false;
  }

  void insertEmoji(String emoji) {
    final text = messageController.text;
    final selection = messageController.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final next = text.replaceRange(start, end, emoji);
    messageController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  void reactToMessage(ChatMessage message, String emoji) {
    if (message.isDeleted) return;
    final key = _reactionKey(message);
    final current = List<MessageReaction>.from(
      _reactionsByKey[key] ?? message.reactions,
    );

    final index = current.indexWhere((r) => r.emoji == emoji);
    if (index >= 0) {
      final existing = current[index];
      if (existing.reactedByMe) {
        final nextCount = existing.count - 1;
        if (nextCount <= 0) {
          current.removeAt(index);
        } else {
          current[index] = existing.copyWith(
            count: nextCount,
            reactedByMe: false,
          );
        }
      } else {
        current[index] = existing.copyWith(
          count: existing.count + 1,
          reactedByMe: true,
        );
      }
    } else {
      // One reaction per user: clear previous "mine" markers.
      for (var i = 0; i < current.length; i++) {
        final r = current[i];
        if (!r.reactedByMe) continue;
        final nextCount = r.count - 1;
        if (nextCount <= 0) {
          current.removeAt(i);
          i--;
        } else {
          current[i] = r.copyWith(count: nextCount, reactedByMe: false);
        }
      }
      current.add(MessageReaction(emoji: emoji, count: 1, reactedByMe: true));
    }

    _reactionsByKey[key] = current;
    _reactionsByKey[message.id] = current;
    if (message.clientId != null) {
      _reactionsByKey[message.clientId!] = current;
    }

    final msgIndex = messages.indexWhere(
      (m) => m.id == message.id || m.clientId == message.clientId,
    );
    if (msgIndex >= 0) {
      messages[msgIndex] = messages[msgIndex].copyWith(reactions: current);
      messages.refresh();
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    showJumpToLatest.value = !_isNearBottom() && messages.isNotEmpty;
    if (_isNearBottom()) _markVisibleMessagesRead();
  }

  bool _isNearBottom() {
    if (!scrollController.hasClients) return true;
    final max = scrollController.position.maxScrollExtent;
    return scrollController.offset >= max - 80;
  }

  Future<void> _loadThread() async {
    if (_conversationId == null) return;
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _chatRepository.fetchMessages(conversationId: _conversationId!),
        _chatRepository.getConversation(_conversationId!),
      ]);
      messages.assignAll(
        (results[0] as List<ChatMessage>).map(_withLocalReactions),
      );
      final conversation = results[1] as ConversationModel?;
      participant.value = conversation?.participant;
      isTyping.value = conversation?.isTyping ?? false;
      await _chatRepository.markConversationRead(_conversationId!);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => forceScrollToBottom());
    } catch (e) {
      Get.snackbar(AppStrings.appName, 'Could not load messages');
    } finally {
      isLoading.value = false;
    }
  }

  bool get hasThreadSearch => threadSearchQuery.value.trim().isNotEmpty;

  List<ChatMessage> get visibleMessages {
    final query = threadSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return messages;
    return messages
        .where((message) =>
            !message.isDeleted && message.text.toLowerCase().contains(query))
        .toList();
  }

  void openThreadSearch() {
    isThreadSearchActive.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isThreadSearchActive.value) {
        threadSearchFocusNode.requestFocus();
      }
    });
  }

  void closeThreadSearch() {
    isThreadSearchActive.value = false;
    clearThreadSearch();
    threadSearchFocusNode.unfocus();
  }

  void toggleThreadSearch() {
    if (isThreadSearchActive.value) {
      closeThreadSearch();
    } else {
      openThreadSearch();
    }
  }

  void handleHeaderBack() {
    if (isThreadSearchActive.value) {
      closeThreadSearch();
      return;
    }
    Get.back();
  }

  void clearThreadSearch() {
    threadSearchController.clear();
    threadSearchQuery.value = '';
  }

  Future<void> openAttachmentMenu() async {
    if (isSending.value) return;
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

  String _buildSendText(String text, List<ChatAttachment> attachments) {
    if (attachments.isEmpty) return text;
    final labels = attachments.map((a) {
      return switch (a.kind) {
        ChatAttachmentKind.photo => 'Photo: ${a.name}',
        ChatAttachmentKind.video => 'Video: ${a.name}',
        ChatAttachmentKind.file => 'File: ${a.name}',
      };
    }).join('\n');
    if (text.isEmpty) return labels;
    return '$text\n\n$labels';
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    final attachments = List<ChatAttachment>.from(pendingAttachments);
    if ((text.isEmpty && attachments.isEmpty) ||
        _conversationId == null ||
        _sendLocked) {
      return;
    }

    _sendLocked = true;
    isSending.value = true;
    final clientId = 'client-${DateTime.now().millisecondsSinceEpoch}';
    final reply = replyToMessage.value;
    final apiText = _buildSendText(text, attachments);
    final optimistic = ChatMessage(
      id: clientId,
      conversationId: _conversationId!,
      senderId: ChatRepository.currentUserId,
      text: text,
      createdAt: DateTime.now(),
      status: MessageDeliveryStatus.sending,
      isOwn: true,
      clientId: clientId,
      replyToMessageId: reply?.id,
      replyToPreview: reply?.text,
      attachments: attachments,
    );
    messages.add(optimistic);
    messageController.clear();
    clearPendingAttachments();
    replyToMessage.value = null;
    forceScrollToBottom();

    try {
      final saved = await _chatRepository.sendMessage(
        conversationId: _conversationId!,
        text: apiText,
        clientId: clientId,
        replyToMessageId: reply?.id,
        replyToPreview: reply?.text,
      );
      final index = messages.indexWhere((m) => m.clientId == clientId);
      if (index >= 0) {
        messages[index] = saved.copyWith(
          status: MessageDeliveryStatus.sent,
          text: text.isEmpty ? '' : text,
          attachments: attachments,
        );
      }
    } catch (_) {
      final index = messages.indexWhere((m) => m.clientId == clientId);
      if (index >= 0) {
        messages[index] = optimistic.copyWith(
          isFailed: true,
          status: MessageDeliveryStatus.failed,
        );
      }
      messageController.text = text;
      pendingAttachments.assignAll(attachments);
      Get.snackbar(AppStrings.appName, 'Message failed to send');
    } finally {
      isSending.value = false;
      _sendLocked = false;
    }
  }

  Future<void> retryMessage(ChatMessage message) async {
    if (_conversationId == null) return;
    final index = messages.indexWhere((m) => m.id == message.id);
    if (index < 0) return;
    messages[index] = message.copyWith(
        isFailed: false, status: MessageDeliveryStatus.sending);
    try {
      final saved = await _chatRepository.sendMessage(
        conversationId: _conversationId!,
        text: message.text,
        clientId: message.clientId,
        replyToMessageId: message.replyToMessageId,
        replyToPreview: message.replyToPreview,
      );
      messages[index] = saved.copyWith(status: MessageDeliveryStatus.sent);
    } catch (_) {
      messages[index] = message.copyWith(
          isFailed: true, status: MessageDeliveryStatus.failed);
    }
  }

  void setReplyTo(ChatMessage message) {
    if (message.isDeleted) return;
    replyToMessage.value = message;
  }

  void cancelReply() => replyToMessage.value = null;

  Future<void> copyMessage(ChatMessage message) async {
    await Clipboard.setData(ClipboardData(text: message.text));
    Get.snackbar(AppStrings.appName, 'Copied to clipboard');
  }

  Future<void> deleteMessage(ChatMessage message) async {
    final confirmed = await DeleteMessageDialog.show();
    if (confirmed != true) return;
    await _chatRepository.deleteMessage(message.id);
  }

  void showMessageActions(ChatMessage message) {
    if (message.isDeleted) return;
    String? myReaction;
    for (final reaction in message.reactions) {
      if (reaction.reactedByMe) {
        myReaction = reaction.emoji;
        break;
      }
    }

    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuickReactionBar(
              selectedEmoji: myReaction,
              onSelected: (emoji) {
                Get.back();
                reactToMessage(message, emoji);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const VitheyIcon(LucideIcons.copy),
              title: const Text('Copy'),
              onTap: () {
                Get.back();
                copyMessage(message);
              },
            ),
            ListTile(
              leading: const VitheyIcon(LucideIcons.reply),
              title: const Text('Reply'),
              onTap: () {
                Get.back();
                setReplyTo(message);
              },
            ),
            if (message.isOwn)
              ListTile(
                leading: const VitheyIcon(LucideIcons.trash2),
                title: const Text('Delete'),
                onTap: () {
                  Get.back();
                  deleteMessage(message);
                },
              ),
          ],
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
    );
  }

  void _markVisibleMessagesRead() {
    if (_conversationId == null) return;
    for (final message in messages) {
      if (!message.isOwn && message.status != MessageDeliveryStatus.read) {
        _pendingReadIds.add(message.id);
      }
    }
    if (_pendingReadIds.isEmpty) return;
    final ids = List<String>.from(_pendingReadIds);
    _pendingReadIds.clear();
    for (final id in ids) {
      _chatRepository.markMessageRead(id);
    }
  }

  void forceScrollToBottom() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    showJumpToLatest.value = false;
  }

  bool shouldShowDateSeparator(int index, List<ChatMessage> source) {
    if (index == 0) return true;
    final current = source[index].createdAt;
    final previous = source[index - 1].createdAt;
    return DateSeparator.labelFor(current) != DateSeparator.labelFor(previous);
  }

  bool shouldShowAvatar(int index, List<ChatMessage> source) {
    final message = source[index];
    if (message.isOwn) return false;
    if (index == 0) return true;
    return source[index - 1].senderId != message.senderId;
  }

  bool shouldShowSeenLabel(int index, List<ChatMessage> source) {
    final message = source[index];
    if (!message.isOwn || message.status != MessageDeliveryStatus.read) {
      return false;
    }
    for (var i = index + 1; i < source.length; i++) {
      if (source[i].isOwn) return false;
    }
    return true;
  }

  bool shouldShowDateSeparatorInThread(int index) =>
      shouldShowDateSeparator(index, visibleMessages);

  bool shouldShowAvatarInThread(int index) =>
      shouldShowAvatar(index, visibleMessages);

  bool shouldShowSeenLabelInThread(int index) =>
      shouldShowSeenLabel(index, visibleMessages);

  void handleHeaderMenu(String action) {
    switch (action) {
      case 'profile':
        openParticipantProfile();
      case 'block':
        blockConversation();
      case 'report':
        reportUser();
    }
  }

  Future<void> reportUser() async {
    final current = participant.value;
    if (current == null) return;
    final reason = await showReportReasonDialog(title: 'Report user');
    if (reason == null || reason.isEmpty) return;
    await _chatRepository.reportUser(current.id, reason);
    Get.snackbar(AppStrings.appName, 'Report submitted');
  }

  void openParticipantProfile() {
    final current = participant.value;
    if (current == null || _conversationId == null) return;
    Get.toNamed(
      AppRoutes.chatProfile,
      arguments: ChatProfileArgs(
        conversationId: _conversationId!,
        participantId: current.id,
      ),
    );
  }

  Future<void> blockConversation() async {
    if (_conversationId == null) return;
    final confirmed = await showConfirmDialog(
      context: Get.context!,
      title: 'Block this user?',
      message: 'You will no longer receive messages from this person.',
      confirmLabel: 'Block',
    );
    if (confirmed != true) return;
    await _chatRepository.blockConversation(_conversationId!);
    Get.back();
    Get.snackbar(AppStrings.appName, 'User blocked');
  }

  @override
  void onClose() {
    _chatRepository.setActiveConversation(null);
    _messageSub?.cancel();
    _conversationSub?.cancel();
    messageController.dispose();
    threadSearchController.dispose();
    threadSearchFocusNode.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
