import '../../util/grid_metrics.dart';
import '../../util/json_value.dart';
import 'layout_block.dart';
import 'layout_title.dart';

/// A titled band of blocks fetched as a page.
///
/// A tab holds the blocks that are always present; content that grows without
/// bound arrives as columns, one page at a time. Each column carries its own
/// grid metrics because it does not share the tab's canvas.
class LayoutColumn {
  const LayoutColumn({
    this.columnId = 0,
    this.columnType = '',
    this.title = LayoutTitle.empty,
    this.defaultTitle = LayoutTitle.empty,
    this.rows = 0,
    this.columns = 0,
    this.space = const <double>[],
    this.blockSize = const <double>[],
    this.blocks = const <LayoutBlock>[],
    this.layoutSignature = '',
    this.latestTime = 0,
  });

  factory LayoutColumn.fromJson(Map<String, dynamic> json) {
    return LayoutColumn(
      columnId: Json.integer(json['column_id']),
      columnType: Json.text(json['column_type']),
      title: LayoutTitle.fromJson(Json.map(json['title'])),
      defaultTitle: LayoutTitle.fromJson(Json.map(json['default_title'])),
      rows: Json.integer(json['row']),
      columns: Json.integer(json['column']),
      space: Json.decimals(json['space']),
      blockSize: Json.decimals(json['block_size']),
      blocks: Json
          .maps(json['blocks'])
          .map<LayoutBlock>(LayoutBlock.fromJson)
          .toList(growable: false),
      layoutSignature: Json.text(json['layout_signature']),
      // Services differ on the spelling of this field; accept either.
      latestTime: Json.integer(json['latest_time'] ?? json['lastest_time']),
    );
  }

  final int columnId;
  final String columnType;

  final LayoutTitle title;

  /// Caption to use when no localized [title] is available.
  final LayoutTitle defaultTitle;

  final int rows;
  final int columns;
  final List<double> space;
  final List<double> blockSize;
  final List<LayoutBlock> blocks;
  final String layoutSignature;
  final int latestTime;

  /// Geometry every block of this column is measured against.
  GridMetrics get metrics =>
      GridMetrics.fromFractions(blockSize: blockSize, space: space);

  /// Caption to draw, preferring the localized one.
  LayoutTitle get caption => title.isEmpty ? defaultTitle : title;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'column_id': columnId,
        'column_type': columnType,
        'title': title.toJson(),
        'default_title': defaultTitle.toJson(),
        'row': rows,
        'column': columns,
        'space': space,
        'block_size': blockSize,
        'blocks':
            blocks.map((LayoutBlock b) => b.toJson()).toList(growable: false),
        'layout_signature': layoutSignature,
        'latest_time': latestTime,
      };
}
