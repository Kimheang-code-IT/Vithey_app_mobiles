import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/core/widgets/vithey_dialog.dart';
import 'package:aub_connect_app/core/widgets/vithey_field.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_link.dart';
import 'package:aub_connect_app/data/models/chat_folder.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/modules/chat/chat_list_controller.dart';
import 'package:get/get.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Folder tab context menu: add chats or remove folder.
Future<void> showFolderTabMenu(BuildContext context, ChatFolder folder) async {
  final controller = Get.find<ChatListController>();
  final colors = context.appColors;
  final box = context.findRenderObject() as RenderBox?;
  if (box == null) return;

  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final position = box.localToGlobal(Offset.zero, ancestor: overlay);

  final value = await showMenu<String>(
    context: context,
    color: colors.cardSurface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy + box.size.height + 4,
      position.dx + box.size.width,
      position.dy + box.size.height + 4,
    ),
    items: [
      PopupMenuItem(
        value: 'add',
        child: Row(
          children: [
            const VitheyIcon(LucideIcons.plus, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppStrings.chatAddChats,
                style: TextStyle(color: colors.heading),
              ),
            ),
          ],
        ),
      ),
      PopupMenuItem(
        value: 'remove',
        child: Row(
          children: [
            const VitheyIcon(LucideIcons.trash2, size: 20, color: AppColors.error),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                AppStrings.chatRemoveFolder,
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  if (!context.mounted) return;
  if (value == 'add') {
    await showAddChatsToFolderSheet(context, folder);
  } else if (value == 'remove') {
    await controller.deleteFolder(folder.id);
  }
}

Future<void> showManageFoldersSheet(BuildContext context) {
  final controller = Get.find<ChatListController>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final colors = ctx.appColors;
      final height = MediaQuery.sizeOf(ctx).height * 0.7;
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: colors.cardSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.muted.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.chatManageFolders,
                      style: context.text.titleLarge,
                    ),
                  ),
                  VitheyTextLink(
                    label: AppStrings.chatNewFolder,
                    color: colors.heading,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      controller.startCreatingFolder();
                    },
                  ),
                  VitheyIconButton(
                    icon: LucideIcons.x,
                    variant: VitheyIconButtonVariant.neutral,
                    tooltip: 'Close',
                    onTap: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.border),
            Expanded(
              child: Obx(() {
                final folders = controller.customFolders;
                if (folders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Create folders to organize your chats.',
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium
                            ?.copyWith(color: colors.muted),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  itemCount: folders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final folder = folders[index];
                    final count = controller.countForFolder(folder.id);
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colors.border),
                      ),
                      leading: const VitheyIcon(
                        LucideIcons.folder,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        folder.name,
                        style: context.text.labelLarge,
                      ),
                      subtitle: Text(
                        '$count chats',
                        style: context.text.labelMedium,
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'add') {
                            Navigator.of(ctx).pop();
                            await showAddChatsToFolderSheet(context, folder);
                          } else if (value == 'rename') {
                            await _promptRenameFolder(ctx, controller, folder);
                          } else if (value == 'delete') {
                            await controller.deleteFolder(folder.id);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'add',
                            child: Text(AppStrings.chatAddChatsToFolder),
                          ),
                          PopupMenuItem(
                            value: 'rename',
                            child: Text(AppStrings.chatRenameFolder),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(AppStrings.chatDeleteFolder),
                          ),
                        ],
                      ),
                      onTap: () {
                        controller.selectFolder(folder.id);
                        Navigator.of(ctx).pop();
                      },
                      onLongPress: () {
                        Navigator.of(ctx).pop();
                        showAddChatsToFolderSheet(context, folder);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      );
    },
  );
}

/// Starts inline folder creation in the folder bar.
void startInlineFolderCreation(BuildContext context) {
  Get.find<ChatListController>().startCreatingFolder();
}

/// Pick chats to add into [folder].
Future<void> showAddChatsToFolderSheet(
  BuildContext context,
  ChatFolder folder,
) {
  final controller = Get.find<ChatListController>();
  final selectedIds = <String>{}.obs;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.52,
        minChildSize: 0.35,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, scrollController) {
          return _AddChatsToFolderSheet(
            folder: folder,
            controller: controller,
            selectedIds: selectedIds,
            scrollController: scrollController,
          );
        },
      );
    },
  );
}

class _AddChatsToFolderSheet extends StatelessWidget {
  const _AddChatsToFolderSheet({
    required this.folder,
    required this.controller,
    required this.selectedIds,
    required this.scrollController,
  });

  final ChatFolder folder;
  final ChatListController controller;
  final RxSet<String> selectedIds;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.muted.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.chatAddChatsToFolder,
                    style: context.text.titleLarge?.copyWith(fontSize: 17),
                  ),
                ),
                Obx(() {
                  final count = selectedIds.length;
                  return CustomButton(
                    label: count == 0 ? 'Add' : 'Add ($count)',
                    onPressed: count == 0
                        ? null
                        : () async {
                            for (final id in selectedIds.toList()) {
                              await controller.addConversationToFolder(
                                folder.id,
                                id,
                              );
                            }
                            if (context.mounted) Navigator.of(context).pop();
                          },
                    variant: CustomButtonVariant.ghost,
                  );
                }),
                VitheyIconButton(
                  icon: LucideIcons.x,
                  variant: VitheyIconButtonVariant.neutral,
                  tooltip: 'Close',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.border),
          Expanded(
            child: Obx(() {
              final latest = controller.customFolders
                  .firstWhereOrNull((f) => f.id == folder.id);
              final existing = latest?.conversationIds.toSet() ??
                  folder.conversationIds.toSet();
              final chats = controller.conversations
                  .where((c) => !existing.contains(c.id))
                  .toList();

              if (chats.isEmpty) {
                return Center(
                  child: Text(
                    AppStrings.chatNoChatsToAdd,
                    style: TextStyle(color: colors.muted),
                  ),
                );
              }

              return ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                itemCount: chats.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: colors.border.withValues(alpha: 0.6),
                ),
                itemBuilder: (_, index) {
                  final chat = chats[index];
                  return Obx(() {
                    final checked = selectedIds.contains(chat.id);
                    return CheckboxListTile(
                      value: checked,
                      onChanged: (value) {
                        if (value == true) {
                          selectedIds.add(chat.id);
                        } else {
                          selectedIds.remove(chat.id);
                        }
                      },
                      secondary: UserAvatar(
                        name: chat.participant.fullName,
                        imageUrl: chat.participant.avatarUrl,
                        radius: 22,
                      ),
                      title: Text(
                        chat.participant.fullName,
                        style: context.text.labelLarge,
                      ),
                      subtitle: Text(
                        chat.lastMessagePreview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall
                            ?.copyWith(color: colors.muted),
                      ),
                      activeColor: AppColors.primary,
                      controlAffinity: ListTileControlAffinity.trailing,
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

Future<void> showMoveToFolderSheet(
  BuildContext context,
  ConversationModel conversation,
) {
  final controller = Get.find<ChatListController>();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final colors = ctx.appColors;
      return Container(
        decoration: BoxDecoration(
          color: colors.cardSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: SafeArea(
          top: false,
          child: Obx(() {
            final folders = controller.customFolders.toList();
            final inFolders = controller.foldersContaining(conversation.id);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.muted.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  AppStrings.chatMoveToFolder,
                  style: context.text.titleLarge,
                ),
                Text(
                  conversation.participant.fullName,
                  style: context.text.bodySmall
                      ?.copyWith(color: colors.muted),
                ),
                const SizedBox(height: 12),
                if (folders.isEmpty)
                  Text(
                    'Create a folder first.',
                    style: TextStyle(color: colors.muted),
                  )
                else
                  ...folders.map((folder) {
                    final inFolder = inFolders.any((f) => f.id == folder.id);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: VitheyIcon(
                        inFolder ? LucideIcons.folder : LucideIcons.folder,
                        color: AppColors.primary,
                      ),
                      title: Text(folder.name),
                      trailing: inFolder
                          ? VitheyTextLink(
                              label: AppStrings.chatRemoveFromFolder,
                              color: AppColors.primary,
                              fontSize: 14,
                              onPressed: () async {
                                await controller.removeConversationFromFolder(
                                  folder.id,
                                  conversation.id,
                                );
                              },
                            )
                          : VitheyTextLink(
                              label: 'Add',
                              color: AppColors.primary,
                              fontSize: 14,
                              onPressed: () async {
                                await controller.addConversationToFolder(
                                  folder.id,
                                  conversation.id,
                                );
                              },
                            ),
                    );
                  }),
                VitheyTextLink(
                  label: AppStrings.chatNewFolder,
                  color: AppColors.primary,
                  fontSize: 15,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    controller.startCreatingFolder();
                  },
                ),
              ],
            );
          }),
        ),
      );
    },
  );
}

Future<void> _promptRenameFolder(
  BuildContext context,
  ChatListController controller,
  ChatFolder folder,
) async {
  final name = await _promptFolderName(
    context,
    title: AppStrings.chatRenameFolder,
    initial: folder.name,
  );
  if (name == null) return;
  await controller.renameFolder(folder.id, name);
}

Future<String?> _promptFolderName(
  BuildContext context, {
  required String title,
  String? initial,
}) {
  final textController = TextEditingController(text: initial ?? '');
  return showVitheyDialog<String>(
    context: context,
    child: Builder(
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.text.titleLarge,
            ),
            const SizedBox(height: 16),
            VitheyField(
              controller: textController,
              hint: AppStrings.chatFolderNameHint,
              autofocus: true,
              onSubmitted: (value) => Navigator.of(ctx).pop(value.trim()),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(ctx).pop(),
                    variant: CustomButtonVariant.ghost,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: 'Save',
                    onPressed: () =>
                        Navigator.of(ctx).pop(textController.text.trim()),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}
