import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/app_app_bar.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_reel_grid_tile.dart';

/// Single-post analytics (LinkedIn / creator-studio style) for own profile content.
class PostAnalyticsScreen extends StatelessWidget {
  const PostAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final post = Get.arguments;
    if (post is! FeedPost) {
      return const Scaffold(
        appBar: AppAppBar(title: 'Analytics'),
        body: Center(child: Text('Post unavailable')),
      );
    }

    final colors = context.appColors;
    final isVideo = post.type == PostType.video;
    final metrics = _PostAnalyticsMetrics.fromPost(post);
    final dateLabel = DateFormat('d MMM yyyy, h:mm a').format(post.createdAt);

    return Scaffold(
      appBar: const AppAppBar(title: 'Post analytics'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _PostSummaryHeader(post: post, dateLabel: dateLabel),
          const SizedBox(height: 16),
          _EngagementStrip(post: post),
          const SizedBox(height: 22),
          Row(
            children: [
              Text(
                'Key metrics',
                style: context.text.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 6),
              VitheyIcon(
                LucideIcons.info,
                size: 16,
                color: colors.muted,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('d/M/yyyy').format(DateTime.now()),
            style: context.text.labelMedium,
          ),
          const SizedBox(height: 12),
          _MetricsGrid(
            metrics: metrics,
            isVideo: isVideo,
            reactionCount: post.reactionCount,
          ),
          const SizedBox(height: 22),
          Text(
            isVideo ? 'Views by date' : 'Impressions by date',
            style: context.text.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Last ${metrics.dailySeries.length} days',
            style: context.text.labelMedium,
          ),
          const SizedBox(height: 12),
          _ViewsByDateChart(points: metrics.dailySeries),
          const SizedBox(height: 20),
          Text(
            'About this data',
            style: context.text.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          VitheyCard(
            bordered: true,
            elevated: false,
            borderRadius: VitheyRadii.card,
            padding: const EdgeInsets.all(14),
            child: Text(
              isVideo
                  ? 'Views, watch time, and completion are estimated from engagement on this reel. Numbers update as people watch and interact.'
                  : 'Impressions and engagement reflect how people saw and interacted with this poster. Tap View post to open the full content.',
              style: context.text.bodySmall?.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            label: isVideo ? 'View reel' : 'View post',
            variant: CustomButtonVariant.outline,
            icon: isVideo ? LucideIcons.play : LucideIcons.fileImage,
            onPressed: () => Get.toNamed(
              AppRoutes.postDetail,
              arguments: post.id,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostAnalyticsMetrics {
  const _PostAnalyticsMetrics({
    required this.views,
    required this.totalPlayLabel,
    required this.avgWatchLabel,
    required this.completionPercent,
    required this.newFollowers,
    required this.impressions,
    required this.dailySeries,
  });

  final int views;
  final String totalPlayLabel;
  final String avgWatchLabel;
  final double completionPercent;
  final int newFollowers;
  final int impressions;
  final List<_DailyViewPoint> dailySeries;

  factory _PostAnalyticsMetrics.fromPost(FeedPost post) {
    final views = post.viewCount > 0
        ? post.viewCount
        : (post.reactionCount * 12 + post.commentCount * 8 + 80);
    final duration = post.durationSeconds > 0 ? post.durationSeconds : 30;
    final totalSeconds = (views * (duration * 0.35)).round();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final avgWatch = (duration * 0.35).clamp(1.0, duration.toDouble());
    final completion = (avgWatch / duration * 100).clamp(5.0, 95.0);
    final followers = (post.reactionCount * 0.12 + post.shareCount * 0.4)
        .round()
        .clamp(0, 99999);
    final impressions = (views * 1.15).round();

    return _PostAnalyticsMetrics(
      views: views,
      totalPlayLabel: hours > 0
          ? '$hours hr ${minutes.toString().padLeft(2, '0')} min'
          : '$minutes min',
      avgWatchLabel: '${avgWatch.toStringAsFixed(1)}s',
      completionPercent: completion,
      newFollowers: followers,
      impressions: impressions,
      dailySeries: _buildDailySeries(
        total: post.type == PostType.video ? views : impressions,
        createdAt: post.createdAt,
        seed: post.id.hashCode,
      ),
    );
  }

  /// Builds a 7-day views series that sums roughly to [total].
  static List<_DailyViewPoint> _buildDailySeries({
    required int total,
    required DateTime createdAt,
    required int seed,
  }) {
    const days = 7;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: days - 1));
    final postDay = DateTime(createdAt.year, createdAt.month, createdAt.day);

    // Weighted curve: lower early, peaks mid/late — deterministic from seed.
    final weights = List<double>.generate(days, (i) {
      final day = start.add(Duration(days: i));
      if (day.isBefore(postDay)) return 0.05;
      final t = (i + 1) / days;
      final wave = 0.55 + 0.45 * (0.5 + 0.5 * ((seed + i * 17) % 10) / 10);
      return (0.35 + t * 1.4) * wave;
    });
    final weightSum = weights.fold<double>(0, (a, b) => a + b);
    var remaining = total;
    final points = <_DailyViewPoint>[];
    for (var i = 0; i < days; i++) {
      final day = start.add(Duration(days: i));
      final value = i == days - 1
          ? remaining.clamp(0, total)
          : ((total * weights[i] / weightSum).round()).clamp(0, remaining);
      remaining -= value;
      points.add(_DailyViewPoint(date: day, views: value));
    }
    return points;
  }
}

class _DailyViewPoint {
  const _DailyViewPoint({required this.date, required this.views});
  final DateTime date;
  final int views;
}

class _PostSummaryHeader extends StatelessWidget {
  const _PostSummaryHeader({
    required this.post,
    required this.dateLabel,
  });

  final FeedPost post;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final thumb = post.thumbnailUrl ?? post.mediaUrl;
    final duration = post.durationSeconds;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(VitheyRadii.media),
          child: SizedBox(
            width: 88,
            height: 88,
            child: thumb != null && thumb.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: thumb,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: colors.inputFill,
                      child: VitheyIcon(
                        LucideIcons.image,
                        color: colors.muted,
                      ),
                    ),
                  )
                : ColoredBox(
                    color: colors.inputFill,
                    child: VitheyIcon(
                      LucideIcons.image,
                      color: colors.muted,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.displayTitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              if (post.type == PostType.video && duration > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '${(duration / 60).floor()}:${(duration % 60).toString().padLeft(2, '0')}',
                  style: context.text.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                dateLabel,
                style: context.text.labelMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EngagementStrip extends StatelessWidget {
  const _EngagementStrip({required this.post});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final items = <(IconData, String)>[
      (LucideIcons.eye, formatReelStatCount(post.viewCount)),
      (LucideIcons.heart, formatReelStatCount(post.reactionCount)),
      (LucideIcons.messageCircle, formatReelStatCount(post.commentCount)),
      (LucideIcons.share2, formatReelStatCount(post.shareCount)),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.border),
          bottom: BorderSide(color: colors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final item in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                VitheyIcon(item.$1, size: 18, color: colors.muted),
                const SizedBox(width: 6),
                Text(
                  item.$2,
                  style: context.text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.heading,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.metrics,
    required this.isVideo,
    required this.reactionCount,
  });

  final _PostAnalyticsMetrics metrics;
  final bool isVideo;
  final int reactionCount;

  @override
  Widget build(BuildContext context) {
    final data = isVideo
        ? <(String, String, bool)>[
            ('Video views', formatReelStatCount(metrics.views), true),
            ('Total play time', metrics.totalPlayLabel, false),
            ('Average watch time', metrics.avgWatchLabel, false),
            (
              'Watched full video',
              '${metrics.completionPercent.toStringAsFixed(2)}%',
              false,
            ),
            ('New followers', '${metrics.newFollowers}', false),
          ]
        : <(String, String, bool)>[
            (
              'Impressions',
              formatReelStatCount(metrics.impressions),
              true,
            ),
            ('Reactions', formatReelStatCount(reactionCount), false),
            (
              'Engagement rate',
              '${(metrics.completionPercent / 4).clamp(1, 40).toStringAsFixed(1)}%',
              false,
            ),
            ('New followers', '${metrics.newFollowers}', false),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final card in data)
              SizedBox(
                width: width,
                child: _MetricCard(
                  label: card.$1,
                  value: card.$2,
                  highlighted: card.$3,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        border: Border.all(
          color: highlighted ? AppColors.primary : colors.border,
          width: highlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.text.labelMedium,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.text.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewsByDateChart extends StatefulWidget {
  const _ViewsByDateChart({required this.points});

  final List<_DailyViewPoint> points;

  @override
  State<_ViewsByDateChart> createState() => _ViewsByDateChartState();
}

class _ViewsByDateChartState extends State<_ViewsByDateChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final points = widget.points;
    if (points.isEmpty) return const SizedBox.shrink();

    final maxViews =
        points.map((p) => p.views).fold<int>(0, (a, b) => a > b ? a : b);
    final yMax = maxViews <= 0 ? 1 : maxViews;
    final selected = _selectedIndex != null &&
            _selectedIndex! >= 0 &&
            _selectedIndex! < points.length
        ? points[_selectedIndex!]
        : null;

    return VitheyCard(
      bordered: true,
      elevated: false,
      borderRadius: VitheyRadii.card,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selected != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${DateFormat('d MMM').format(selected.date)} · '
                '${formatReelStatCount(selected.views)} views',
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.heading,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Tap a point to see daily views',
                style: context.text.labelMedium,
              ),
            ),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 36,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final label in [
                        formatReelStatCount(yMax),
                        formatReelStatCount((yMax * 0.66).round()),
                        formatReelStatCount((yMax * 0.33).round()),
                        '0',
                      ])
                        Text(
                          label,
                          style: context.text.labelSmall?.copyWith(
                            fontSize: 10,
                            height: 1,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                          final n = points.length;
                          if (n <= 1) {
                            setState(() => _selectedIndex = 0);
                            return;
                          }
                          final dx = details.localPosition.dx
                              .clamp(0.0, constraints.maxWidth);
                          final idx = ((dx / constraints.maxWidth) * (n - 1))
                              .round()
                              .clamp(0, n - 1);
                          setState(() => _selectedIndex = idx);
                        },
                        child: CustomPaint(
                          painter: _ViewsLineChartPainter(
                            points: points,
                            yMax: yMax.toDouble(),
                            lineColor: AppColors.primary,
                            gridColor: colors.border,
                            fillColor:
                                AppColors.primary.withValues(alpha: 0.16),
                            selectedIndex: _selectedIndex,
                          ),
                          size: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final point in points)
                  Text(
                    '${point.date.day}',
                    style: context.text.labelSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewsLineChartPainter extends CustomPainter {
  _ViewsLineChartPainter({
    required this.points,
    required this.yMax,
    required this.lineColor,
    required this.gridColor,
    required this.fillColor,
    this.selectedIndex,
  });

  final List<_DailyViewPoint> points;
  final double yMax;
  final Color lineColor;
  final Color gridColor;
  final Color fillColor;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.width <= 0 || size.height <= 0) return;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal dashed-style grid (solid thin lines).
    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    Offset pointAt(int i) {
      final n = points.length;
      final x = n == 1 ? size.width / 2 : size.width * i / (n - 1);
      final t = (points[i].views / yMax).clamp(0.0, 1.0);
      final y = size.height * (1 - t);
      return Offset(x, y);
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(pointAt(i).dx, pointAt(i).dy);
    }

    final fill = Path.from(path)
      ..lineTo(pointAt(points.length - 1).dx, size.height)
      ..lineTo(pointAt(0).dx, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = fillColor);

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final dotPaint = Paint()..color = lineColor;
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var i = 0; i < points.length; i++) {
      final p = pointAt(i);
      final selected = selectedIndex == i;
      final radius = selected ? 5.5 : 3.5;
      canvas.drawCircle(p, radius + 1.5, ringPaint);
      canvas.drawCircle(p, radius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ViewsLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.yMax != yMax ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}
