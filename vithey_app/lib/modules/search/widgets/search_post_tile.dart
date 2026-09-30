import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:aub_connect_app/core/widgets/vithey_action_sheet.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/modules/search/widgets/search_highlight_text.dart';
import 'package:aub_connect_app/modules/search/widgets/search_result_tile_shell.dart';
import 'package:intl/intl.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class SearchPostTile extends StatelessWidget {
  const SearchPostTile({
    super.key,
    required this.post,
    required this.query,
    required this.onTap,
  });

  final PostSearchResult post;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final meta = _metaLabel(post);

    return SearchResultTileCard(
      onTap: onTap,
      onLongPress: () => _showActionSheet(context),
      child: Row(
        children: [
          _Thumbnail(url: post.thumbnailUrl, colors: colors),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchHighlightText(
                  text: post.title,
                  query: query,
                  style: context.text.bodyMedium!
                      .copyWith(fontWeight: VitheyWeight.medium),
                  maxLines: 2,
                ),
                if (meta != null) ...[
                  const SizedBox(height: 4),
                  Text(meta,
                      style: context.text.bodySmall?.copyWith(fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showActionSheet(BuildContext context) {
    return showVitheyActionSheet<void>(
      context: context,
      title: post.title,
      actions: [
        VitheyActionSheetItem(
          label: 'Open post',
          icon: LucideIcons.externalLink,
          onTap: onTap,
        ),
      ],
      cancelLabel: 'Cancel',
    );
  }

  String? _metaLabel(PostSearchResult post) {
    final parts = <String>[post.authorName];
    if (post.createdAt != null) {
      parts.add(_relativeTime(post.createdAt!));
    }
    return parts.join(' · ');
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat.MMMd().format(time);
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.url, required this.colors});

  final String? url;
  final AppSemanticColors colors;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(VitheyRadii.media),
      child: Container(
        width: 56,
        height: 56,
        color: colors.inputFill,
        child: url != null
            ? CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover)
            : VitheyIcon(LucideIcons.image, color: colors.muted),
      ),
    );
  }
}
