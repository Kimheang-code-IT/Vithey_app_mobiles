import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class VerificationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VerificationAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Verification',
        style: context.text.titleLarge,
      ),
      actions: [
        VitheyIconButton(
          icon: LucideIcons.search,
          variant: VitheyIconButtonVariant.neutral,
          tooltip: 'Search',
          onTap: () => Get.toNamed(AppRoutes.search),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: context.appColors.border),
      ),
    );
  }
}
