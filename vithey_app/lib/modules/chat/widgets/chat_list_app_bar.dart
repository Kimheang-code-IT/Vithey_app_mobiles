import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/modules/chat/chat_list_controller.dart';
import 'package:aub_connect_app/modules/home/widgets/home_app_bar.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';

/// Home-style chat list header: title · search · inbox.
class ChatListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatListAppBar({super.key});

  static const double _extraTop = 24;
  static const double _barHeight = kToolbarHeight;

  @override
  Size get preferredSize => const Size.fromHeight(_barHeight + _extraTop + 1);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatListController>();
    final colors = context.appColors;
    final title = AppStrings.appName.split(' ').first;

    return Material(
      color: colors.cardSurface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: _extraTop),
          SizedBox(
            height: _barHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.headlineSmall?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  HomeAppBarAction(
                    icon: const VitheyIcon(LucideIcons.search),
                    onPressed: () => Get.toNamed(AppRoutes.search),
                    tooltip: 'Search',
                  ),
                  Obx(() {
                    final count = controller.messageRequests.length;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        HomeAppBarAction(
                          icon: const VitheyIcon(LucideIcons.mail),
                          onPressed: () => showMessageRequestsSheet(context),
                          tooltip: AppStrings.chatMessageRequests,
                        ),
                        if (count > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                count > 9 ? '9+' : '$count',
                                style: context.text.labelSmall?.copyWith(
                                  fontSize: 9,
                                  color: context.scheme.onPrimary,
                                  fontWeight: VitheyWeight.bold,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(width: 2),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: colors.border),
        ],
      ),
    );
  }
}

Future<void> showMessageRequestsSheet(BuildContext context) {
  final controller = Get.find<ChatListController>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final colors = ctx.appColors;
      final height = MediaQuery.sizeOf(ctx).height * 0.72;
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
                      AppStrings.chatMessageRequests,
                      style: context.text.titleLarge,
                    ),
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
                final requests = controller.messageRequests;
                if (requests.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No message requests right now.',
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium
                            ?.copyWith(color: colors.muted),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final request = requests[index];
                    return _InboxRequestTile(
                      request: request,
                      onAccept: () async {
                        await controller.acceptRequest(request);
                        if (ctx.mounted && controller.messageRequests.isEmpty) {
                          Navigator.of(ctx).pop();
                        }
                      },
                      onDecline: () => controller.declineRequest(request),
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

class _InboxRequestTile extends StatelessWidget {
  const _InboxRequestTile({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  final MessageRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                name: request.requester.fullName,
                imageUrl: request.requester.avatarUrl,
                radius: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requester.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall
                          ?.copyWith(fontWeight: VitheyWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Wants to message you',
                      style: context.text.labelMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (request.initialMessage.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              request.initialMessage,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(height: 1.35),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Decline',
                  onPressed: onDecline,
                  foregroundColor: colors.heading,
                  variant: CustomButtonVariant.outline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  label: 'Accept',
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
