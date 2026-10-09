import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/model/app/app_catalog.dart';
import 'package:flutter_tv/model/video/video_catalog.dart';
import 'package:flutter_tv/util/locale_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('locale catalog', () {
    test('offers a locale for every language tag', () {
      expect(LocaleCatalog.locales.length, LocaleCatalog.languages.length);
      expect(LocaleCatalog.languages, contains('en'));
      expect(LocaleCatalog.languages, contains('ja'));
    });

    test('maps a tag that needs a script to be unambiguous', () {
      final Locale simplified = LocaleCatalog.fromTag('zh-cn');
      expect(simplified.languageCode, 'zh');
      expect(simplified.scriptCode, 'Hans');

      final Locale traditional = LocaleCatalog.fromTag('zh-tw');
      expect(traditional.languageCode, 'zh');
      expect(traditional.scriptCode, 'Hant');
    });

    test('maps a tag that needs a region', () {
      final Locale egyptian = LocaleCatalog.fromTag('ar-eg');
      expect(egyptian.languageCode, 'ar');
      expect(egyptian.countryCode, 'EG');
    });

    test('a plain tag stays plain', () {
      final Locale english = LocaleCatalog.fromTag('en');
      expect(english.languageCode, 'en');
      expect(english.scriptCode, isNull);
      expect(english.countryCode, isNull);
    });

    test('knows its own codes and nothing else', () {
      expect(LocaleCatalog.isKnown('en'), isTrue);
      expect(LocaleCatalog.isKnown('zh'), isTrue);
      expect(LocaleCatalog.isKnown('xx'), isFalse);
      // The regional tags are tags, not codes.
      expect(LocaleCatalog.isKnown('zh-cn'), isFalse);
    });
  });

  group('app catalog', () {
    final AppCatalog catalog = AppCatalog.fromJson(<String, dynamic>{
      'apps': <dynamic>[
        <String, dynamic>{
          'id': 3,
          'title': 'Store',
          'image': 'store.jpg',
          'action': <String, dynamic>{'action': 'open_store'},
        },
        <String, dynamic>{'id': 4, 'title': 'Settings', 'image': 'settings.jpg'},
      ],
    });

    test('reads every entry', () {
      expect(catalog.apps.length, 2);
      expect(catalog.apps.first.title, 'Store');
      expect(catalog.apps.first.imageUrl, 'store.jpg');
      expect(catalog.apps.first.action.action, 'open_store');
    });

    test('an entry without an action still parses', () {
      expect(catalog.apps.last.action.isEmpty, isTrue);
    });

    test('turns an entry into a tile', () {
      expect(catalog.apps.first.poster.blockId, 3);
      expect(catalog.apps.first.poster.imageUrl, 'store.jpg');
    });

    test('finds an entry by id, and reports a miss', () {
      expect(catalog.byId(4)?.title, 'Settings');
      expect(catalog.byId(99), isNull);
    });

    test('tolerates a payload with no apps', () {
      expect(AppCatalog.fromJson(<String, dynamic>{}).isEmpty, isTrue);
    });
  });

  group('video catalog', () {
    final VideoCatalog catalog = VideoCatalog.fromJson(<String, dynamic>{
      'rows': <dynamic>[
        <String, dynamic>{
          'title': 'Featured',
          'items': <dynamic>[
            <String, dynamic>{'title': 'A', 'image': 'a.jpg', 'progress': '0.5'},
            <String, dynamic>{'title': 'B', 'image': 'b.jpg'},
          ],
        },
        <String, dynamic>{'title': 'Empty'},
      ],
    });

    test('reads a row and its items', () {
      expect(catalog.rows.length, 2);
      expect(catalog.rows.first.title, 'Featured');
      expect(catalog.rows.first.items.length, 2);
      expect(catalog.rows.first.items.first.title, 'A');
    });

    test('reads a resume position that arrived as a string', () {
      expect(catalog.rows.first.items.first.progress, 0.5);
      expect(catalog.rows.first.items.last.progress, 0.0);
    });

    test('numbers items that carry no id', () {
      expect(catalog.rows.first.items.first.blockId, 0);
      expect(catalog.rows.first.items.last.blockId, 1);
    });

    test('a row without items is kept but empty', () {
      expect(catalog.rows.last.items, isEmpty);
    });

    test('tolerates a payload with no rows', () {
      expect(VideoCatalog.fromJson(<String, dynamic>{}).isEmpty, isTrue);
    });

    test('bundled video posters are slightly larger and keep portrait shape',
        () async {
      final VideoCatalog bundled = await VideoCatalog.bundled();

      expect(bundled.tileWidth, 237.0);
      expect(bundled.tileHeight, 332.0);
      expect(bundled.tileWidth / bundled.tileHeight, closeTo(398 / 557, 0.002));
    });
  });
}
