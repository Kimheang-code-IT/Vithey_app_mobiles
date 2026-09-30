import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';

/// ChatGPT-style “thinking / reasoning” while a mock (or live) reply is in flight.
class AssistantThinkingIndicator extends StatefulWidget {
  const AssistantThinkingIndicator({super.key, this.reasoning});

  /// Live word-by-word dream text. When empty, cycles placeholder lines.
  final String? reasoning;

  @override
  State<AssistantThinkingIndicator> createState() =>
      _AssistantThinkingIndicatorState();
}

class _AssistantThinkingIndicatorState extends State<AssistantThinkingIndicator>
    with TickerProviderStateMixin {
  static const _dreams = [
    'Reading your question',
    'Checking campus context',
    'Choosing a useful structure',
    'Drafting tables and examples',
  ];

  late final AnimationController _dots;
  late final AnimationController _dream;
  int _dreamIndex = 0;

  @override
  void initState() {
    super.initState();
    _dots = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _dream = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _dreamIndex = (_dreamIndex + 1) % _dreams.length);
          _dream.forward(from: 0);
        }
      });
    _dream.forward();
  }

  @override
  void dispose() {
    _dots.dispose();
    _dream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      liveRegion: true,
      label: 'Vithey AI is thinking',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppLogo(size: 28),
              const SizedBox(width: 8),
              Text('Thinking', style: context.text.labelLarge),
              const SizedBox(width: 6),
              reduceMotion ? _staticDots() : _animatedDots(),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: _dreamBody(reduceMotion),
          ),
        ],
      ),
    );
  }

  Widget _dreamBody(bool reduceMotion) {
    final live = widget.reasoning?.trim() ?? '';
    final style = context.text.bodySmall
        ?.copyWith(height: 1.45, fontStyle: FontStyle.italic);
    if (live.isNotEmpty) {
      return Text(live, style: style);
    }
    return FadeTransition(
      opacity: reduceMotion
          ? const AlwaysStoppedAnimation(1)
          : CurvedAnimation(parent: _dream, curve: Curves.easeInOut),
      child: Text(_dreams[_dreamIndex], style: style),
    );
  }

  Widget _staticDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _animatedDots() {
    return AnimatedBuilder(
      animation: _dots,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final opacity = ((_dots.value + i * 0.2) % 1.0) > 0.5 ? 1.0 : 0.3;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
