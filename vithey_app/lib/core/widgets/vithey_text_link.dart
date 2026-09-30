import 'package:flutter/material.dart';

/// Inline text link ("Forgot password?", "Sign up") used next to body copy.
///
/// Not a primary CTA — for those use [CustomButton]. Extends [TextButton] so
/// it can also be passed to `Get.snackbar(mainButton: ...)`.
class VitheyTextLink extends TextButton {
  // Not const: styleFrom builds the compact inline-link style at runtime.
  VitheyTextLink({
    super.key,
    required String label,
    required super.onPressed,
    Color? color,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w600,
  }) : super(
          style: TextButton.styleFrom(
            // Compact inline link: tight padding, no minimum size, no
            // enlarged tap target — it sits inside body copy.
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            foregroundColor: color,
            textStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
              fontFamily: null,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            ),
          ),
        );
}
