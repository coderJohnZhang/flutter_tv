import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/model/layout/layout_block.dart';
import 'package:flutter_tv/model/layout/layout_column.dart';
import 'package:flutter_tv/model/layout/layout_content.dart';
import 'package:flutter_tv/model/layout/layout_resource.dart';
import 'package:flutter_tv/model/layout/layout_tab.dart';
import 'package:flutter_tv/model/layout/layout_template.dart';
import 'package:flutter_tv/model/layout/page_result.dart';

/// A template whose first block spans two cells, so it is a banner candidate.
Map<String, dynamic> templateJson() => <String, dynamic>{
      'template_id': 7,
      'template_type': 2,
      'publish_time': 1600000000,
      'priority': 1,
      'waterfall_order': <dynamic>[1, 2],
      'tabs': <dynamic>[
        <String, dynamic>{
          'tab_id': 1,
          'name': 'home',
          'active': 1,
          'row': 4,
          'column': 6,
          'block_size': <dynamic>[0.12, 0.18],
          'space': <dynamic>[0.02, 0.03],
          'title': <String, dynamic>{'value': 'For you'},
          'blocks': <dynamic>[
            <String, dynamic>{
              'block_id': 101,
              'grid_xy': <dynamic>[0, 0, 1, 0],
              'around': <dynamic>[0, 0, 102, 0],
            },
            <String, dynamic>{
              'block_id': 102,
              'grid_xy': <dynamic>[0, 1, 0, 1],
              'around': <dynamic>[101, 0, 103, 0],
            },
            <String, dynamic>{
              'block_id': 103,
              'grid_xy': <dynamic>[1, 1, 1, 1],
            },
          ],
        },
        <String, dynamic>{'tab_id': 2, 'name': 'movies', 'display': 0},
      ],
    };

/// The artwork for the template above, listed in a different order on purpose.
Map<String, dynamic> contentJson() => <String, dynamic>{
      'template_id': 7,
      'tabs': <dynamic>[
        <String, dynamic>{
          'tab_id': 1,
          'blocks': <dynamic>[
            <String, dynamic>{
              'block_id': 102,
              'resources': <dynamic>[
                <String, dynamic>{'res_id': 2, 'title': <dynamic>['One'], 'url': 'one.jpg'},
              ],
            },
            <String, dynamic>{
              'block_id': 101,
              'resources': <dynamic>[
                <String, dynamic>{
                  'res_id': 1,
                  'title': <dynamic>['Hero'],
                  'name': 'Hero original',
                  'url': 'hero.jpg',
                  'action_url': <String, dynamic>{
                    'behavior': 'open',
                    'action': 'open_hero',
                    'uri': 'app://hero',
                  },
                },
              ],
            },
            <String, dynamic>{
              'block_id': 103,
              'resources': <dynamic>[
                <String, dynamic>{
                  'res_id': 3,
                  'title': <dynamic>['Two'],
                  'url': 'two.jpg',
                  'display_control': 1,
                },
              ],
            },
          ],
        },
      ],
    };

void main() {
  group('template parsing', () {
    final LayoutTemplate template = LayoutTemplate.fromJson(templateJson());

    test('reads the template envelope', () {
      expect(template.templateId, 7);
      expect(template.templateType, 2);
      expect(template.order, <int>[1, 2]);
    });

    test('derives the block span from the corner cells', () {
      final LayoutTab tab = template.tabs.first;
      // grid_xy [0,0,1,0] covers two columns and one row.
      expect(tab.blocks[0].spanX, 2);
      expect(tab.blocks[0].spanY, 1);
      // grid_xy [0,1,0,1] is a single cell.
      expect(tab.blocks[1].spanX, 1);
      expect(tab.blocks[1].spanY, 1);
      expect(tab.blocks[1].gridY, 1);
    });

    test('reads the neighbour ids in left, up, right, down order', () {
      final LayoutBlock block = template.tabs.first.blocks[1];
      expect(block.leftId, 101);
      expect(block.upId, 0);
      expect(block.rightId, 103);
      expect(block.downId, 0);
    });

    test('treats a numeric flag as a boolean', () {
      expect(template.tabs[0].active, isTrue);
      expect(template.tabs[1].display, isFalse);
      // `control` defaults to true when the payload omits it.
      expect(template.tabs.first.blocks[0].control, isTrue);
    });

    test('finds tabs by name and by the active flag', () {
      expect(template.tabNamed('movies')?.tabId, 2);
      expect(template.tabNamed('missing'), isNull);
      expect(template.defaultTab?.name, 'home');
    });

    test('orders blocks by grid position', () {
      final List<int> ids = template.tabs.first
          .orderedBlocks
          .map((LayoutBlock b) => b.blockId)
          .toList();
      expect(ids, <int>[101, 102, 103]);
    });

    test('survives a round trip through json', () {
      final LayoutTemplate again =
          LayoutTemplate.fromJson(template.toJson());
      expect(again.templateId, 7);
      expect(again.tabs.first.blocks.length, 3);
      expect(again.tabs.first.blocks[0].spanX, 2);
      expect(again.tabs.first.title.value, 'For you');
      expect(again.tabs.first.blockSize, <double>[0.12, 0.18]);
    });
  });

  group('content parsing and merging', () {
    final LayoutTemplate merged = LayoutTemplate.fromJson(templateJson())
        .merge(LayoutContent.fromJson(contentJson()));

    test('pairs resources by block id, not by position', () {
      final LayoutTab tab = merged.tabs.first;
      // The content lists block 102 first, yet 101 must keep its own artwork.
      expect(tab.blocks[0].blockId, 101);
      expect(tab.blocks[0].primary?.imageUrl, 'hero.jpg');
      expect(tab.blocks[1].blockId, 102);
      expect(tab.blocks[1].primary?.imageUrl, 'one.jpg');
    });

    test('keeps the target the service attached', () {
      final LayoutResource resource = merged.tabs.first.blocks[0].primary!;
      expect(resource.title, 'Hero');
      expect(resource.target.action, 'open_hero');
      expect(resource.target.uri, 'app://hero');
      expect(resource.isSelectable, isTrue);
    });

    test('marks a suppressed resource as not displayable', () {
      final LayoutResource resource = merged.tabs.first.blocks[2].primary!;
      expect(resource.isDisplayable, isFalse);
    });

    test('leaves a tab without content untouched', () {
      final LayoutTemplate unmerged = LayoutTemplate.fromJson(templateJson())
          .merge(LayoutContent.fromJson(<String, dynamic>{'tabs': <dynamic>[]}));
      expect(unmerged.tabs.first.blocks[0].primary, isNull);
      expect(unmerged.tabs.first.blocks.length, 3);
    });
  });

  group('tolerant parsing', () {
    test('accepts numeric strings for the grid metrics', () {
      final LayoutTab tab = LayoutTab.fromJson(<String, dynamic>{
        'block_size': <dynamic>['0.1', '0.2'],
        'space': <dynamic>['0.01', '0.02'],
        'blocks': <dynamic>[
          <String, dynamic>{'block_id': '5', 'grid_xy': <dynamic>['0', '1', '1', '1']},
        ],
      });
      expect(tab.blockSize, <double>[0.1, 0.2]);
      expect(tab.metrics.blockWidth, closeTo(0.1 * 1920.0, 0.001));
      expect(tab.blocks.single.blockId, 5);
      expect(tab.blocks.single.gridY, 1);
      expect(tab.blocks.single.spanX, 2);
    });

    test('accepts either spelling of the title visibility flag', () {
      expect(
        LayoutTab.fromJson(<String, dynamic>{'title': <String, dynamic>{'value': 'A', 'title_visiable': 0}})
            .title
            .isEmpty,
        isTrue,
      );
      expect(
        LayoutTab.fromJson(<String, dynamic>{'title': <String, dynamic>{'value': 'A', 'title_visible': 1}})
            .title
            .isEmpty,
        isFalse,
      );
    });

    test('reads a column whether or not the service reports a title', () {
      final LayoutColumn column = LayoutColumn.fromJson(<String, dynamic>{
        'column_id': 11,
        'default_title': <String, dynamic>{'value': 'Top rated'},
        'lastest_time': '1600',
      });
      expect(column.columnId, 11);
      expect(column.caption.value, 'Top rated');
      expect(column.latestTime, 1600);
    });
  });

  group('page result', () {
    test('reports more pages while the total is not reached', () {
      final PageResult<LayoutColumn> first = PageResult.fromJson(
        <String, dynamic>{
          'total_size': 3,
          'columns': <dynamic>[
            <String, dynamic>{'column_id': 1},
          ],
        },
        itemsKey: 'columns',
        item: LayoutColumn.fromJson,
        pageNo: 1,
        pageSize: 1,
      );
      expect(first.items.length, 1);
      expect(first.totalSize, 3);
      expect(first.hasMore, isTrue);
      expect(first.nextPageNo, 2);
    });

    test('stops once the last page has arrived', () {
      final PageResult<LayoutColumn> last = PageResult.fromJson(
        <String, dynamic>{
          'total_size': 3,
          'columns': <dynamic>[
            <String, dynamic>{'column_id': 3},
          ],
        },
        itemsKey: 'columns',
        item: LayoutColumn.fromJson,
        pageNo: 3,
        pageSize: 1,
      );
      expect(last.hasMore, isFalse);
    });

    test('an empty page ends the list', () {
      final PageResult<LayoutColumn> none =
          PageResult.empty<LayoutColumn>(pageNo: 4, pageSize: 1);
      expect(none.isEmpty, isTrue);
      expect(none.hasMore, isFalse);
    });

    test('falls back to the page size when no total is given', () {
      PageResult<LayoutColumn> page(int count, int pageNo) => PageResult.fromJson(
            <String, dynamic>{
              'columns': <dynamic>[
                for (int i = 0; i < count; i++) <String, dynamic>{'column_id': i},
              ],
            },
            itemsKey: 'columns',
            item: LayoutColumn.fromJson,
            pageNo: pageNo,
            pageSize: 2,
          );
      expect(page(2, 1).hasMore, isTrue);
      expect(page(1, 2).hasMore, isFalse);
    });
  });
}
