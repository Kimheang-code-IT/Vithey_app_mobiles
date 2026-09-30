import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/modules/chatbot/chatbot_controller.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ChatbotHistoryDrawer extends StatelessWidget {
  const ChatbotHistoryDrawer({super.key, required this.controller});

  final ChatbotController controller;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.86,
      backgroundColor: context.appColors.cardSurface,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Vithey AI',
                      style: context.text.headlineSmall,
                    ),
                  ),
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(VitheyRadii.pill),
                    child: InkWell(
                      onTap: controller.newChat,
                      borderRadius: BorderRadius.circular(VitheyRadii.pill),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            VitheyIcon(
                              LucideIcons.penLine,
                              size: 18,
                              color: context.scheme.onPrimary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'New chat',
                              style: context.text.bodySmall?.copyWith(
                                color: context.scheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CircleAction(
                    icon: LucideIcons.search,
                    tooltip: 'Search chats (coming soon)',
                    onTap: null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingSessions.value) {
                  return const LoadingWidget();
                }
                final sessions = _orderedSessions(controller.sortedSessions);
                if (sessions.isEmpty) {
                  return Center(
                    child: Text(
                      'No chat history yet',
                      style: TextStyle(color: context.appColors.muted),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                      child: Text(
                        'Recents',
                        style: context.text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    ...sessions.map(
                      (s) => _SessionTile(
                        session: s,
                        isSelected: controller.currentSessionId == s.id,
                        onTap: () => controller.selectSession(s.id),
                        onLongPress: () => _showSessionMenu(context, s),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Pinned chats float to the top; no separate "Pinned" section.
  List<AiSession> _orderedSessions(List<AiSession> source) {
    final list = List<AiSession>.from(source);
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  Future<void> _showSessionMenu(BuildContext context, AiSession session) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: context.appColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                ListTile(
                  leading: VitheyIcon(
                    session.isPinned
                        ? LucideIcons.pin
                        : LucideIcons.pin,
                    color: session.isPinned
                        ? AppColors.primary
                        : context.appColors.heading,
                  ),
                  title: Text(session.isPinned ? 'Unpin' : 'Pin'),
                  onTap: () {
                    Navigator.pop(ctx);
                    controller.togglePin(session);
                  },
                ),
                ListTile(
                  leading: VitheyIcon(
                    LucideIcons.pencil,
                    color: context.appColors.heading,
                  ),
                  title: const Text('Rename'),
                  onTap: () {
                    Navigator.pop(ctx);
                    controller.renameSession(session);
                  },
                ),
                ListTile(
                  leading: const VitheyIcon(LucideIcons.trash2, color: Colors.red),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    controller.deleteSession(session);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: context.appColors.cardSurface,
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onTap,
          icon: VitheyIcon(icon, color: context.appColors.heading, size: 22),
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final AiSession session;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.14)
                      : context.appColors.inputFill,
                  borderRadius: BorderRadius.circular(VitheyRadii.iconSquircle),
                ),
                child: VitheyIcon(
                  session.isPinned
                      ? LucideIcons.pin
                      : LucideIcons.messageCircle,
                  size: 20,
                  color: isSelected || session.isPinned
                      ? AppColors.primary
                      : context.appColors.muted,
                ),
              ),
              Expanded(
                child: Text(
                  session.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
