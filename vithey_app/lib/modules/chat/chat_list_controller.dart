import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/models/chat_folder.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/models/search_args.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';

class ChatListController extends GetxController {
  ChatListController(this._chatRepository, this._localStorage);

  final ChatRepository _chatRepository;
  final LocalStorageService _localStorage;

  final conversations = <ConversationModel>[].obs;
  final messageRequests = <MessageRequestModel>[].obs;
  final recentContacts = <ChatParticipant>[].obs;
  final customFolders = <ChatFolder>[].obs;
  final selectedFolderId = ChatFolderIds.all.obs;
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  final isSearchActive = false.obs;
  final messageSearchSnippets = <String, String>{}.obs;

  /// True when contacts header is collapsed (scrolled) — used to hide folder border.
  final headerCollapsed = false.obs;

  /// Inline folder name entry in the folder bar (no dialog).
  final isCreatingFolder = false.obs;

  final searchController = TextEditingController();

  StreamSubscription<List<ConversationModel>>? _conversationSub;
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    _conversationSub =
        _chatRepository.watchConversations().listen(conversations.assignAll);
    _chatRepository.connectRealtime();
    _loadFolders();
    loadChatList();
  }

  Future<void> _loadFolders() async {
    try {
      final raw = await _localStorage.readChatFoldersJson();
      if (raw == null || raw.isEmpty) return;
      final list = jsonDecode(raw) as List<dynamic>;
      customFolders.assignAll(
        list
            .whereType<Map>()
            .map((e) => ChatFolder.fromJson(Map<String, dynamic>.from(e)))
            .where((f) => f.id.isNotEmpty && f.name.isNotEmpty),
      );
    } catch (_) {
      // Keep empty folders on parse errors.
    }
  }

  Future<void> _persistFolders() async {
    final json = jsonEncode(customFolders.map((f) => f.toJson()).toList());
    await _localStorage.saveChatFoldersJson(json);
  }

  Future<void> loadChatList() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final results = await Future.wait([
        _chatRepository.fetchConversations(),
        _chatRepository.fetchMessageRequests(),
        _chatRepository.fetchRecentContacts(),
      ]);
      conversations.assignAll(results[0] as List<ConversationModel>);
      messageRequests.assignAll(results[1] as List<MessageRequestModel>);
      recentContacts.assignAll(results[2] as List<ChatParticipant>);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshChatList() async {
    isRefreshing.value = true;
    try {
      await loadChatList();
    } finally {
      isRefreshing.value = false;
    }
  }

  void selectFolder(String folderId) {
    selectedFolderId.value = folderId;
  }

  void startCreatingFolder() {
    isCreatingFolder.value = true;
  }

  void cancelCreatingFolder() {
    isCreatingFolder.value = false;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    messageSearchSnippets.clear();
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 220), () {
      _refreshMessageSearch();
    });
  }

  Future<void> _refreshMessageSearch() async {
    final query = searchQuery.value.trim();
    if (query.isEmpty) {
      messageSearchSnippets.clear();
      return;
    }
    final snippets = await _chatRepository.searchMessageSnippets(query);
    if (searchQuery.value.trim() != query) return;
    messageSearchSnippets.assignAll(snippets);
  }

  bool conversationMatchesSearch(ConversationModel conversation, String query) {
    if (query.isEmpty) return true;
    final lower = query.toLowerCase();
    if (conversation.participant.fullName.toLowerCase().contains(lower)) {
      return true;
    }
    if (conversation.lastMessagePreview.toLowerCase().contains(lower)) {
      return true;
    }
    return messageSearchSnippets.containsKey(conversation.id);
  }

  String? searchSubtitleFor(ConversationModel conversation) {
    final query = searchQuery.value.trim();
    if (query.isEmpty) return null;

    final snippet = messageSearchSnippets[conversation.id];
    if (snippet != null &&
        !conversation.lastMessagePreview
            .toLowerCase()
            .contains(query.toLowerCase())) {
      return snippet;
    }
    return null;
  }

  void openSearch() {
    isSearchActive.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isSearchActive.value) {
        _refreshMessageSearch();
      }
    });
  }

  void closeSearch() {
    isSearchActive.value = false;
    clearSearch();
  }

  void toggleSearch() {
    if (isSearchActive.value) {
      closeSearch();
    } else {
      openSearch();
    }
  }

  List<ConversationModel> get filteredConversations {
    var list = conversations.toList();
    final folderId = selectedFolderId.value;

    if (folderId == ChatFolderIds.unread) {
      list = list.where((c) => c.unreadCount > 0).toList();
    } else if (folderId != ChatFolderIds.all) {
      final folder = customFolders.firstWhereOrNull((f) => f.id == folderId);
      if (folder != null) {
        final ids = folder.conversationIds.toSet();
        list = list.where((c) => ids.contains(c.id)).toList();
      }
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((c) => conversationMatchesSearch(c, query)).toList();
    }
    return list;
  }

  int countForFolder(String folderId) {
    if (folderId == ChatFolderIds.all) return conversations.length;
    if (folderId == ChatFolderIds.unread) {
      return conversations.where((c) => c.unreadCount > 0).length;
    }
    final folder = customFolders.firstWhereOrNull((f) => f.id == folderId);
    if (folder == null) return 0;
    final ids = folder.conversationIds.toSet();
    return conversations.where((c) => ids.contains(c.id)).length;
  }

  Future<ChatFolder?> createFolder(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    final folder = ChatFolder(
      id: 'folder_${DateTime.now().millisecondsSinceEpoch}',
      name: trimmed,
    );
    customFolders.add(folder);
    await _persistFolders();
    return folder;
  }

  Future<void> renameFolder(String folderId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final index = customFolders.indexWhere((f) => f.id == folderId);
    if (index < 0) return;
    customFolders[index] = customFolders[index].copyWith(name: trimmed);
    customFolders.refresh();
    await _persistFolders();
  }

  Future<void> deleteFolder(String folderId) async {
    customFolders.removeWhere((f) => f.id == folderId);
    if (selectedFolderId.value == folderId) {
      selectedFolderId.value = ChatFolderIds.all;
    }
    await _persistFolders();
  }

  Future<void> addConversationToFolder(
    String folderId,
    String conversationId,
  ) async {
    final index = customFolders.indexWhere((f) => f.id == folderId);
    if (index < 0) return;
    final folder = customFolders[index];
    if (folder.conversationIds.contains(conversationId)) return;
    customFolders[index] = folder.copyWith(
      conversationIds: [...folder.conversationIds, conversationId],
    );
    customFolders.refresh();
    await _persistFolders();
  }

  Future<void> removeConversationFromFolder(
    String folderId,
    String conversationId,
  ) async {
    final index = customFolders.indexWhere((f) => f.id == folderId);
    if (index < 0) return;
    final folder = customFolders[index];
    customFolders[index] = folder.copyWith(
      conversationIds:
          folder.conversationIds.where((id) => id != conversationId).toList(),
    );
    customFolders.refresh();
    await _persistFolders();
  }

  List<ChatFolder> foldersContaining(String conversationId) {
    return customFolders
        .where((f) => f.conversationIds.contains(conversationId))
        .toList();
  }

  void openConversation(String conversationId) {
    Get.toNamed(
      AppRoutes.chatDetail,
      arguments: ChatDetailArgs(conversationId: conversationId),
    )?.then((_) => refreshChatList());
  }

  Future<void> openAddChat() async {
    await Get.toNamed(
      AppRoutes.search,
      arguments: const SearchArgs(mode: SearchMode.pickUserForChat),
    );
  }

  void openContactChat(ChatParticipant contact) async {
    final conversationId =
        await _chatRepository.findOrCreateConversation(contact.id);
    openConversation(conversationId);
  }

  Future<void> acceptRequest(MessageRequestModel request) async {
    await _chatRepository.acceptMessageRequest(request.id);
    messageRequests.removeWhere((r) => r.id == request.id);
    openConversation(request.id);
  }

  Future<void> declineRequest(MessageRequestModel request) async {
    final confirmed = await showConfirmDialog(
      context: Get.context!,
      title: 'Decline request?',
      message:
          'This person will not be able to message you unless they send a new request.',
      confirmLabel: 'Decline',
    );
    if (confirmed != true) return;
    await _chatRepository.declineMessageRequest(request.id);
    messageRequests.removeWhere((r) => r.id == request.id);
  }

  void onTabSelected(int index) {
    MainTabNavigation.handle(
      index,
      currentIndex: MainTabNavigation.home,
    );
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _conversationSub?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
