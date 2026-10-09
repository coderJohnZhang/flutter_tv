import 'package:flutter/material.dart';

/// Removes the overscroll glow a scrolling view draws at its edges.
///
/// A television remote has no touch gesture behind a scroll, so the glow that
/// tells a finger it has reached the end means nothing on a TV and is drawn over
/// the artwork instead. Nothing is lost by leaving it off, and a launcher that
/// keeps it looks like a phone app on a large screen.
class TvScrollBehavior extends MaterialScrollBehavior {
  const TvScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}
