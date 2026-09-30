import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/modules/auth/startup/startup_controller.dart';

/// Clipped left/right slide for Startup step content only.
/// AppBar and bottom nav stay outside this widget.
class StartupContentSwitcher extends StatefulWidget {
  const StartupContentSwitcher({
    super.key,
    required this.pages,
    this.gap = 24,
    this.duration = const Duration(milliseconds: 380),
  });

  final List<Widget> pages;
  final double gap;
  final Duration duration;

  @override
  State<StartupContentSwitcher> createState() => _StartupContentSwitcherState();
}

class _StartupContentSwitcherState extends State<StartupContentSwitcher>
    with SingleTickerProviderStateMixin {
  final StartupController _controller = Get.find<StartupController>();

  late final AnimationController _animation;
  late final Animation<double> _t;
  late Worker _stepWorker;

  int _from = 0;
  int _to = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _from = _controller.currentStep.value;
    _to = _from;
    _animation = AnimationController(vsync: this, duration: widget.duration);
    _t = CurvedAnimation(parent: _animation, curve: Curves.easeInOutCubic);
    _stepWorker = ever<int>(_controller.currentStep, _onStepChanged);
  }

  Future<void> _onStepChanged(int next) async {
    if (!mounted || next == _to || _busy) return;
    if (next < 0 || next >= widget.pages.length) return;

    _busy = true;
    _controller.isContentAnimating.value = true;
    setState(() {
      _from = _to;
      _to = next;
    });

    await _animation.forward(from: 0);
    if (!mounted) return;

    setState(() {
      _from = next;
      _to = next;
    });
    _animation.value = 0;
    _controller.isContentAnimating.value = false;
    _busy = false;
  }

  double _offsetFor(int index, double width, double progress) {
    final shown = _from + (_to - _from) * progress;
    return (index - shown) * (width + widget.gap);
  }

  @override
  void dispose() {
    _stepWorker.dispose();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return ClipRect(
          child: AnimatedBuilder(
            animation: _t,
            builder: (context, _) {
              final progress = _busy ? _t.value : 0.0;
              return Stack(
                clipBehavior: Clip.hardEdge,
                alignment: Alignment.topCenter,
                children: [
                  for (var i = 0; i < widget.pages.length; i++)
                    _slideChild(
                      index: i,
                      width: width,
                      progress: progress,
                      child: widget.pages[i],
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _slideChild({
    required int index,
    required double width,
    required double progress,
    required Widget child,
  }) {
    final dx = _offsetFor(index, width, progress);
    return Transform.translate(
      offset: Offset(dx, 0),
      child: SizedBox(
        width: width,
        height: double.infinity,
        child: IgnorePointer(
          ignoring: _busy || index != _to,
          child: child,
        ),
      ),
    );
  }
}
