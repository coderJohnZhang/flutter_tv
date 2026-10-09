import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/util/grid_metrics.dart';

void main() {
  // A cell of 252x252 with a 36-unit gap: the numbers a service sends when one
  // block fills a 1920-wide canvas divided into seven columns.
  const GridMetrics metrics = GridMetrics(
    blockWidth: 252.0,
    blockHeight: 252.0,
    spaceX: 36.0,
    spaceY: 36.0,
    leadingInset: 119.0,
  );

  group('block size', () {
    test('a single cell is the cell size', () {
      expect(metrics.width(1), 252.0);
      expect(metrics.height(1), 252.0);
    });

    test('a span adds one gap between each pair of cells', () {
      expect(metrics.width(2), 252.0 * 2 + 36.0);
      expect(metrics.height(3), 252.0 * 3 + 36.0 * 2);
    });
  });

  group('block position', () {
    test('the first cell sits at the leading inset', () {
      expect(metrics.left(0), 119.0);
      expect(metrics.top(0), 0.0);
    });

    test('each further cell advances by a cell plus a gap', () {
      expect(metrics.left(1), 119.0 + 252.0 + 36.0);
      expect(metrics.left(2), 119.0 + (252.0 + 36.0) * 2);
      expect(metrics.top(2), (252.0 + 36.0) * 2);
    });

    test('a rect combines position and span', () {
      final Rect rect = metrics.rect(gridX: 1, gridY: 2, spanX: 2, spanY: 1);
      expect(rect.left, 119.0 + 288.0);
      expect(rect.top, 576.0);
      expect(rect.width, 540.0);
      expect(rect.height, 252.0);
    });
  });

  group('fractions', () {
    test('scales the unit fractions against the design canvas', () {
      final GridMetrics fromFractions = GridMetrics.fromFractions(
        blockSize: <double>[0.125, 0.25],
        space: <double>[0.01, 0.02],
      );
      expect(fromFractions.blockWidth, 0.125 * 1920.0);
      expect(fromFractions.blockHeight, 0.25 * 1080.0);
      expect(fromFractions.spaceX, 0.01 * 1920.0);
      expect(fromFractions.spaceY, 0.02 * 1080.0);
      expect(fromFractions.leadingInset, 119.0);
    });

    test('an absent metric becomes zero rather than throwing', () {
      const GridMetrics empty = GridMetrics(
        blockWidth: 0.0,
        blockHeight: 0.0,
        spaceX: 0.0,
        spaceY: 0.0,
      );
      expect(empty.width(2), 0.0);
      expect(empty.top(3), 0.0);
      expect(empty.left(1), 119.0);

      final GridMetrics partial = GridMetrics.fromFractions(
        blockSize: <double>[0.1],
        space: <double>[],
      );
      expect(partial.blockWidth, 0.1 * 1920.0);
      expect(partial.blockHeight, 0.0);
      expect(partial.spaceX, 0.0);
    });
  });
}
