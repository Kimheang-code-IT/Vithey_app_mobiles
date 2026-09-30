import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';

/// Clipped left/right slide for Sign Up Part 1 ↔ Part 2 **fields only**.
/// Slides stay inside the padded form lane (do not reach the phone edge).
/// [gap] is the empty space between the outgoing and incoming parts.
class RegisterStepSlider extends StatefulWidget {
  const RegisterStepSlider({
    super.key,
    required this.part1,
    required this.part2,
    this.gap = 24,
    this.duration = const Duration(milliseconds: 380),
  });

  final Widget part1;
  final Widget part2;
  final double gap;
  final Duration duration;

  @override
  State<RegisterStepSlider> createState() => _RegisterStepSliderState();
}

class _RegisterStepSliderState extends State<RegisterStepSlider>
    with SingleTickerProviderStateMixin {
  final AuthController _auth = Get.find<AuthController>();

  late final AnimationController _controller;
  late final Animation<double> _t;
  late Worker _stepWorker;

  int _from = 0;
  int _to = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _from = _auth.registerStep.value;
    _to = _from;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _stepWorker = ever<int>(_auth.registerStep, _onStepChanged);
  }

  Future<void> _onStepChanged(int next) async {
    if (!mounted || next == _to || _busy) return;

    _busy = true;
    _auth.isRegisterStepAnimating.value = true;
    setState(() {
      _from = _to;
      _to = next;
    });

    await _controller.forward(from: 0);
    if (!mounted) return;

    setState(() {
      _from = next;
      _to = next;
    });
    _controller.value = 0;
    _auth.isRegisterStepAnimating.value = false;
    _busy = false;
  }

  double _offsetFor(int index, double width, double progress) {
    // progress 0 → show [_from]; progress 1 → show [_to]
    // Map to absolute step positions 0 and 1.
    final shown = _from + (_to - _from) * progress;
    return (index - shown) * (width + widget.gap);
  }

  @override
  void dispose() {
    _stepWorker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        // Only clip while sliding. At rest, ClipRect chops focus rings /
        // field borders (looks like a broken outline on Confirm Password).
        final stack = AnimatedBuilder(
          animation: _t,
          builder: (context, _) {
            final progress = _busy ? _t.value : 0.0;
            return Stack(
              clipBehavior: _busy ? Clip.hardEdge : Clip.none,
              alignment: Alignment.topCenter,
              children: [
                _slideChild(
                  index: 0,
                  width: width,
                  progress: progress,
                  child: widget.part1,
                ),
                _slideChild(
                  index: 1,
                  width: width,
                  progress: progress,
                  child: widget.part2,
                ),
              ],
            );
          },
        );

        if (!_busy) return stack;
        return ClipRect(child: stack);
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
        child: IgnorePointer(
          ignoring: _busy || index != _to,
          child: child,
        ),
      ),
    );
  }
}
