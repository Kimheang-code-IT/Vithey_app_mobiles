import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';

/// Share options: in-app share, save private, or system share (Telegram, etc.).
class ShareSheet extends StatefulWidget {
  const ShareSheet({
    super.key,
    required this.post,
    required this.onShared,
  });

  final FeedPost post;
  final VoidCallback onShared;

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  int? _loadingOption;
  final _repo = Get.find<PostRepository>();

  String get _shareText {
    final author = widget.post.author.fullName;
    final body = widget.post.content.trim();
    final snippet = body.isEmpty
        ? 'Check out this post on ${AppStrings.appName}'
        : (body.length > 160 ? '${body.substring(0, 160)}…' : body);
    return '$snippet\n\n— $author on ${AppStrings.appName}';
  }

  Future<void> _shareToApps() async {
    if (_loadingOption != null) return;
    setState(() => _loadingOption = 2);
    try {
      await Share.share(_shareText);
      widget.onShared();
      if (Get.isBottomSheetOpen ?? false) Get.back();
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not open share');
    } finally {
      if (mounted) setState(() => _loadingOption = null);
    }
  }

  Future<void> _submit(int option) async {
    if (_loadingOption != null) return;
    setState(() => _loadingOption = option);

    try {
      if (option == 0) {
        await _repo.sharePublicly(widget.post.id);
        widget.onShared();
        Get.back();
        Get.snackbar(AppStrings.appName, 'Shared for everyone');
      } else if (option == 1) {
        await _repo.savePrivately(widget.post.id);
        Get.back();
        Get.snackbar(AppStrings.appName, 'Saved privately');
      }
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not complete action');
    } finally {
      if (mounted) setState(() => _loadingOption = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: context.appColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Share this post',
            style: context.text.titleLarge?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _ShareOption(
            title: 'Share to apps',
            subtitle: 'Telegram, Messages, and more',
            icon: LucideIcons.share2,
            loading: _loadingOption == 2,
            onTap: _shareToApps,
          ),
          const SizedBox(height: 8),
          _ShareOption(
            title: 'Share for everyone',
            subtitle: 'Post to your Vithey feed',
            icon: LucideIcons.globe,
            loading: _loadingOption == 0,
            onTap: () => _submit(0),
          ),
          const SizedBox(height: 8),
          _ShareOption(
            title: 'Save privately',
            subtitle: 'Only you can see it',
            icon: LucideIcons.bookmark,
            loading: _loadingOption == 1,
            onTap: () => _submit(1),
          ),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(VitheyRadii.field),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(VitheyRadii.field),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: VitheyIcon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.text.labelLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.text.bodyMedium
                        ?.copyWith(color: colors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              VitheyIcon(LucideIcons.chevronRight, color: colors.muted, size: 20),
          ],
        ),
      ),
    );
  }
}
