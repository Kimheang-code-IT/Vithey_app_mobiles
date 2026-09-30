import 'package:flutter/material.dart';

/// Staggered slide-and-fade entrance used when the notification list
/// (re)appears, e.g. after switching filter tabs.
///
/// [index] controls the stagger delay (capped so long lists settle quickly).
/// [direction] slides content in from the right (1) or left (-1), matching
/// the direction the user moved between tabs.
class NotificationListEntrance extends StatefulWidget {
  const NotificationListEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.direction = 1,
  });

  final Widget child;
  final int index;
  final int direction;

  @override
  State<NotificationListEntrance> createState() =>
      _NotificationListEntranceState();
}

class _NotificationListEntranceState extends State<NotificationListEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 45 * widget.index.clamp(0, 8));
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0.10 * widget.direction, 0.06),
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
