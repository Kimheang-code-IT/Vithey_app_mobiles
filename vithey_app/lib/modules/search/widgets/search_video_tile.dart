import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:aub_connect_app/core/widgets/vithey_action_sheet.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/modules/search/widgets/search_highlight_text.dart';
import 'package:aub_connect_app/modules/search/widgets/search_result_tile_shell.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class SearchVideoTile extends StatelessWidget {
  const SearchVideoTile({
    super.key,
    required this.video,
    required this.query,
    required this.onTap,
  });

  final PostSearchResult video;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SearchResultTileCard(
      onTap: onTap,
      onLongPress: () => _showActionSheet(context),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(VitheyRadii.media),
                child: Container(
                  width: 80,
                  height: 48,
                  color: colors.inputFill,
                  child: video.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: video.thumbnailUrl!, fit: BoxFit.cover)
                      : VitheyIcon(LucideIcons.video,
                          color: colors.muted),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const VitheyIcon(LucideIcons.play,
                    color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SearchHighlightText(
              text: video.title,
              query: query,
              style: context.text.bodyMedium!
                  .copyWith(fontWeight: VitheyWeight.medium),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showActionSheet(BuildContext context) {
    return showVitheyActionSheet<void>(
      context: context,
      title: video.title,
      actions: [
        VitheyActionSheetItem(
          label: 'Watch video',
          icon: LucideIcons.play,
          onTap: onTap,
        ),
      ],
      cancelLabel: 'Cancel',
    );
  }
}
