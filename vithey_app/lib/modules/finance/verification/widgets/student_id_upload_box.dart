import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Empty dashed dropzone (Screen 1) or selected-file row (Screen 2).
class StudentIdUploadBox extends StatelessWidget {
  const StudentIdUploadBox({
    super.key,
    required this.fileName,
    required this.onPick,
    required this.onRemove,
    this.fileSizeBytes,
  });

  final String? fileName;
  final int? fileSizeBytes;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Student Document',
          style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: context.appColors.heading),
        ),
        const SizedBox(height: 8),
        if (fileName == null)
          _EmptyUpload(onPick: onPick)
        else
          _SelectedFileRow(
          fileName: fileName!,
          fileSizeBytes: fileSizeBytes,
          onRemove: onRemove,
        ),
      ],
    );
  }
}

class _EmptyUpload extends StatelessWidget {
  const _EmptyUpload({required this.onPick});

  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(VitheyRadii.sheet),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: context.appColors.border,
            radius: VitheyRadii.sheet,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              children: [
                // GenZ circular add-icon chrome.
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.30),
                    ),
                  ),
                  child: const VitheyIcon(
                    LucideIcons.plus,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Drag & drop your file here',
                  style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: context.appColors.heading),
                ),
                const SizedBox(height: 4),
                Text(
                  'or tap to browse',
                  style: context.text.bodySmall,
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: context.appColors.border),
                const SizedBox(height: 12),
                Text(
                  'JPG, PNG, or PDF (Max 5MB)',
                  style: context.text.bodySmall?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedFileRow extends StatelessWidget {
  const _SelectedFileRow({
    required this.fileName,
    required this.onRemove,
    this.fileSizeBytes,
  });

  final String fileName;
  final int? fileSizeBytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: VitheyIcon(
              _iconForName(fileName),
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: context.appColors.heading),
                ),
                if (fileSizeBytes != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatBytes(fileSizeBytes!),
                    style: context.text.bodySmall?.copyWith(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          VitheyIconButton(
            icon: LucideIcons.circleX,
            variant: VitheyIconButtonVariant.destructive,
            tooltip: 'Remove',
            onTap: onRemove,
          ),
        ],
      ),
    );
  }

  IconData _iconForName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return LucideIcons.fileText;
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return LucideIcons.fileText;
    }
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp')) {
      return LucideIcons.image;
    }
    return LucideIcons.fileText;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

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
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
