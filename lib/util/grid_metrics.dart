import 'dart:ui' show Rect;

import 'constant.dart';

/// Translates grid coordinates into design-canvas pixels.
///
/// A tab places its blocks on an integer grid. `grid_xy` carries the top-left
/// cell and the bottom-right cell, so a block occupies whole cells: a block from
/// cell 0 to cell 1 spans two columns. The unit size of one cell and the gap
/// between cells arrive as fractions of the design canvas (`block_size` and
/// `space`), which keeps a layout resolution-independent.
class GridMetrics {
  const GridMetrics({
    required this.blockWidth,
    required this.blockHeight,
    required this.spaceX,
    required this.spaceY,
    this.leadingInset = kGridLeadingInset,
  });

  /// Builds metrics from the fractions a layout tab carries.
  factory GridMetrics.fromFractions({
    required List<double> blockSize,
    required List<double> space,
    double leadingInset = kGridLeadingInset,
  }) {
    return GridMetrics(
      blockWidth: (blockSize.isNotEmpty ? blockSize[0] : 0.0) * kDesignWidth,
      blockHeight: (blockSize.length > 1 ? blockSize[1] : 0.0) * kDesignHeight,
      spaceX: (space.isNotEmpty ? space[0] : 0.0) * kDesignWidth,
      spaceY: (space.length > 1 ? space[1] : 0.0) * kDesignHeight,
      leadingInset: leadingInset,
    );
  }

  /// Size of a single grid cell, in design units.
  final double blockWidth;
  final double blockHeight;

  /// Gap between two neighbouring cells, in design units.
  final double spaceX;
  final double spaceY;

  /// Left margin shared by every block of the tab.
  final double leadingInset;

  /// Width of a block spanning [spanX] cells, gaps included.
  double width(int spanX) => blockWidth * spanX + spaceX * (spanX - 1);

  /// Height of a block spanning [spanY] cells, gaps included.
  double height(int spanY) => blockHeight * spanY + spaceY * (spanY - 1);

  /// Vertical offset of grid row [gridY].
  double top(int gridY) => (blockHeight + spaceY) * gridY;

  /// Horizontal offset of grid column [gridX].
  double left(int gridX) => leadingInset + (blockWidth + spaceX) * gridX;

  /// Bounds of a block, in design units.
  Rect rect({
    required int gridX,
    required int gridY,
    required int spanX,
    required int spanY,
  }) {
    return Rect.fromLTWH(
      left(gridX),
      top(gridY),
      width(spanX),
      height(spanY),
    );
  }
}
