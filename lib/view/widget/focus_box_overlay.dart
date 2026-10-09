import 'package:flutter/material.dart';

import '../../util/app_theme.dart';
import '../../util/constant.dart';

/// Drives the glide of the shared focus box.
class FocusBoxController extends ChangeNotifier {
  Rect? _target;
  bool _visible = false;
  bool _snapping = false;

  Rect? get target => _target;

  bool get visible => _visible;

  /// True while the box is tracking a block that is moving on its own, so it
  /// is placed rather than animated.
  bool get snapping => _snapping;

  /// Glides the box to [rect].
  void moveTo(Rect rect) {
    _target = rect;
    _visible = true;
    _snapping = false;
    notifyListeners();
  }

  /// Puts the box on [rect] without animating.
  ///
  /// A page being scrolled already carries the block along, so animating the
  /// box towards it as well would leave the box trailing the thing it outlines.
  void snapTo(Rect rect) {
    _target = rect;
    _visible = true;
    _snapping = true;
    notifyListeners();
  }

  void hide() {
    if (!_visible) {
      return;
    }
    _visible = false;
    _snapping = false;
    notifyListeners();
  }
}

/// Draws the focus box that slides between the blocks of the active tab.
///
/// Must be a sibling of the content inside the shell's [Stack] so its coordinate
/// space matches the blocks it tracks.
class FocusBoxOverlay extends StatelessWidget {
  const FocusBoxOverlay({super.key, required this.controller});

  final FocusBoxController controller;

  @override
  Widget build(BuildContext context) {
    // Positioned.fill is required: the inner Stack holds only positioned
    // children, so on its own it would collapse to zero size and clip the box.
    return Positioned.fill(
      child: IgnorePointer(
        child: ListenableBuilder(
          listenable: controller,
          builder: (BuildContext context, Widget? child) {
            final Rect? rect = controller.target;
            return Stack(
              children: <Widget>[
                if (controller.visible && rect != null)
                  AnimatedPositioned(
                    duration:
                        controller.snapping ? Duration.zero : kFocusAnimation,
                    curve: Curves.easeOutCubic,
                    left: rect.left,
                    top: rect.top,
                    width: rect.width,
                    height: rect.height,
                    // Drawn from the same accent and the same outline as the
                    // block own border, so the glide reads as the frame
                    // moving rather than as a second frame appearing.
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.fromBorderSide(BorderSide(
                          width: kFocusBorderWidth,
                          color: kFocusColor,
                        )),
                        borderRadius: BorderRadius.all(
                          Radius.circular(kFocusBorderRadius),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
