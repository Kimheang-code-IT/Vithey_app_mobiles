import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';import 'package:aub_connect_app/core/widgets/vithey_action_sheet.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/modules/search/widgets/search_highlight_text.dart';
import 'package:aub_connect_app/modules/search/widgets/search_result_tile_shell.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class SearchJobTile extends StatelessWidget {
  const SearchJobTile({
    super.key,
    required this.job,
    required this.query,
    required this.onTap,
  });

  final PostSearchResult job;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subtitle = [
      if (job.jobCompany != null) job.jobCompany!,
      if (job.jobLocation != null) job.jobLocation!,
    ].join(' · ');

    return SearchResultTileCard(
      onTap: onTap,
      onLongPress: () => _showActionSheet(context),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(VitheyRadii.media),
            child: Container(
              width: 56,
              height: 56,
              color: colors.inputFill,
              child: job.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: job.thumbnailUrl!, fit: BoxFit.cover)
                  : VitheyIcon(LucideIcons.briefcase, color: colors.muted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchHighlightText(
                  text: job.title,
                  query: query,
                  style: context.text.labelLarge!,
                  maxLines: 2,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
      title: job.title,
      actions: [
        VitheyActionSheetItem(
          label: 'View job',
          icon: LucideIcons.externalLink,
          onTap: onTap,
        ),
      ],
      cancelLabel: 'Cancel',
    );
  }
}
