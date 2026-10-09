import 'package:flutter/material.dart';

import '../../util/app_theme.dart';
import '../../util/focus_style.dart';
import '../focus/focus_block.dart';

/// A focusable tile inside a tab page.
///
/// It only reports its bounds, toggles its own highlight and reports activation.
/// Which block gets the focus next is decided by the shell's focus engine.
class FocusBlockWidget extends StatefulWidget {
  const FocusBlockWidget({
    super.key,
    required this.child,
    required this.highlightStyle,
    this.onSelect,
  });

  final Widget child;

  /// Kept in sync with the shell so a page never mixes highlight modes.
  final FocusHighlightStyle highlightStyle;

  final VoidCallback? onSelect;

  @override
  State<FocusBlockWidget> createState() => FocusBlockWidgetState();
}

class FocusBlockWidgetState extends State<FocusBlockWidget>
    implements FocusBlock {
  bool _focused = false;
  Rect _rect = Rect.zero;

  @override
  bool get focused => _focused;

  @override
  Rect get rect => _rect;

  /// The overlay style draws its own box, so the block stays untouched.
  bool get _paintsBorder =>
      widget.highlightStyle != FocusHighlightStyle.overlay;

  @override
  void setFocus(bool focused) {
    if (!mounted || _focused == focused) {
      return;
    }
    setState(() => _focused = focused);
  }

  @override
  void calculateRenderRect() {
    final RenderObject? object = context.findRenderObject();
    if (object is RenderBox && object.hasSize) {
      _rect = object.localToGlobal(Offset.zero) & object.size;
    }
  }

  @override
  void select() => widget.onSelect?.call();

  @override
  Widget build(BuildContext context) {
    // Drawn in the foreground so the border sits on top of the poster art.
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: _paintsBorder && _focused
          ? BoxDecoration(
              border: Border.all(width: kFocusBorderWidth, color: kFocusColor),
              borderRadius: const BorderRadius.all(
                Radius.circular(kFocusBorderRadius),
              ),
            )
          : const BoxDecoration(),
      child: widget.child,
    );
  }
}
