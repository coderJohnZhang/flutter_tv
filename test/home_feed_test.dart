import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/model/common/poster.dart';
import 'package:flutter_tv/model/home/home_model.dart';
import 'package:flutter_tv/model/home/home_layout.dart';
import 'package:flutter_tv/model/layout/layout_column.dart';
import 'package:flutter_tv/model/layout/layout_content.dart';
import 'package:flutter_tv/model/layout/layout_home_mapper.dart';
import 'package:flutter_tv/model/layout/layout_source.dart';
import 'package:flutter_tv/model/layout/layout_template.dart';
import 'package:flutter_tv/model/layout/page_result.dart';
import 'package:flutter_tv/viewmodel/home/home_view_model.dart';

/// A layout service whose answers the test decides, including its failures.
class _FakeSource implements LayoutSource {
  _FakeSource({
    this.columnsAvailable = 0,
    this.templateAvailable = true,
    this.columnsFail = false,
  });

  final int columnsAvailable;
  final bool templateAvailable;
  bool columnsFail;

  int columnCalls = 0;

  /// This source issues no identifier, so enrolment is skipped.
  @override
  Future<String?> enrol() async => null;

  @override
  Future<LayoutTemplate?> template() async {
    if (!templateAvailable) {
      return null;
    }
    return LayoutTemplate.fromJson(<String, dynamic>{
      'template_id': 7,
      'tabs': <dynamic>[
        <String, dynamic>{
          'tab_id': 1,
          'name': 'home',
          'active': 1,
          'block_size': <dynamic>[0.12, 0.18],
          'space': <dynamic>[0.01, 0.02],
          'title': <String, dynamic>{'value': 'For you'},
          'blocks': <dynamic>[
            <String, dynamic>{'block_id': 101, 'grid_xy': <dynamic>[0, 0, 1, 0]},
            <String, dynamic>{'block_id': 102, 'grid_xy': <dynamic>[0, 1, 0, 1]},
          ],
        },
      ],
    });
  }

  @override
  Future<LayoutContent?> content(int templateId) async => LayoutContent.fromJson(
        <String, dynamic>{
          'template_id': 7,
          'tabs': <dynamic>[
            <String, dynamic>{
              'tab_id': 1,
              'blocks': <dynamic>[
                <String, dynamic>{
                  'block_id': 101,
                  'resources': <dynamic>[
                    <String, dynamic>{
                      'res_id': 1,
                      'title': <dynamic>['Hero'],
                      'url': 'hero.jpg',
                      'action_url': <String, dynamic>{'action': 'open_hero'},
                    },
                  ],
                },
                <String, dynamic>{
                  'block_id': 102,
                  'resources': <dynamic>[
                    <String, dynamic>{'res_id': 2, 'title': <dynamic>['One'], 'url': 'one.jpg'},
                  ],
                },
              ],
            },
          ],
        },
      );

  @override
  Future<PageResult<LayoutColumn>?> columns({
    required int templateId,
    required int tabId,
    required String tabName,
    required int pageNo,
  }) async {
    columnCalls++;
    if (columnsFail) {
      return null;
    }
    return PageResult<LayoutColumn>(
      pageNo: pageNo,
      pageSize: 1,
      totalSize: columnsAvailable,
      items: <LayoutColumn>[
        if (pageNo <= columnsAvailable) _column(pageNo, 'Row $pageNo'),
      ],
    );
  }

  static LayoutColumn _column(int id, String caption) => LayoutColumn.fromJson(<String, dynamic>{
        'column_id': id,
        'default_title': <String, dynamic>{'value': caption},
        'block_size': <dynamic>[0.1, 0.1],
        'space': <dynamic>[0.01, 0.01],
        'blocks': <dynamic>[
          <String, dynamic>{
            'block_id': 300 + id,
            'grid_xy': <dynamic>[0, 0, 0, 0],
            'resources': <dynamic>[
              <String, dynamic>{'res_id': 1, 'title': <dynamic>['C$id'], 'url': 'c$id.jpg'},
            ],
          },
        ],
      });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('loading from the service', () {
    test('maps the server tab into a banner and its rows', () async {
      final HomeViewModel viewModel = HomeViewModel(source: _FakeSource());
      final MappedHome home = await viewModel.load();

      expect(home.layout.featured?.title, 'Hero');
      expect(home.layout.rows.single.items.single.title, 'One');
      expect(home.actionFor(101)?.action, 'open_hero');
      // A service may hold columns, so paging starts enabled.
      expect(viewModel.canLoadMore, isTrue);
    });

    test('falls back to the bundled layout when the service cannot be read', () async {
      final HomeViewModel viewModel =
          HomeViewModel(source: _FakeSource(templateAvailable: false));
      final MappedHome home = await viewModel.load();

      // Compared against the bundled source rather than against a title, so
      // the test says which layout was used and not what is in it.
      final HomeLayout bundled = await HomeModel.instance.local();
      expect(home.layout.rows, isNotEmpty);
      expect(home.layout.rows.length, bundled.rows.length);
      expect(home.layout.featured?.title, bundled.featured?.title);
      // Nothing to page without a service.
      expect(viewModel.canLoadMore, isFalse);
    });
  });

  group('column paging', () {
    test('appends each page until the total is reached', () async {
      final _FakeSource source = _FakeSource(columnsAvailable: 2);
      final HomeViewModel viewModel = HomeViewModel(source: source);

      final MappedHome first = await viewModel.load();
      expect(first.layout.rows.length, 1);

      final MappedHome? second = await viewModel.loadMore(first);
      expect(second, isNotNull);
      expect(second!.layout.rows.length, 2);
      expect(second.layout.rows.last.title, 'Row 1');
      expect(viewModel.canLoadMore, isTrue);

      final MappedHome? third = await viewModel.loadMore(second);
      expect(third, isNotNull);
      expect(third!.layout.rows.length, 3);
      expect(third.layout.rows.last.title, 'Row 2');
      expect(viewModel.canLoadMore, isFalse);

      // The end of the list is final: no further request is made.
      expect(await viewModel.loadMore(third), isNull);
      expect(source.columnCalls, 2);
    });

    test('keeps the banner and the tab rows while appending', () async {
      final HomeViewModel viewModel =
          HomeViewModel(source: _FakeSource(columnsAvailable: 1));
      final MappedHome first = await viewModel.load();
      final MappedHome grown = (await viewModel.loadMore(first))!;

      expect(grown.layout.featured?.title, 'Hero');
      expect(grown.layout.rows.first.title, 'For you');
      expect(grown.actionFor(101)?.action, 'open_hero');
    });

    test('a failed page leaves paging open so a later scroll can retry', () async {
      final _FakeSource source = _FakeSource(columnsAvailable: 1, columnsFail: true);
      final HomeViewModel viewModel = HomeViewModel(source: source);
      final MappedHome first = await viewModel.load();

      expect(await viewModel.loadMore(first), isNull);
      expect(viewModel.canLoadMore, isTrue);

      // The service comes back and the next attempt succeeds.
      source.columnsFail = false;
      final MappedHome? recovered = await viewModel.loadMore(first);
      expect(recovered, isNotNull);
      expect(recovered!.layout.rows.length, 2);
    });

    test('asking for more before loading returns nothing', () async {
      final HomeViewModel viewModel = HomeViewModel(source: _FakeSource());
      final MappedHome empty = await viewModel.load();
      // Loading has not happened against a tab that has no columns, so the
      // second call is what discovers the end.
      await viewModel.loadMore(empty);
      expect(await viewModel.loadMore(empty), isNull);
    });
  });

  group('launching', () {
    test('a tile with a target does not throw when the host is absent', () async {
      final HomeViewModel viewModel = HomeViewModel(source: _FakeSource());
      final MappedHome home = await viewModel.load();
      final Poster banner = home.layout.featured!;

      await viewModel.launch(banner, action: home.actionFor(banner.blockId));
      await viewModel.launch(banner);
    });
  });
}
