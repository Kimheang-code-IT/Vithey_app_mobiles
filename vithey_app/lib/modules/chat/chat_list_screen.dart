import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_bottom_navigation.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/shimmer_list_tile.dart';
import 'package:aub_connect_app/modules/chat/chat_list_controller.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_folder_tabs.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_folders_sheet.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_list_flexible_header.dart';
import 'package:aub_connect_app/modules/chat/widgets/conversation_list_tile.dart';

class ChatListScreen extends GetView<ChatListController> {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: context.appColors.bodyBackground,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final isLoading = controller.isLoading.value;
          final hasError = controller.hasError.value;
          final conversations = controller.conversations.toList();
          // Register reactive deps used by filteredConversations.
          controller.searchQuery.value;
          controller.isSearchActive.value;
          controller.messageSearchSnippets.length;
          controller.selectedFolderId.value;
          controller.customFolders.length;

          if (isLoading && conversations.isEmpty) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (_, index) => const ShimmerListTile(),
            );
          }
          if (hasError && conversations.isEmpty) {
            return AppErrorWidget(
              message: controller.errorMessage.value,
              onRetry: controller.loadChatList,
            );
          }

          final chats = controller.filteredConversations;

          return RefreshIndicator(
            onRefresh: controller.refreshChatList,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const ChatListFlexibleHeader(),
                const ChatFolderTabs(),
                if (chats.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      title: controller.isSearchActive.value &&
                              controller.searchQuery.value.trim().isNotEmpty
                          ? AppStrings.chatSearchEmpty
                          : AppStrings.chatNoMessages,
                      subtitle: controller.isSearchActive.value &&
                              controller.searchQuery.value.trim().isNotEmpty
                          ? AppStrings.chatSearchHint
                          : AppStrings.chatNoMessagesSubtitle,
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom: AppBottomNavigation.scrollClearance(context),
                    ),
                    sliver: SliverList.builder(
                      itemCount: chats.length,
                      itemBuilder: (_, index) {
                        final conversation = chats[index];
                        final query = controller.searchQuery.value;
                        return ConversationListTile(
                          conversation: conversation,
                          searchQuery: query,
                          searchSubtitle:
                              controller.searchSubtitleFor(conversation),
                          onTap: () =>
                              controller.openConversation(conversation.id),
                          onLongPress: () => showMoveToFolderSheet(
                            context,
                            conversation,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: MainTabNavigation.chatbot,
        messagesMode: true,
        onTap: (index) {
          if (index == MainTabNavigation.chatbot) return;
          MainTabNavigation.handle(
            index,
            currentIndex: MainTabNavigation.chatbot,
          );
        },
      ),
    );
  }
}
