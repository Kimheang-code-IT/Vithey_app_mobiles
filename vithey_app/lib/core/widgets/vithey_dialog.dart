import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:flutter/material.dart';

/// App-wide themed dialog shell for custom content (not yes/no confirms).
///
/// Use [showConfirmDialog] for logout / delete / accept-reject.
/// Use this for success panels, rename prompts, and other custom bodies.
class VitheyDialog extends StatelessWidget {
  const VitheyDialog({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 24, 24, 20),
    this.maxWidth = 420,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Dialog(
      backgroundColor: colors.cardSurface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VitheyRadii.sheet),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Shows a [VitheyDialog] with the given [child] as content.
Future<T?> showVitheyDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(24, 24, 24, 20),
  double maxWidth = 420,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black45,
    builder: (context) => VitheyDialog(
      padding: padding,
      maxWidth: maxWidth,
      child: child,
    ),
  );
}
