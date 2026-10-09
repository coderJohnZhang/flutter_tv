import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/model/layout/layout_column.dart';
import 'package:flutter_tv/model/layout/layout_content.dart';
import 'package:flutter_tv/model/layout/layout_source.dart';
import 'package:flutter_tv/model/layout/layout_template.dart';
import 'package:flutter_tv/model/layout/page_result.dart';
import 'package:flutter_tv/util/constant.dart';

/// A transport that answers from a scripted function, so the source can be
/// exercised without a server.
class _FakeTransport implements LayoutTransport {
  _FakeTransport(this.handler);

  final Map<String, dynamic> Function(String path, Map<String, dynamic>? query) handler;

  final List<String> paths = <String>[];
  final List<Map<String, dynamic>?> queries = <Map<String, dynamic>?>[];

  @override
  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    paths.add(path);
    queries.add(query);
    return handler(path, query);
  }
}

Map<String, dynamic> _templateBody() => <String, dynamic>{
      'error_code': 1000,
      'template_id': 7,
      'tabs': <dynamic>[
        <String, dynamic>{
          'tab_id': 1,
          'name': 'home',
          'block_size': <dynamic>[0.1, 0.1],
          'space': <dynamic>[0.01, 0.01],
          'blocks': <dynamic>[
            <String, dynamic>{'block_id': 1, 'grid_xy': <dynamic>[0, 0, 0, 0]},
          ],
        },
      ],
    };

Map<String, dynamic> _columnPage(int pageNo, int total) => <String, dynamic>{
      'error_code': 1000,
      'total_size': total,
      'columns': <dynamic>[
        if (pageNo <= total)
          <String, dynamic>{
            'column_id': pageNo,
            'default_title': <String, dynamic>{'value': 'Row $pageNo'},
            'blocks': <dynamic>[
              <String, dynamic>{
                'block_id': 100 + pageNo,
                'grid_xy': <dynamic>[0, 0, 0, 0],
                'resources': <dynamic>[
                  <String, dynamic>{'res_id': 1, 'title': <dynamic>['T'], 'url': 't.jpg'},
                ],
              },
            ],
          },
      ],
    };

void main() {
  group('template and content', () {
    test('reads the template and keeps the envelope out of the way', () async {
      final _FakeTransport transport = _FakeTransport(
        (String path, Map<String, dynamic>? query) => _templateBody(),
      );
      final LayoutTemplate? template =
          await RemoteLayoutSource(transport: transport).template();

      expect(template, isNotNull);
      expect(template!.templateId, 7);
      expect(template.tabs.single.name, 'home');
      expect(transport.paths.single, '/waterfall/layout');
    });

    test('unwraps a payload nested under data', () async {
      final _FakeTransport transport = _FakeTransport(
        (String path, Map<String, dynamic>? query) => <String, dynamic>{
          'error_code': 1000,
          'data': _templateBody(),
        },
      );
      final LayoutTemplate? template =
          await RemoteLayoutSource(transport: transport).template();
      expect(template?.templateId, 7);
    });

    test('sends the requested template when asking for content', () async {
      final _FakeTransport transport = _FakeTransport(
        (String path, Map<String, dynamic>? query) => <String, dynamic>{
          'error_code': 1000,
          'template_id': 7,
          'tabs': <dynamic>[],
        },
      );
      final LayoutContent? content =
          await RemoteLayoutSource(transport: transport).content(7);

      expect(content, isNotNull);
      expect(transport.paths.single, '/waterfall/content');
      expect(transport.queries.single?['template_id'], 7);
    });

    test('reports the device context with every request', () async {
      final _FakeTransport transport = _FakeTransport(
        (String path, Map<String, dynamic>? query) => _templateBody(),
      );
      await RemoteLayoutSource(
        transport: transport,
        appVersion: kAppVersion,
        context: const <String, String>{'language': 'zh', 'client_type': 'tv'},
      ).template();

      final Map<String, dynamic>? query = transport.queries.single;
      expect(query?['language'], 'zh');
      expect(query?['client_type'], 'tv');
      expect(query?['app_version'], kAppVersion);
      expect(query?['resolution'], '1920*1080');
      expect(query?['param'], isA<int>());
    });
  });

  group('failure is reported, never thrown', () {
    test('an unreachable service reads as null', () async {
      final _FakeTransport transport = _FakeTransport(
        (String path, Map<String, dynamic>? query) => const <String, dynamic>{},
      );
      expect(await RemoteLayoutSource(transport: transport).template(), isNull);
    });

    test('a service that answers with an error code reads as null', () async {
      final _FakeTransport transport = _FakeTransport(
        (String path, Map<String, dynamic>? query) => <String, dynamic>{'error_code': 500},
      );
      expect(await RemoteLayoutSource(transport: transport).template(), isNull);
    });

    test('a failing column request reads as null, not as an empty page', () async {
      final _FakeTransport transport = _FakeTransport(
        (String path, Map<String, dynamic>? query) => const <String, dynamic>{},
      );
      final PageResult<LayoutColumn>? page =
          await RemoteLayoutSource(transport: transport).columns(
        templateId: 7,
        tabId: 1,
        tabName: 'home',
        pageNo: 1,
      );
      expect(page, isNull);
    });

    test('a service may report success with its own code', () async {
      final _FakeTransport transport = _FakeTransport(
        (String path, Map<String, dynamic>? query) => <String, dynamic>{
          'error_code': 0,
          'template_id': 9,
        },
      );
      expect(
        (await RemoteLayoutSource(transport: transport).template())?.templateId,
        9,
      );
    });
  });

  group('column paging', () {
    test('walks the pages until the total is reached', () async {
      const int total = 2;
      final _FakeTransport transport = _FakeTransport(
        (String path, Map<String, dynamic>? query) =>
            _columnPage(query?['page_no'] as int? ?? 1, total),
      );
      final RemoteLayoutSource source =
          RemoteLayoutSource(transport: transport, pageSize: 1);

      final PageResult<LayoutColumn> first = (await source.columns(
        templateId: 7,
        tabId: 1,
        tabName: 'home',
        pageNo: 1,
      ))!;
      expect(first.items.single.columnId, 1);
      expect(first.hasMore, isTrue);

      final PageResult<LayoutColumn> second = (await source.columns(
        templateId: 7,
        tabId: 1,
        tabName: 'home',
        pageNo: first.nextPageNo,
      ))!;
      expect(second.items.single.columnId, 2);
      expect(second.hasMore, isFalse);
      expect(second.nextPageNo, 3);
    });

    test('asks for the column page it was told to', () async {
      final _FakeTransport transport = _FakeTransport(
        (String path, Map<String, dynamic>? query) => _columnPage(3, 5),
      );
      await RemoteLayoutSource(transport: transport, pageSize: 20).columns(
        templateId: 7,
        tabId: 4,
        tabName: 'movies',
        pageNo: 3,
      );

      expect(transport.paths.single, '/waterfall/column');
      expect(transport.queries.single?['page_no'], 3);
      expect(transport.queries.single?['page_size'], 20);
      expect(transport.queries.single?['tab_id'], 4);
      expect(transport.queries.single?['tab_name'], 'movies');
    });
  });
}
