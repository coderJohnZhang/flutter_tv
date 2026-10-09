import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/model/common/poster.dart';
import 'package:flutter_tv/model/home/home_layout.dart';
import 'package:flutter_tv/model/layout/layout_column.dart';
import 'package:flutter_tv/model/layout/layout_content.dart';
import 'package:flutter_tv/model/layout/layout_home_mapper.dart';
import 'package:flutter_tv/model/layout/layout_tab.dart';
import 'package:flutter_tv/model/layout/layout_template.dart';

const LayoutHomeMapper mapper = LayoutHomeMapper();

Map<String, dynamic> _resource(int id, String title, String image, {String action = ''}) =>
    <String, dynamic>{
      'res_id': id,
      'title': <dynamic>[title],
      'url': image,
      if (action.isNotEmpty)
        'action_url': <String, dynamic>{'action': action, 'uri': 'app://$action'},
    };

Map<String, dynamic> _block(
  int id,
  int gridX,
  int gridY,
  int spanX, {
  String? title,
  String image = 'i.jpg',
  bool hidden = false,
}) =>
    <String, dynamic>{
      'block_id': id,
      'grid_xy': <dynamic>[gridX, gridY, gridX + spanX - 1, gridY],
      if (title != null)
        'resources': <dynamic>[
          <String, dynamic>{
            'res_id': id,
            'title': <dynamic>[title],
            'url': image,
            if (hidden) 'display_control': 1,
          },
        ],
    };

LayoutTab _tab(List<Map<String, dynamic>> blocks) => LayoutTab.fromJson(<String, dynamic>{
      'name': 'home',
      'block_size': <dynamic>[0.12, 0.18],
      'space': <dynamic>[0.01, 0.02],
      'title': <String, dynamic>{'value': 'For you'},
      'blocks': blocks,
    });

/// A home tab: one banner candidate spanning two cells, then two tiles beside
/// each other on the next grid row.
LayoutTab homeTab() {
  final Map<String, dynamic> template = <String, dynamic>{
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
          <String, dynamic>{'block_id': 103, 'grid_xy': <dynamic>[1, 1, 1, 1]},
        ],
      },
    ],
  };
  final Map<String, dynamic> content = <String, dynamic>{
    'template_id': 7,
    'tabs': <dynamic>[
      <String, dynamic>{
        'tab_id': 1,
        'blocks': <dynamic>[
          <String, dynamic>{
            'block_id': 101,
            'resources': <dynamic>[_resource(1, 'Hero', 'hero.jpg', action: 'open_hero')],
          },
          <String, dynamic>{
            'block_id': 102,
            'resources': <dynamic>[_resource(2, 'One', 'one.jpg', action: 'open_one')],
          },
          <String, dynamic>{
            'block_id': 103,
            'resources': <dynamic>[_resource(3, 'Two', 'two.jpg')],
          },
        ],
      },
    ],
  };
  return LayoutTemplate.fromJson(template)
      .merge(LayoutContent.fromJson(content))
      .tabs
      .first;
}

LayoutColumn column(int id, String caption, List<String> titles) => LayoutColumn.fromJson(
      <String, dynamic>{
        'column_id': id,
        'default_title': <String, dynamic>{'value': caption},
        'block_size': <dynamic>[0.1, 0.1],
        'space': <dynamic>[0.01, 0.01],
        'blocks': <dynamic>[
          for (int i = 0; i < titles.length; i++)
            <String, dynamic>{
              'block_id': id * 100 + i,
              'grid_xy': <dynamic>[i, 0, i, 0],
              'resources': <dynamic>[
                _resource(10 + i, titles[i], 'c$i.jpg', action: 'open_$id'),
              ],
            },
        ],
      },
    );

void main() {
  group('banner selection', () {
    test('promotes the widest block of the top grid row', () {
      final MappedHome home = mapper.map(tab: homeTab());
      final Poster? banner = home.layout.featured;
      expect(banner, isNotNull);
      expect(banner!.title, 'Hero');
      expect(banner.imageUrl, 'hero.jpg');
      expect(banner.blockId, 101);
    });

    test('leaves the banner empty when no top-row block spans a second cell', () {
      final LayoutTab tab = _tab(<Map<String, dynamic>>[
        _block(1, 0, 0, 1, title: 'Left', image: 'l.jpg'),
        _block(2, 1, 0, 1, title: 'Right', image: 'r.jpg'),
      ]);
      final MappedHome home = mapper.map(tab: tab);
      expect(home.layout.featured, isNull);
      expect(home.layout.rows.single.items.length, 2);
      expect(home.layout.rows.single.title, 'For you');
    });

    test('never takes a banner candidate from a lower row', () {
      final LayoutTab tab = _tab(<Map<String, dynamic>>[
        _block(1, 0, 0, 1, title: 'Top', image: 't.jpg'),
        _block(2, 0, 1, 2, title: 'Wide', image: 'w.jpg'),
      ]);
      expect(mapper.map(tab: tab).layout.featured, isNull);
    });
  });

  group('rows', () {
    final MappedHome home = mapper.map(tab: homeTab());

    test('the blocks below the banner become one row', () {
      expect(home.layout.rows.length, 1);
      final HomeRow row = home.layout.rows.single;
      expect(row.items.map((Poster p) => p.title), <String>['One', 'Two']);
      expect(row.items.first.imageUrl, 'one.jpg');
    });

    test('the tab caption heads the row that opens it', () {
      expect(home.layout.rows.single.title, 'For you');
    });

    test('takes its metrics from the tab grid', () {
      expect(home.layout.leadingInset, 119.0);
      expect(home.layout.tileWidth, closeTo(0.12 * 1920.0, 0.001));
      expect(home.layout.tileHeight, closeTo(0.18 * 1080.0, 0.001));
      expect(home.layout.gapX, closeTo(0.01 * 1920.0, 0.001));
    });

    test('falls back to default metrics when the grid omits a cell size', () {
      final LayoutTab bare = LayoutTab.fromJson(<String, dynamic>{
        'name': 'home',
        'blocks': <dynamic>[
          <String, dynamic>{
            'block_id': 1,
            'grid_xy': <dynamic>[0, 0, 0, 0],
            'resources': <dynamic>[_resource(1, 'A', 'a.jpg')],
          },
        ],
      });
      final HomeLayout layout = mapper.map(tab: bare).layout;
      expect(layout.tileWidth, 320.0);
      expect(layout.tileHeight, 180.0);
      expect(layout.gapX, 24.0);
    });
  });

  group('targets', () {
    final MappedHome home = mapper.map(
      tab: homeTab(),
      columns: <LayoutColumn>[column(11, 'Top rated', <String>['A', 'B'])],
    );

    test('remembers the target of every tile', () {
      expect(home.actionFor(101)?.action, 'open_hero');
      expect(home.actionFor(102)?.action, 'open_one');
      expect(home.actionFor(102)?.uri, 'app://open_one');
      // A tile the service gave no target stays unselectable by action.
      expect(home.actionFor(103), isNull);
    });

    test('leaves the target of a column tile reachable too', () {
      expect(home.actionFor(1100)?.action, 'open_11');
      expect(home.actions.containsKey(101), isTrue);
    });
  });

  group('columns as rows', () {
    test('each column becomes a row captioned by the column', () {
      final MappedHome home = mapper.map(
        tab: homeTab(),
        columns: <LayoutColumn>[
          column(11, 'Top rated', <String>['A', 'B']),
          column(12, 'New releases', <String>['C']),
        ],
      );
      // One tab row plus one row per column.
      expect(home.layout.rows.length, 3);
      expect(home.layout.rows[1].title, 'Top rated');
      expect(home.layout.rows[1].items.length, 2);
      expect(home.layout.rows[2].title, 'New releases');
      expect(home.layout.rows[2].items.single.title, 'C');
    });

    test('a column without drawable tiles is dropped', () {
      final MappedHome home = mapper.map(
        tab: homeTab(),
        columns: <LayoutColumn>[column(11, 'Empty', <String>[])],
      );
      expect(home.layout.rows.length, 1);
    });

    test('appending keeps the banner, the metrics and the earlier rows', () {
      final MappedHome first = mapper.map(
        tab: homeTab(),
        columns: <LayoutColumn>[column(11, 'Top rated', <String>['A'])],
      );
      final MappedHome grown = mapper.appendColumns(
        first,
        <LayoutColumn>[column(12, 'New releases', <String>['B', 'C'])],
      );

      expect(grown.layout.featured?.title, 'Hero');
      expect(grown.layout.tileWidth, first.layout.tileWidth);
      expect(grown.layout.leadingInset, first.layout.leadingInset);
      expect(grown.layout.rows.length, 3);
      expect(grown.layout.rows.last.title, 'New releases');
      // Targets from both pages survive.
      expect(grown.actionFor(101)?.action, 'open_hero');
      expect(grown.actions.length, greaterThan(first.actions.length));
    });

    test('appending nothing changes nothing', () {
      final MappedHome first = mapper.map(tab: homeTab());
      expect(
        mapper.appendColumns(first, const <LayoutColumn>[]).layout.rows.length,
        first.layout.rows.length,
      );
    });
  });

  group('undrawable resources', () {
    test('a suppressed resource leaves no tile behind', () {
      final LayoutTab tab = _tab(<Map<String, dynamic>>[
        _block(1, 0, 0, 1, title: 'Hidden', image: 'h.jpg', hidden: true),
        _block(2, 1, 0, 1, title: 'Shown', image: 's.jpg'),
      ]);
      final MappedHome home = mapper.map(tab: tab);
      expect(home.layout.rows.single.items.single.title, 'Shown');
      expect(home.actionFor(1), isNull);
    });

    test('a block with no resource at all is skipped', () {
      final LayoutTab tab = _tab(<Map<String, dynamic>>[
        _block(1, 0, 0, 1),
      ]);
      expect(mapper.map(tab: tab).layout.rows, isEmpty);
      expect(mapper.map(tab: tab).layout.featured, isNull);
    });
  });
}
