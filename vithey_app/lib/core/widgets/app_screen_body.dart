import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// Ensures the main content area uses the themed page background (white in light mode).
class AppScreenBody extends StatelessWidget {
  const AppScreenBody({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final content = padding != null ? Padding(padding: padding!, child: child) : child;
    return ColoredBox(
      color: context.appColors.bodyBackground,
      child: content,
    );
  }
}
