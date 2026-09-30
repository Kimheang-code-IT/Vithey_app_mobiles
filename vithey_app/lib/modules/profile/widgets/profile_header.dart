import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/profile/utils/profile_format.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key, required this.profile});

  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'Likes',
              value: formatProfileCount(profile.likeCount),
            ),
          ),
          Expanded(
            child: _StatItem(
              label: 'Followers',
              value: formatProfileCount(profile.followerCount),
            ),
          ),
          Expanded(
            child: _StatItem(
              label: 'Following',
              value: formatProfileCount(profile.followingCount),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: context.text.titleLarge?.copyWith(
            fontSize: 17,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.text.bodySmall?.copyWith(height: 1.1),
        ),
      ],
    );
  }
}

class ProfileActionRow extends StatelessWidget {
  const ProfileActionRow({
    super.key,
    required this.isOwnProfile,
    required this.isFollowing,
    required this.isStudentVerified,
    required this.onFollow,
    required this.onMessage,
    required this.onEditProfile,
    required this.onVerifyStudent,
    required this.onShare,
  });

  final bool isOwnProfile;
  final bool isFollowing;
  final bool isStudentVerified;
  final VoidCallback onFollow;
  final VoidCallback onMessage;
  final VoidCallback onEditProfile;
  final VoidCallback onVerifyStudent;
  final VoidCallback onShare;

  static const _buttonGap = 16.0;
  static const _actionMinHeight = 40.0;
  static const _actionHorizontalInset = 10.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        if (isOwnProfile) ...[
          CustomButton(
            label: 'Edit Profile',
            minHeight: _actionMinHeight,
            horizontalInset: _actionHorizontalInset,
            onPressed: onEditProfile,
          ),
          const SizedBox(width: _buttonGap),
          CustomButton(
            label: isStudentVerified ? 'Review' : 'Verify',
            variant: CustomButtonVariant.outline,
            minHeight: _actionMinHeight,
            horizontalInset: _actionHorizontalInset,
            onPressed: onVerifyStudent,
          ),
        ] else ...[
          if (isFollowing)
            CustomButton(
              label: 'Unfollow',
              variant: CustomButtonVariant.outline,
              minHeight: _actionMinHeight,
              horizontalInset: _actionHorizontalInset,
              onPressed: onFollow,
            )
          else
            CustomButton(
              label: 'Follow',
              minHeight: _actionMinHeight,
              horizontalInset: _actionHorizontalInset,
              onPressed: onFollow,
            ),
          const SizedBox(width: _buttonGap),
          CustomButton(
            label: 'Message',
            variant: CustomButtonVariant.outline,
            minHeight: _actionMinHeight,
            horizontalInset: _actionHorizontalInset,
            onPressed: onMessage,
          ),
        ],
        const SizedBox(width: _buttonGap),
        // GenZ round icon chrome — 48px tap target.
        VitheyIconButton(
          icon: LucideIcons.share,
          onTap: onShare,
          tooltip: 'Share profile',
          circle: true,
        ),
      ],
      ),
    );
  }
}

void shareProfileLink(String userId, String name) {
  Share.share('Check out $name on Vithey App');
}

void openVerifyStudent() => Get.toNamed(AppRoutes.studentVerification);
