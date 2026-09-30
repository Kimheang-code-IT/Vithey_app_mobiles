import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/help_center/help_center_controller.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_menu_tile.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_section_label.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_tile_divider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class HelpCenterScreen extends GetView<HelpCenterController> {
  const HelpCenterScreen({super.key});

  static IconData _iconFor(String categoryId) {
    return switch (categoryId) {
      'account' => LucideIcons.user,
      'verification' => LucideIcons.badgeCheck,
      'finance' => LucideIcons.wallet,
      'jobs' => LucideIcons.briefcase,
      'chat' => LucideIcons.messageCircle,
      'ai' => LucideIcons.sparkles,
      _ => LucideIcons.circleHelp,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SettingsScaffold(
      title: 'Help Center',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: _SearchField(
              controller: controller.searchController,
              onChanged: (v) => controller.query.value = v,
            ),
          ),
          const SettingsSectionLabel(label: 'Topics'),
          Obx(() {
            final items = controller.filteredCategories;
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'No topics match your search.',
                  style: context.text.bodyMedium?.copyWith(color: colors.muted),
                ),
              );
            }
            return _CardGroup(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SettingsTileDivider(),
                  SettingsMenuTile(
                    icon: _iconFor(items[i].id),
                    label: items[i].title,
                    subtitle: '${items[i].topics.length} articles',
                    onTap: () => controller.openFaqCategory(items[i].id),
                  ),
                ],
              ],
            );
          }),
          const SettingsSectionLabel(label: 'Support'),
          _CardGroup(
            children: [
              SettingsMenuTile(
                icon: LucideIcons.mail,
                label: 'Email Support',
                subtitle: 'support@vithey.app',
                onTap: controller.contactSupport,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fill = colors.cardSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: context.text.bodyMedium?.copyWith(
          fontSize: 15,
          color: colors.heading,
        ),
        decoration: InputDecoration(
          hintText: 'Search help topics',
          hintStyle: context.text.bodyMedium?.copyWith(
            fontSize: 15,
            color: colors.muted,
          ),
          prefixIcon: Icon(LucideIcons.search, color: colors.muted, size: 22),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _CardGroup extends StatelessWidget {
  const _CardGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cardColor = context.appColors.cardSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(children: children),
        ),
      ),
    );
  }
}
