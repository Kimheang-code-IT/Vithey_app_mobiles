import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_search_pill.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
    required this.onSubmitted,
    this.hintText = 'Search',
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onSubmitted;
  final String hintText;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colors.cardSurface,
      foregroundColor: colors.heading,
      leading: VitheyIconButton(
        icon: LucideIcons.arrowLeft,
        variant: VitheyIconButtonVariant.neutral,
        tooltip: 'Back',
        onTap: () => Navigator.of(context).maybePop(),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            return Semantics(
              label: hintText,
              child: VitheySearchPill(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                hintText: hintText,
                onChanged: onChanged,
                onSubmitted: (_) => onSubmitted(),
                onClear: value.text.isNotEmpty ? onClear : null,
              ),
            );
          },
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: colors.border),
      ),
    );
  }
}
