import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/post_author.dart';

class MentionUserBox extends StatelessWidget {
  const MentionUserBox({
    super.key,
    required this.users,
    required this.onSelect,
  });

  final List<PostAuthor> users;
  final ValueChanged<PostAuthor> onSelect;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(VitheyRadii.field),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 160),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, index) {
            final user = users[index];
            return ListTile(
              dense: true,
              title: Text(
                user.fullName,
                style: context.text.titleMedium?.copyWith(fontSize: 14),
              ),
              subtitle: Text(
                '@${user.fullName.replaceAll(' ', '')}',
                style: context.text.bodyMedium?.copyWith(fontSize: 12),
              ),
              onTap: () => onSelect(user),
            );
          },
        ),
      ),
    );
  }
}
