import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';

/// Legacy preferred-size app bar (kept for screens that still need it).
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: context.appColors.cardSurface,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          const AppLogo(size: 28),
          const SizedBox(width: 8),
          Text(
            AppStrings.appName.split(' ').first,
            style: context.text.titleLarge?.copyWith(fontSize: 16),
          ),
        ],
      ),
      actions: [
        HomeAppBarAction(
          icon: const VitheyIcon(LucideIcons.search),
          onPressed: () => Get.toNamed(AppRoutes.search),
          tooltip: 'Search',
        ),
        HomeAppBarAction(
          icon: const VitheyIcon(LucideIcons.mapPinned),
          onPressed: () => Get.toNamed(AppRoutes.map),
          tooltip: 'Map',
        ),
        const HomeChatAppBarAction(),
        const HomeAppBarAction(
          icon: VitheyIcon(LucideIcons.wallet),
          onPressed: FinanceNavigation.openFinanceEntry,
          tooltip: 'Finance',
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: context.appColors.border),
      ),
    );
  }
}

/// Chat icon with notification-style unread count badge.
class HomeChatAppBarAction extends StatefulWidget {
  const HomeChatAppBarAction({super.key});

  @override
  State<HomeChatAppBarAction> createState() => _HomeChatAppBarActionState();
}

class _HomeChatAppBarActionState extends State<HomeChatAppBarAction> {
  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ChatRepository>()) {
      Get.find<ChatRepository>().ensureUnreadBadge();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ChatRepository>()) {
      return HomeAppBarAction(
        icon: const VitheyIcon(LucideIcons.messageCircle),
        onPressed: () => Get.toNamed(AppRoutes.chat),
        tooltip: 'Messages',
      );
    }

    return Obx(() {
      final count = Get.find<ChatRepository>().unreadCount.value;
      return HomeAppBarAction(
        icon: const VitheyIcon(LucideIcons.messageCircle),
        onPressed: () => Get.toNamed(AppRoutes.chat),
        tooltip: count > 0 ? 'Messages ($count)' : 'Messages',
        badgeCount: count,
      );
    });
  }
}

class HomeAppBarAction extends StatefulWidget {
  const HomeAppBarAction({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.badgeCount = 0,
  });

  final Widget icon;
  final VoidCallback onPressed;
  final String tooltip;

  /// Unread count badge (notification-style red pill). Hidden when 0.
  final int badgeCount;

  @override
  State<HomeAppBarAction> createState() => _HomeAppBarActionState();
}

class _HomeAppBarActionState extends State<HomeAppBarAction> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  Future<void> _handleTap() async {
    HapticFeedback.selectionClick();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final iconColor = colors.heading;
    final scale = _pressed
        ? 0.92
        : (_hovered || _focused)
            ? 1.04
            : 1.0;
    final radius = BorderRadius.circular(VitheyRadii.iconSquircle);
    final count = widget.badgeCount;

    // Badge must wrap the glyph only — not the 48px tap target — or it
    // floats at the corner of the button between neighboring icons.
    Widget glyph = IconTheme(
      data: IconThemeData(color: iconColor, size: 22),
      child: widget.icon,
    );

    if (count > 0) {
      final label = count > 99 ? '99+' : '$count';
      glyph = SizedBox(
        width: 28,
        height: 28,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            glyph,
            Positioned(
              top: -3,
              right: label.length >= 2 ? -10 : -6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: EdgeInsets.symmetric(
                  horizontal: label.length >= 2 ? 4 : 0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: colors.cardSurface, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Tooltip(
      message: widget.tooltip,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: VitheyRadii.iconButton,
          height: VitheyRadii.iconButton,
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.none,
            child: InkWell(
              onTap: _handleTap,
              onHover: (value) => setState(() => _hovered = value),
              onFocusChange: (value) => setState(() => _focused = value),
              onHighlightChanged: (value) => setState(() => _pressed = value),
              customBorder: RoundedRectangleBorder(borderRadius: radius),
              splashColor: colors.muted.withValues(alpha: 0.12),
              highlightColor: colors.muted.withValues(alpha: 0.08),
              child: Center(child: glyph),
            ),
          ),
        ),
      ),
    );
  }
}
