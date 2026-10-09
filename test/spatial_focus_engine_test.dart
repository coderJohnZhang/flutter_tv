import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/util/nav_key.dart';
import 'package:flutter_tv/view/focus/focus_block.dart';
import 'package:flutter_tv/view/focus/spatial_focus_engine.dart';

/// Fixed rectangles stand in for real blocks so the geometry can be verified
/// without building any widgets.
class _FakeBlock implements FocusBlock {
  _FakeBlock(this.rect);

  @override
  Rect rect;

  bool _focused = false;

  @override
  bool get focused => _focused;

  @override
  BuildContext get context =>
      throw UnsupportedError('not used by the engine');

  @override
  void setFocus(bool focused) => _focused = focused;

  @override
  void calculateRenderRect() {}

  @override
  void select() {}
}

void main() {
  const double tile = 100.0;
  const double step = 110.0;

  _FakeBlock at(int col, int row) =>
      _FakeBlock(Rect.fromLTWH(col * step, row * step, tile, tile));

  // 3x3 evenly spaced grid.
  final _FakeBlock topLeft = at(0, 0);
  final _FakeBlock topMiddle = at(1, 0);
  final _FakeBlock topRight = at(2, 0);
  final _FakeBlock middleLeft = at(0, 1);
  final _FakeBlock middle = at(1, 1);
  final _FakeBlock middleRight = at(2, 1);
  final _FakeBlock bottomLeft = at(0, 2);
  final _FakeBlock bottomMiddle = at(1, 2);
  final _FakeBlock bottomRight = at(2, 2);

  final List<FocusBlock> grid = <FocusBlock>[
    topLeft,
    topMiddle,
    topRight,
    middleLeft,
    middle,
    middleRight,
    bottomLeft,
    bottomMiddle,
    bottomRight,
  ];

  group('direction search', () {
    test('picks the adjacent block on each side', () {
      expect(SpatialFocusEngine.resolve(middle, grid, NavKey.right),
          same(middleRight));
      expect(SpatialFocusEngine.resolve(middle, grid, NavKey.left),
          same(middleLeft));
      expect(SpatialFocusEngine.resolve(middle, grid, NavKey.up),
          same(topMiddle));
      expect(SpatialFocusEngine.resolve(middle, grid, NavKey.down),
          same(bottomMiddle));
    });

    test('returns null at the edge so the caller can handle the boundary', () {
      expect(SpatialFocusEngine.resolve(topLeft, grid, NavKey.up), isNull);
      expect(SpatialFocusEngine.resolve(topLeft, grid, NavKey.left), isNull);
      expect(SpatialFocusEngine.resolve(bottomRight, grid, NavKey.down), isNull);
      expect(
          SpatialFocusEngine.resolve(bottomRight, grid, NavKey.right), isNull);
    });

    test('does not treat a block behind the focus as a candidate', () {
      expect(
        SpatialFocusEngine.isInDirection(
            middle.rect, bottomLeft.rect, NavKey.down),
        isTrue,
      );
      expect(
        SpatialFocusEngine.isInDirection(middle.rect, topLeft.rect, NavKey.down),
        isFalse,
      );
    });
  });

  group('nearest selection', () {
    test('prefers the closer of two candidates', () {
      final _FakeBlock near = at(1, 3);
      final _FakeBlock far = at(1, 6);
      expect(
        SpatialFocusEngine.resolve(middle, <FocusBlock>[far, near], NavKey.down),
        same(near),
      );
    });

    test('measures between the facing edges', () {
      // Bottom centre (50,100) to top centre (50,150) => 50 squared.
      expect(
        SpatialFocusEngine.distanceSquared(
          const Rect.fromLTWH(0, 0, 100, 100),
          const Rect.fromLTWH(0, 150, 100, 100),
          NavKey.down,
        ),
        2500.0,
      );
    });
  });

  group('row and column containment', () {
    // A tile in row 0 that sits diagonally up and to the right of the focused
    // tile in row 1, closer than the next tile along the same row.
    final _FakeBlock currentRowTile =
        _FakeBlock(const Rect.fromLTWH(0, 260, 320, 180));
    final _FakeBlock diagonalTile =
        _FakeBlock(const Rect.fromLTWH(340, 0, 320, 180));
    final _FakeBlock nextTileInRow =
        _FakeBlock(const Rect.fromLTWH(700, 260, 320, 180));

    test('sideways movement stays in the current row', () {
      expect(
        SpatialFocusEngine.resolve(
          currentRowTile,
          <FocusBlock>[diagonalTile, nextTileInRow],
          NavKey.right,
        ),
        same(nextTileInRow),
      );
    });

    test('a nearer diagonal block is still reachable when nothing overlaps', () {
      // With the same-row tile absent the diagonal block becomes the only
      // option, so containment must not strand the focus.
      expect(
        SpatialFocusEngine.resolve(
          currentRowTile,
          <FocusBlock>[diagonalTile],
          NavKey.right,
        ),
        same(diagonalTile),
      );
    });

    test('vertical movement prefers the overlapping column', () {
      // Straight below versus diagonally below, with the diagonal one nearer.
      final _FakeBlock straightBelow =
          _FakeBlock(const Rect.fromLTWH(0, 1000, 320, 180));
      final _FakeBlock diagonalBelow =
          _FakeBlock(const Rect.fromLTWH(340, 500, 320, 180));
      expect(
        SpatialFocusEngine.resolve(
          currentRowTile,
          <FocusBlock>[diagonalBelow, straightBelow],
          NavKey.down,
        ),
        same(straightBelow),
      );
    });
  });

  group('content entry points', () {
    test('first block is the leftmost of the top row', () {
      expect(SpatialFocusEngine.firstBlock(grid), same(topLeft));
    });

    test('last block is the rightmost of the top row', () {
      expect(SpatialFocusEngine.lastBlock(grid), same(topRight));
    });

    test('empty input yields null', () {
      expect(SpatialFocusEngine.firstBlock(<FocusBlock>[]), isNull);
      expect(SpatialFocusEngine.lastBlock(<FocusBlock>[]), isNull);
    });
  });
}
