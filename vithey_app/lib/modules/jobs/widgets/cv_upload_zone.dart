import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class CvUploadZone extends StatelessWidget {
  const CvUploadZone({
    super.key,
    required this.policyLabel,
    required this.enabled,
    required this.onTap,
    this.compact = false,
  });

  final String policyLabel;
  final bool enabled;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final heading = context.appColors.heading;
    final muted = context.appColors.muted;
    final border = enabled
        ? context.appColors.border
        : context.appColors.border.withValues(alpha: 0.5);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 0 : 20,
        vertical: compact ? 0 : 8,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: CustomPaint(
            painter: _DashedRectPainter(color: border, radius: 20),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: compact ? 24 : 32,
                horizontal: 20,
              ),
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.scheme.primary.withValues(
                        alpha: enabled ? 0.12 : 0.06,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: enabled ? 1 : 0.5,
                      child: VitheyIcon(
                        LucideIcons.upload,
                        size: 40,
                        color: context.scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.dragDropCv,
                    textAlign: TextAlign.center,
                    style: context.text.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: enabled ? heading : muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.orTapToBrowse,
                    style: context.text.bodyMedium?.copyWith(color: muted),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: border, height: 1),
                  const SizedBox(height: 12),
                  Text(
                    policyLabel,
                    style: context.text.bodySmall?.copyWith(fontSize: 12, color: muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    _drawDashedPath(canvas, path, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
  const dashWidth = 6.0;
  const dashSpace = 4.0;
  for (final metric in path.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      final next = distance + dashWidth;
      final extractPath =
          metric.extractPath(distance, next.clamp(0, metric.length));
      canvas.drawPath(extractPath, paint);
      distance = next + dashSpace;
    }
  }
}
