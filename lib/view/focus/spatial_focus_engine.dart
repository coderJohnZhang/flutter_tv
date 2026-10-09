import 'package:flutter/widgets.dart';

import '../../util/nav_key.dart';
import 'focus_block.dart';

/// Picks the next block for a directional key press.
///
/// A remote user expects geometric movement, not build order: the target is the
/// nearest block that lies in the pressed direction. Pure geometry, no widget
/// state, so it is unit-testable with plain rectangles.
abstract final class SpatialFocusEngine {
  /// Nearest block to [current] in the [key] direction, or null at the edge.
  ///
  /// Blocks that also overlap [current] perpendicular to the direction are
  /// preferred. On a TV that is what keeps left/right inside the row the viewer
  /// is already on, and up/down inside the same column, instead of jumping to a
  /// block diagonally across the grid. When nothing overlaps, the plain nearest
  /// candidate is used so the focus can still leave a row.
  static FocusBlock? resolve(
    FocusBlock current,
    List<FocusBlock> blocks,
    NavKey key,
  ) {
    final List<FocusBlock> candidates =
        candidatesInDirection(current, blocks, key);
    if (candidates.isEmpty) {
      return null;
    }
    final List<FocusBlock> aligned = candidates
        .where((FocusBlock block) =>
            _overlapsPerpendicular(current.rect, block.rect, key))
        .toList(growable: false);
    return nearest(current, aligned.isEmpty ? candidates : aligned, key);
  }

  /// Blocks lying strictly in the [key] direction from [current].
  static List<FocusBlock> candidatesInDirection(
    FocusBlock current,
    List<FocusBlock> blocks,
    NavKey key,
  ) {
    final Rect currentRect = current.rect;
    return blocks
        .where((FocusBlock block) =>
            !identical(block, current) &&
            isInDirection(currentRect, block.rect, key))
        .toList(growable: false);
  }

  /// Whether [target] lies entirely beyond [current] in the [key] direction.
  static bool isInDirection(Rect current, Rect target, NavKey key) {
    return switch (key) {
      NavKey.up => target.bottomCenter.dy < current.topCenter.dy,
      NavKey.down => target.topCenter.dy > current.bottomCenter.dy,
      NavKey.left => target.centerRight.dx < current.centerLeft.dx,
      NavKey.right => target.centerLeft.dx > current.centerRight.dx,
      NavKey.select || NavKey.back => false,
    };
  }

  /// Whether [target] shares a band with [current] across the [key] axis.
  static bool _overlapsPerpendicular(Rect current, Rect target, NavKey key) {
    switch (key) {
      // Moving sideways: the rows must overlap vertically.
      case NavKey.left:
      case NavKey.right:
        return current.top < target.bottom && target.top < current.bottom;
      // Moving up or down: the columns must overlap horizontally.
      case NavKey.up:
      case NavKey.down:
        return current.left < target.right && target.left < current.right;
      case NavKey.select:
      case NavKey.back:
        return false;
    }
  }

  /// Candidate whose facing edge midpoint is closest to [current]'s.
  static FocusBlock? nearest(
    FocusBlock current,
    List<FocusBlock> candidates,
    NavKey key,
  ) {
    FocusBlock? best;
    double bestDistance = double.infinity;
    for (final FocusBlock block in candidates) {
      final double distance = distanceSquared(current.rect, block.rect, key);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = block;
      }
    }
    return best;
  }

  /// Squared distance between the facing edges' midpoints.
  ///
  /// Squared because the value is only compared, never used as a length.
  static double distanceSquared(Rect source, Rect target, NavKey key) {
    final (Offset, Offset)? span = switch (key) {
      NavKey.up => (source.topCenter, target.bottomCenter),
      NavKey.down => (source.bottomCenter, target.topCenter),
      NavKey.left => (source.centerLeft, target.centerRight),
      NavKey.right => (source.centerRight, target.centerLeft),
      NavKey.select || NavKey.back => null,
    };
    if (span == null) {
      return double.infinity;
    }
    final double dx = span.$1.dx - span.$2.dx;
    final double dy = span.$1.dy - span.$2.dy;
    return dx * dx + dy * dy;
  }

  /// Entry point when the focus drops into the content: top row, then leftmost.
  static FocusBlock? firstBlock(List<FocusBlock> blocks) =>
      _topRowEdge(blocks, leftmost: true);

  /// Entry point when arriving from the right: top row, then rightmost.
  static FocusBlock? lastBlock(List<FocusBlock> blocks) =>
      _topRowEdge(blocks, leftmost: false);

  static FocusBlock? _topRowEdge(
    List<FocusBlock> blocks, {
    required bool leftmost,
  }) {
    if (blocks.isEmpty) {
      return null;
    }
    double topMost = double.infinity;
    for (final FocusBlock block in blocks) {
      topMost = topMost < block.rect.top ? topMost : block.rect.top;
    }

    FocusBlock? best;
    double bestEdge = leftmost ? double.infinity : double.negativeInfinity;
    for (final FocusBlock block in blocks) {
      final Rect rect = block.rect;
      if (rect.top != topMost) {
        continue;
      }
      final double edge = leftmost ? rect.left : rect.right;
      if (leftmost ? edge < bestEdge : edge > bestEdge) {
        bestEdge = edge;
        best = block;
      }
    }
    return best;
  }
}
