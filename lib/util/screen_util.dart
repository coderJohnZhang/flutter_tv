import 'package:flutter/widgets.dart';

import 'constant.dart';

/// Scales design-canvas measurements to the current screen.
///
/// One factor derived from the width is used for both axes so the layout keeps
/// its proportions at any TV resolution.
class ScreenUtil {
  const ScreenUtil._(this._scale, this._textScale);

  final double _scale;
  final double _textScale;

  factory ScreenUtil.of(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    return ScreenUtil._(
      media.size.width / kDesignWidth,
      media.textScaler.scale(1.0),
    );
  }

  /// Raw design-pixel to logical-pixel factor.
  double get scale => _scale;

  /// Horizontal measurement in design units.
  double w(double designPx) => designPx * _scale;

  /// Vertical measurement in design units. Shares the width factor so shapes
  /// never distort.
  double h(double designPx) => designPx * _scale;

  /// Font size in design units. The system text scale is divided out so the TV
  /// layout stays intact regardless of accessibility font settings.
  double sp(double designPx) => _textScale == 0
      ? designPx * _scale
      : designPx * _scale / _textScale;
}
