import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/modules/finance/finance_controller.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class FinanceAppBar extends GetView<FinanceController>
    implements PreferredSizeWidget {
  const FinanceAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final colors = context.appColors;

    return Obx(() {
      final isSearchActive = controller.isSearchActive.value;
      final hasQuery = controller.searchQuery.value.isNotEmpty;

      return AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: canPop ? 0 : 16,
        automaticallyImplyLeading: canPop && !isSearchActive,
        leading: isSearchActive
            ? VitheyIconButton(
                icon: LucideIcons.arrowLeft,
                variant: VitheyIconButtonVariant.neutral,
                tooltip: 'Back',
                onTap: controller.closeSearch,
              )
            : null,
        title: isSearchActive
            ? _FinanceSearchField(
                controller: controller.searchController,
                focusNode: controller.searchFocusNode,
                hasQuery: hasQuery,
                onChanged: controller.onSearchChanged,
                onClear: controller.clearSearch,
              )
            : Text(
                'Finance',
                style: context.text.titleLarge,
              ),
        actions: [
          VitheyIconButton(
            icon: isSearchActive ? LucideIcons.x : LucideIcons.search,
            variant: VitheyIconButtonVariant.neutral,
            tooltip: AppStrings.financeSearchHint,
            onTap: controller.toggleSearch,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colors.border),
        ),
      );
    });
  }
}

class _FinanceSearchField extends StatelessWidget {
  const _FinanceSearchField({
    required this.controller,
    required this.focusNode,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: AppStrings.financeSearchHint,
          hintStyle: context.text.titleSmall
              ?.copyWith(fontWeight: FontWeight.w500, color: colors.muted),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          filled: true,
          fillColor: colors.inputFill,
          prefixIcon:
              VitheyIcon(LucideIcons.search, color: colors.muted, size: 20),
          suffixIcon: hasQuery
              ? IconButton(
                  icon: VitheyIcon(LucideIcons.x, color: colors.muted, size: 18),
                  onPressed: onClear,
                  tooltip: AppStrings.clearSearch,
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(99),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(99),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
