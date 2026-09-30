import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/models/chat_shared_content_model.dart';
import 'package:aub_connect_app/modules/profile/profile_navigation.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_call_sheet.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_shared_content.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/core/widgets/report_reason_dialog.dart';

class ChatProfileController extends GetxController {
  ChatProfileController(this._chatRepository, this._localStorage);

  final ChatRepository _chatRepository;
  final LocalStorageService _localStorage;

  final participant = Rxn<ChatParticipant>();
  final sharedContent = Rxn<ChatSharedContent>();
  final isLoading = true.obs;
  final isSharedLoading = false.obs;
  final selectedTab = 0.obs;
  final isNotificationsMuted = false.obs;

  String? _conversationId;
  String? _participantId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as ChatProfileArgs;
    _conversationId = args.conversationId;
    _participantId = args.participantId;
    _loadProfile();
    _loadSharedContent();
    _loadMuteState();
  }

  Future<void> _loadMuteState() async {
    final conversationId = _conversationId;
    if (conversationId == null) return;
    isNotificationsMuted.value =
        await _localStorage.isConversationMuted(conversationId);
  }

  Future<void> _loadSharedContent() async {
    if (_conversationId == null) return;
    isSharedLoading.value = true;
    try {
      sharedContent.value =
          await _chatRepository.fetchSharedContent(_conversationId!);
    } finally {
      isSharedLoading.value = false;
    }
  }

  Future<void> _loadProfile() async {
    isLoading.value = true;
    try {
      participant.value = await _chatRepository.getParticipant(
        conversationId: _conversationId!,
        participantId: _participantId!,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void openFullProfile() {
    final id = _participantId;
    if (id == null) return;
    openUserProfile(id);
  }

  void openMessage() => Get.back();

  void startVoiceCall() {
    final p = participant.value;
    final ctx = Get.context;
    if (p == null || ctx == null) return;
    showChatCallSheet(context: ctx, participant: p, isVideo: false);
  }

  void startVideoCall() {
    final p = participant.value;
    final ctx = Get.context;
    if (p == null || ctx == null) return;
    showChatCallSheet(context: ctx, participant: p, isVideo: true);
  }

  /// Long-press Call / Video — mock incoming call banner on the previous screen.
  Future<void> previewIncomingCall({required bool isVideo}) async {
    final conversationId = _conversationId;
    if (conversationId == null) return;
    Get.back();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await _chatRepository.simulateIncomingCall(
      conversationId,
      isVideo: isVideo,
    );
  }

  Future<void> toggleMuteNotifications() async {
    final conversationId = _conversationId;
    if (conversationId == null) return;
    final next = !isNotificationsMuted.value;
    await _localStorage.setConversationMuted(conversationId, next);
    isNotificationsMuted.value = next;
    Get.snackbar(
      AppStrings.appName,
      next
          ? AppStrings.chatNotificationsMuted
          : AppStrings.chatNotificationsUnmuted,
    );
  }

  Future<void> blockUser() async {
    if (_conversationId == null) return;
    final confirmed = await showConfirmDialog(
      context: Get.context!,
      title: 'Block this user?',
      message: 'You will no longer receive messages from this person.',
      confirmLabel: 'Block',
    );
    if (confirmed != true) return;
    await _chatRepository.blockConversation(_conversationId!);
    Get.close(2);
    Get.snackbar(AppStrings.appName, 'User blocked');
  }

  Future<void> reportUser() async {
    if (_participantId == null) return;
    final reason = await showReportReasonDialog(title: 'Report user');
    if (reason == null || reason.isEmpty) return;
    await _chatRepository.reportUser(_participantId!, reason);
    Get.snackbar(AppStrings.appName, 'Report submitted');
  }
}

class ChatProfileScreen extends GetView<ChatProfileController> {
  const ChatProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bodyBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.appColors.bodyBackground,
        foregroundColor: context.appColors.heading,
        actions: [
          PopupMenuButton<String>(
            color: context.appColors.cardSurface,
            onSelected: (value) {
              switch (value) {
                case 'block':
                  controller.blockUser();
                case 'report':
                  controller.reportUser();
              }
            },
            itemBuilder: (ctx) {
              final colors = ctx.appColors;
              return [
                PopupMenuItem(
                  value: 'block',
                  child: Text('Block', style: TextStyle(color: colors.heading)),
                ),
                PopupMenuItem(
                  value: 'report',
                  child: Text('Report', style: TextStyle(color: colors.heading)),
                ),
              ];
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();
        final p = controller.participant.value;
        if (p == null) {
          return const Center(child: Text('Participant unavailable'));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    UserAvatar(
                        name: p.fullName, imageUrl: p.avatarUrl, radius: 48),
                    if (p.isOnline)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.appColors.cardSurface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                p.fullName,
                style: context.text.headlineSmall,
              ),
            ),
            Center(
              child: Text(
                p.isOnline ? AppStrings.chatOnline : 'Offline',
                style: TextStyle(
                  color:
                      p.isOnline ? AppColors.primary : context.appColors.muted,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ChatQuickActionsRow(
              onProfile: controller.openFullProfile,
              onCall: controller.startVoiceCall,
              onVideo: controller.startVideoCall,
              onCallLongPress: () =>
                  controller.previewIncomingCall(isVideo: false),
              onVideoLongPress: () =>
                  controller.previewIncomingCall(isVideo: true),
              onMute: controller.toggleMuteNotifications,
              isMuted: controller.isNotificationsMuted.value,
            ),
            const SizedBox(height: 16),
            ChatContactInfoCard(phone: p.phone, bio: p.bio),
            const SizedBox(height: 20),
            ChatSharedTabs(
              selectedIndex: controller.selectedTab.value,
              onTabSelected: (i) => controller.selectedTab.value = i,
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.isSharedLoading.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return _buildTabContent(
                  controller.selectedTab.value, controller.sharedContent.value);
            }),
          ],
        );
      }),
    );
  }

  Widget _buildTabContent(int tab, ChatSharedContent? content) {
    final shared = content ?? const ChatSharedContent();
    switch (tab) {
      case 0:
        return SharedMediaGrid(imageUrls: shared.imageUrls);
      case 1:
        return SharedVideoGrid(videoUrls: shared.videoUrls);
      case 2:
        return SharedFilesList(
          files: shared.files
              .map((file) =>
                  (name: file.name, size: file.sizeLabel, date: file.sharedAt))
              .toList(),
        );
      case 3:
        return SharedLinksList(
          links: shared.links
              .map(
                (link) => (
                  month: link.monthLabel,
                  title: link.title ?? link.url,
                  description: link.description ?? '',
                  url: link.url,
                ),
              )
              .toList(),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
