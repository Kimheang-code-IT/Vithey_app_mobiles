import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';

/// Floating pill bottom navigation used across main app screens.
///
/// Order: Profile (avatar) · Home · Reel · Chatbot/Chat · Notifications
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.avatarUrl,
    this.avatarName,
    /// When true (Messages screen), slot 3 shows a chat icon instead of chatbot.
    this.messagesMode = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? avatarUrl;
  final String? avatarName;
  final bool messagesMode;

  static const barHeight = 64.0;
  static const bottomMargin = 10.0;
  static const _radius = 32.0;

  /// Bottom inset so scroll content clears the floating pill.
  ///
  /// Use with [Scaffold.extendBody] — without this, lists slide under the bar
  /// and feel like they “scratch” when scrolling.
  static double scrollClearance(BuildContext context, {double extra = 12}) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final navBottom = safeBottom > bottomMargin ? safeBottom : bottomMargin;
    return barHeight + navBottom + extra;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final user = Get.isRegistered<CurrentUserService>()
        ? Get.find<CurrentUserService>()
        : null;
    final resolvedAvatar = avatarUrl ?? user?.avatarUrl;
    final resolvedName = avatarName ?? user?.displayName;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.cardSurface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.55),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SizedBox(
          height: barHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                _ProfileNavItem(
                  selected: currentIndex == 0,
                  avatarUrl: resolvedAvatar,
                  avatarName: resolvedName,
                  onTap: () => onTap(0),
                ),
                _NavIcon(
                  icon: LucideIcons.house,
                  selected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavIcon(
                  icon: LucideIcons.clapperboard,
                  selected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavIcon(
                  icon: messagesMode
                      ? LucideIcons.messageCircle
                      : LucideIcons.sparkles,
                  selected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
                _NotificationNavItem(
                  selected: currentIndex == 4,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactive = context.appColors.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: VitheyIcon(
              icon,
              size: 22,
              color: selected ? AppColors.primary : inactive,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationNavItem extends StatelessWidget {
  const _NotificationNavItem({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactive = context.appColors.muted;
    final repo = Get.isRegistered<NotificationRepository>()
        ? Get.find<NotificationRepository>()
        : null;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: repo == null
                ? VitheyIcon(
                    LucideIcons.bell,
                    size: 22,
                    color: selected ? AppColors.primary : inactive,
                  )
                : Obx(() {
                    final count = repo.unreadCount.value;
                    return Badge(
                      isLabelVisible: count > 0,
                      backgroundColor: AppColors.error,
                      label: Text(
                        count > 99 ? '99+' : '$count',
                        style: context.text.bodyMedium?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: VitheyIcon(
                        LucideIcons.bell,
                        size: 22,
                        color: selected ? AppColors.primary : inactive,
                      ),
                    );
                  }),
          ),
        ),
      ),
    );
  }
}

class _ProfileNavItem extends StatelessWidget {
  const _ProfileNavItem({
    required this.selected,
    required this.onTap,
    this.avatarUrl,
    this.avatarName,
  });

  final bool selected;
  final VoidCallback onTap;
  final String? avatarUrl;
  final String? avatarName;

  @override
  Widget build(BuildContext context) {
    final inactive = context.appColors.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : inactive.withValues(alpha: 0.35),
                width: selected ? 2 : 1.25,
              ),
            ),
            child: UserAvatar(
              imageUrl: avatarUrl,
              name: avatarName,
              radius: 14,
            ),
          ),
        ),
      ),
    );
  }
}
