import '../../util/grid_metrics.dart';
import '../../util/json_value.dart';
import 'layout_block.dart';
import 'layout_title.dart';

/// One tab of a layout template: a titled grid of blocks.
///
/// The tab owns the grid metrics ([blockSize] and [space]) that every block on
/// it is measured against, so geometry is consistent across the tab without
/// repeating it per block.
class LayoutTab {
  const LayoutTab({
    this.tabId = 0,
    this.name = '',
    this.desc = '',
    this.active = false,
    this.editable = false,
    this.display = true,
    this.movable = false,
    this.rows = 0,
    this.columns = 0,
    this.space = const <double>[],
    this.blockSize = const <double>[],
    this.title = LayoutTitle.empty,
    this.blocks = const <LayoutBlock>[],
    this.latestTime = 0,
  });

  factory LayoutTab.fromJson(Map<String, dynamic> json) {
    return LayoutTab(
      tabId: Json.integer(json['tab_id']),
      name: Json.text(json['name']),
      desc: Json.text(json['desc']),
      active: Json.flag(json['active']),
      editable: Json.flag(json['editable']),
      display: Json.flag(json['display'], true),
      movable: Json.flag(json['movable']),
      rows: Json.integer(json['row']),
      columns: Json.integer(json['column']),
      space: Json.decimals(json['space']),
      blockSize: Json.decimals(json['block_size']),
      title: LayoutTitle.fromJson(Json.map(json['title'])),
      blocks: Json
          .maps(json['blocks'])
          .map<LayoutBlock>(LayoutBlock.fromJson)
          .toList(growable: false),
      latestTime: Json.integer(json['latest_time']),
    );
  }

  final int tabId;
  final String name;
  final String desc;
  final bool active;
  final bool editable;
  final bool display;
  final bool movable;

  /// Size of the grid, in cells.
  final int rows;
  final int columns;

  /// Cell gap as a fraction of the design canvas, column first.
  final List<double> space;

  /// Cell size as a fraction of the design canvas, width first.
  final List<double> blockSize;

  final LayoutTitle title;
  final List<LayoutBlock> blocks;
  final int latestTime;

  /// Geometry every block of this tab is measured against.
  GridMetrics get metrics =>
      GridMetrics.fromFractions(blockSize: blockSize, space: space);

  /// Blocks in reading order: top row first, left to right within it.
  List<LayoutBlock> get orderedBlocks {
    final List<LayoutBlock> ordered = List<LayoutBlock>.of(blocks);
    ordered.sort((LayoutBlock a, LayoutBlock b) {
      final int byRow = a.gridY.compareTo(b.gridY);
      return byRow != 0 ? byRow : a.gridX.compareTo(b.gridX);
    });
    return ordered;
  }

  /// Distinct grid rows the blocks occupy, top first.
  List<int> get gridRows {
    final Set<int> rows = <int>{
      for (final LayoutBlock block in blocks) block.gridY,
    };
    final List<int> ordered = rows.toList()..sort();
    return ordered;
  }

  /// Returns the same tab carrying [incoming] blocks.
  LayoutTab withBlocks(List<LayoutBlock> incoming) => LayoutTab(
        tabId: tabId,
        name: name,
        desc: desc,
        active: active,
        editable: editable,
        display: display,
        movable: movable,
        rows: rows,
        columns: columns,
        space: space,
        blockSize: blockSize,
        title: title,
        blocks: incoming,
        latestTime: latestTime,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'tab_id': tabId,
        'name': name,
        'desc': desc,
        'active': active,
        'editable': editable,
        'display': display,
        'movable': movable,
        'row': rows,
        'column': columns,
        'space': space,
        'block_size': blockSize,
        'title': title.toJson(),
        'blocks':
            blocks.map((LayoutBlock b) => b.toJson()).toList(growable: false),
        'latest_time': latestTime,
      };
}
