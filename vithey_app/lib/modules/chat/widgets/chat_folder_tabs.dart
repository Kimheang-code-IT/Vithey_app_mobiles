import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:aub_connect_app/data/models/chat_folder.dart';
import 'package:aub_connect_app/modules/chat/chat_list_controller.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_folders_sheet.dart';
import 'package:get/get.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Pinned Telegram-style folder navigation bar with bordered capsule track.
class ChatFolderTabs extends StatefulWidget {
  const ChatFolderTabs({super.key});

  static const double height = 44;

  @override
  State<ChatFolderTabs> createState() => _ChatFolderTabsState();
}

class _ChatFolderTabsState extends State<ChatFolderTabs> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _ChatFolderTabsDelegate(
        scrollController: _scrollController,
        onStartCreatingFolder: _scrollToEnd,
      ),
    );
  }
}

class _ChatFolderTabsDelegate extends SliverPersistentHeaderDelegate {
  _ChatFolderTabsDelegate({
    required this.scrollController,
    required this.onStartCreatingFolder,
  });

  final ScrollController scrollController;
  final VoidCallback onStartCreatingFolder;

  @override
  double get maxExtent => ChatFolderTabs.height;

  @override
  double get minExtent => ChatFolderTabs.height;

  @override
  bool shouldRebuild(covariant _ChatFolderTabsDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = context.appColors;
    final controller = Get.find<ChatListController>();

    final trackFill = colors.inputFill;
    final trackBorder = colors.border;
    final inactiveLabel = colors.muted;
    final badgeBg = colors.cardSurface;
    final badgeFg = colors.heading;

    return Material(
      color: colors.cardSurface,
      elevation: 0,
      child: Obx(() {
        final selected = controller.selectedFolderId.value;
        final conversationCount = controller.conversations.length;
        final folders = controller.customFolders.toList();
        final isCreating = controller.isCreatingFolder.value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: trackFill,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: trackBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: colors.subtleShadow,
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: ListView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 2,
                ),
                children: [
                  _FolderNavTab(
                    label: AppStrings.chatFolderAll,
                    count: conversationCount,
                    selected: selected == ChatFolderIds.all,
                    inactiveLabel: inactiveLabel,
                    badgeBg: badgeBg,
                    badgeFg: badgeFg,
                    onTap: (_) => controller.selectFolder(ChatFolderIds.all),
                  ),
                  _FolderNavTab(
                    label: AppStrings.chatFolderUnread,
                    count: controller.countForFolder(ChatFolderIds.unread),
                    selected: selected == ChatFolderIds.unread,
                    inactiveLabel: inactiveLabel,
                    badgeBg: badgeBg,
                    badgeFg: badgeFg,
                    onTap: (_) => controller.selectFolder(ChatFolderIds.unread),
                  ),
                  ...folders.map(
                    (folder) => _FolderNavTab(
                      label: folder.name,
                      count: controller.countForFolder(folder.id),
                      selected: selected == folder.id,
                      inactiveLabel: inactiveLabel,
                      badgeBg: badgeBg,
                      badgeFg: badgeFg,
                      onTap: (_) => controller.selectFolder(folder.id),
                      onShowMenu: (tabContext) =>
                          showFolderTabMenu(tabContext, folder),
                    ),
                  ),
                  if (isCreating)
                    _InlineCreateFolderField(
                      inactiveLabel: inactiveLabel,
                      onCancel: controller.cancelCreatingFolder,
                      onSave: (name) async {
                        final folder = await controller.createFolder(name);
                        controller.cancelCreatingFolder();
                        if (folder != null) {
                          controller.selectFolder(folder.id);
                        }
                      },
                    )
                  else
                    _ManageFolderNavTab(
                      onTap: () {
                        controller.startCreatingFolder();
                        onStartCreatingFolder();
                      },
                      color: inactiveLabel,
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _InlineCreateFolderField extends StatefulWidget {
  const _InlineCreateFolderField({
    required this.inactiveLabel,
    required this.onCancel,
    required this.onSave,
  });

  final Color inactiveLabel;
  final VoidCallback onCancel;
  final Future<void> Function(String name) onSave;

  @override
  State<_InlineCreateFolderField> createState() =>
      _InlineCreateFolderFieldState();
}

class _InlineCreateFolderFieldState extends State<_InlineCreateFolderField> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus || _saving || !mounted) return;
    final name = _textController.text.trim();
    if (name.isEmpty) {
      widget.onCancel();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    final name = _textController.text.trim();
    if (name.isEmpty) {
      widget.onCancel();
      return;
    }
    setState(() => _saving = true);
    await widget.onSave(name);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: SizedBox(
        width: 132,
        height: 28,
        child: TextField(
          controller: _textController,
          focusNode: _focusNode,
          enabled: !_saving,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          style: context.text.bodySmall?.copyWith(
            fontWeight: VitheyWeight.semibold,
            color: context.appColors.heading,
          ),
          decoration: InputDecoration(
            hintText: AppStrings.chatFolderNameHint,
            hintStyle: context.text.labelMedium?.copyWith(
              fontSize: 13,
              color: widget.inactiveLabel.withValues(alpha: 0.65),
            ),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            filled: true,
            fillColor: context.appColors.cardSurface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(99),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(99),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.6,
              ),
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
      ),
    );
  }
}

class _FolderNavTab extends StatelessWidget {
  const _FolderNavTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.inactiveLabel,
    required this.badgeBg,
    required this.badgeFg,
    required this.onTap,
    this.onShowMenu,
  });

  final String label;
  final int count;
  final bool selected;
  final Color inactiveLabel;
  final Color badgeBg;
  final Color badgeFg;
  final void Function(BuildContext tabContext) onTap;
  final void Function(BuildContext tabContext)? onShowMenu;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (tabContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: GestureDetector(
            onDoubleTap:
                onShowMenu != null ? () => onShowMenu!(tabContext) : null,
            child: Material(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.20)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(99),
              child: InkWell(
                onTap: () => onTap(tabContext),
                onLongPress:
                    onShowMenu != null ? () => onShowMenu!(tabContext) : null,
                borderRadius: BorderRadius.circular(99),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 3, 8, 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: context.text.bodySmall?.copyWith(
                          color: selected
                              ? AppColors.primaryLight
                              : inactiveLabel,
                          fontWeight: VitheyWeight.semibold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        height: 16,
                        constraints: const BoxConstraints(minWidth: 18),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primaryLight : badgeBg,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$count',
                          style: context.text.labelSmall?.copyWith(
                            fontSize: VitheyType.micro,
                            fontWeight: VitheyWeight.bold,
                            color: selected
                                ? context.scheme.onPrimary
                                : badgeFg,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ManageFolderNavTab extends StatelessWidget {
  const _ManageFolderNavTab({
    required this.onTap,
    required this.color,
  });

  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              VitheyIcon(LucideIcons.folder, size: 16, color: color),
              const SizedBox(width: 2),
              VitheyIcon(LucideIcons.plus, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
