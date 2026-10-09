import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/model/common/poster.dart';
import 'package:flutter_tv/model/home/home_layout.dart';

void main() {
  const Map<String, dynamic> config = <String, dynamic>{
    'leadingInset': 60.0,
    'tileWidth': 320.0,
    'tileHeight': 180.0,
    'gapX': 24.0,
    'headingHeight': 56.0,
    'rowGap': 24.0,
    'featured': <String, dynamic>{
      'title': 'Northern Lights',
      'subtitle': 'Season 1',
      'image': 'images/backgrounds/main_bg.webp',
      'progress': 0.35,
    },
    'rows': <dynamic>[
      <String, dynamic>{
        'title': 'Continue watching',
        'items': <dynamic>[
          <String, dynamic>{
            'title': 'Harbour Town',
            'image': 'i0',
            'progress': 0.62,
          },
          <String, dynamic>{'title': 'Silver Lining', 'image': 'i1'},
        ],
      },
      <String, dynamic>{
        'title': 'Top rated',
        'items': <dynamic>[
          <String, dynamic>{'title': 'Golden Field', 'image': 'i2'},
        ],
      },
    ],
  };

  final HomeLayout layout = HomeLayout.fromJson(config);

  group('row layout parsing', () {
    test('reads the row headings and their tiles', () {
      expect(layout.rows.length, 2);
      expect(layout.rows[0].title, 'Continue watching');
      expect(layout.rows[0].items.length, 2);
      expect(layout.rows[1].title, 'Top rated');
      expect(layout.rows[1].items.length, 1);
    });

    test('reads the tile fields including the resume position', () {
      final Poster first = layout.rows[0].items[0];
      expect(first.title, 'Harbour Town');
      expect(first.imageUrl, 'i0');
      expect(first.progress, 0.62);
      // Tiles without a resume position report zero, which hides the bar.
      expect(layout.rows[0].items[1].progress, 0.0);
    });

    test('reads the featured banner', () {
      final Poster? featured = layout.featured;
      expect(featured, isNotNull);
      expect(featured!.title, 'Northern Lights');
      expect(featured.subtitle, 'Season 1');
      expect(featured.progress, 0.35);
    });

    test('reads the layout metrics', () {
      expect(layout.leadingInset, 60.0);
      expect(layout.tileWidth, 320.0);
      expect(layout.tileHeight, 180.0);
      expect(layout.gapX, 24.0);
      expect(layout.headingHeight, 56.0);
      expect(layout.rowGap, 24.0);
    });
  });

  group('derived metrics', () {
    test('row stride is heading plus tile plus gap', () {
      expect(layout.rowStride, 56.0 + 180.0 + 24.0);
    });

    test('content height covers the rows without a trailing gap', () {
      // Two rows: 2 * 260, minus the gap that would follow the last one.
      expect(layout.contentHeight, 2 * 260.0 - 24.0);
    });

    test('an empty layout has no height', () {
      final HomeLayout empty = HomeLayout.fromJson(<String, dynamic>{});
      expect(empty.rows, isEmpty);
      expect(empty.contentHeight, 0.0);
      expect(empty.featured, isNull);
    });
  });

  group('tolerant parsing', () {
    test('falls back to defaults when metrics are absent', () {
      final HomeLayout minimal = HomeLayout.fromJson(<String, dynamic>{
        'rows': <dynamic>[
          <String, dynamic>{'title': 'Only'},
        ],
      });
      expect(minimal.leadingInset, 60.0);
      expect(minimal.tileWidth, 320.0);
      expect(minimal.tileHeight, 180.0);
      expect(minimal.gapX, 24.0);
      expect(minimal.headingHeight, 56.0);
      expect(minimal.rowGap, 24.0);
      // A row without items still parses.
      expect(minimal.rows.single.items, isEmpty);
    });

    test('accepts numeric strings from a remote payload', () {
      final HomeLayout fromStrings = HomeLayout.fromJson(<String, dynamic>{
        'tileWidth': '400',
        'tileHeight': '200',
        'rowGap': '0',
        'headingHeight': '40',
        'rows': <dynamic>[
          <String, dynamic>{'title': 'S'},
        ],
      });
      expect(fromStrings.tileWidth, 400.0);
      expect(fromStrings.tileHeight, 200.0);
      expect(fromStrings.rowGap, 0.0);
      expect(fromStrings.rowStride, 240.0);
      expect(fromStrings.contentHeight, 240.0);
    });
  });
}
