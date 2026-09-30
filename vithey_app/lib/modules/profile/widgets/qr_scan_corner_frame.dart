import 'package:flutter/material.dart';

/// White rounded corner brackets for the QR scan viewfinder.
class QrScanCornerFrame extends StatelessWidget {
  const QrScanCornerFrame({
    super.key,
    required this.size,
    this.color = Colors.white,
    this.strokeWidth = 3.5,
    this.cornerRadius = 18,
    this.armFraction = 0.22,
  });

  final double size;
  final Color color;
  final double strokeWidth;
  final double cornerRadius;
  final double armFraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _QrScanCornerPainter(
          color: color,
          strokeWidth: strokeWidth,
          cornerRadius: cornerRadius,
          armFraction: armFraction,
        ),
      ),
    );
  }
}

class _QrScanCornerPainter extends CustomPainter {
  const _QrScanCornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerRadius,
    required this.armFraction,
  });

  final Color color;
  final double strokeWidth;
  final double cornerRadius;
  final double armFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final arm = size.width * armFraction;
    final r = cornerRadius;

    void corner({
      required Offset origin,
      required bool top,
      required bool left,
    }) {
      final path = Path();
      if (top && left) {
        path
          ..moveTo(origin.dx, origin.dy + arm)
          ..lineTo(origin.dx, origin.dy + r)
          ..quadraticBezierTo(origin.dx, origin.dy, origin.dx + r, origin.dy)
          ..lineTo(origin.dx + arm, origin.dy);
      } else if (top && !left) {
        path
          ..moveTo(origin.dx - arm, origin.dy)
          ..lineTo(origin.dx - r, origin.dy)
          ..quadraticBezierTo(origin.dx, origin.dy, origin.dx, origin.dy + r)
          ..lineTo(origin.dx, origin.dy + arm);
      } else if (!top && left) {
        path
          ..moveTo(origin.dx, origin.dy - arm)
          ..lineTo(origin.dx, origin.dy - r)
          ..quadraticBezierTo(origin.dx, origin.dy, origin.dx + r, origin.dy)
          ..lineTo(origin.dx + arm, origin.dy);
      } else {
        path
          ..moveTo(origin.dx - arm, origin.dy)
          ..lineTo(origin.dx - r, origin.dy)
          ..quadraticBezierTo(origin.dx, origin.dy, origin.dx, origin.dy - r)
          ..lineTo(origin.dx, origin.dy - arm);
      }
      canvas.drawPath(path, paint);
    }

    corner(origin: Offset.zero, top: true, left: true);
    corner(origin: Offset(size.width, 0), top: true, left: false);
    corner(origin: Offset(0, size.height), top: false, left: true);
    corner(origin: Offset(size.width, size.height), top: false, left: false);
  }

  @override
  bool shouldRepaint(covariant _QrScanCornerPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        cornerRadius != oldDelegate.cornerRadius ||
        armFraction != oldDelegate.armFraction;
  }
}
