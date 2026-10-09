import 'package:flutter/widgets.dart';

/// Contract every focusable content block satisfies.
///
/// The spatial search depends on nothing else, which keeps the focus engine
/// independent of any particular widget or tab page.
abstract class FocusBlock {
  /// Used to walk ancestors when the block must be scrolled into view.
  BuildContext get context;

  bool get focused;

  /// Bounds in global coordinates; refreshed by [calculateRenderRect].
  Rect get rect;

  void setFocus(bool focused);

  /// Re-samples [rect]. A block's position changes as the content scrolls, so
  /// this runs before every directional key press.
  void calculateRenderRect();

  /// Runs when the select key is pressed while this block is focused.
  ///
  /// Named `select` rather than `activate` because [State.activate] is a
  /// framework lifecycle callback that an implementation would otherwise
  /// accidentally override.
  void select();
}
