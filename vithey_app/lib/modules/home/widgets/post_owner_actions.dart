import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/widgets/vithey_action_sheet.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class PostOwnerActions extends StatelessWidget {
  const PostOwnerActions({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return VitheyIconButton(
      icon: LucideIcons.ellipsis,
      variant: VitheyIconButtonVariant.neutral,
      tooltip: 'Post actions',
      onTap: () => _showActions(context),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final action = await showVitheyActionSheet<_PostOwnerAction>(
      context: context,
      title: 'Post actions',
      actions: [
        VitheyActionSheetAction(
          value: _PostOwnerAction.edit,
          label: 'Edit post',
          subtitle: 'Update text, media, or job details',
          icon: LucideIcons.pencil,
        ),
        VitheyActionSheetAction(
          value: _PostOwnerAction.delete,
          label: 'Delete post',
          subtitle: 'Permanently remove this post',
          icon: LucideIcons.trash2,
          destructive: true,
        ),
      ],
    );
    if (action == _PostOwnerAction.edit) onEdit();
    if (action == _PostOwnerAction.delete) onDelete();
  }
}

enum _PostOwnerAction { edit, delete }
