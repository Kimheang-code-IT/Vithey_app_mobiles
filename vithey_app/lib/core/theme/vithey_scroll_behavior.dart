import 'package:flutter/material.dart';

/// App-wide scroll behavior.
///
/// Disables Android Material 3 stretch overscroll, which feels like the screen
/// “scratches” or rubber-bands when lists hit the edge — especially behind the
/// floating bottom nav (`extendBody: true`).
class VitheyScrollBehavior extends MaterialScrollBehavior {
  const VitheyScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
