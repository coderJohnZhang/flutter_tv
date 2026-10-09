import 'dart:ui' show Rect;

import '../../util/grid_metrics.dart';
import '../../util/json_value.dart';
import 'layout_resource.dart';

/// One cell group on a tab's grid.
///
/// `grid_xy` holds the top-left and the bottom-right cell, so a block spans
/// whole cells and [spanX] / [spanY] are derived rather than stored.
///
/// [around] names the neighbour in each direction. It is parsed so that a
/// service's adjacency data is not thrown away, but nothing consumes it:
/// movement is decided geometrically by `SpatialFocusEngine`, which needs no
/// such table and therefore also works for a block a service never described.
class LayoutBlock {
  const LayoutBlock({
    this.blockId = 0,
    this.gridX = 0,
    this.gridY = 0,
    this.spanX = 1,
    this.spanY = 1,
    this.around = const <int>[0, 0, 0, 0],
    this.displayType = 0,
    this.control = true,
    this.latestTime = 0,
    this.layoutSignature = '',
    this.resources = const <LayoutResource>[],
  });

  factory LayoutBlock.fromJson(Map<String, dynamic> json) {
    final List<int> grid = Json.integers(json['grid_xy']);
    final int x0 = grid.isNotEmpty ? grid[0] : 0;
    final int y0 = grid.length > 1 ? grid[1] : 0;
    final int x1 = grid.length > 2 ? grid[2] : x0;
    final int y1 = grid.length > 3 ? grid[3] : y0;

    return LayoutBlock(
      blockId: Json.integer(json['block_id']),
      gridX: x0,
      gridY: y0,
      spanX: x1 - x0 + 1,
      spanY: y1 - y0 + 1,
      around: Json.integers(json['around']),
      displayType: Json.integer(json['display_type']),
      control: Json.flag(json['control'], true),
      latestTime: Json.integer(json['latest_time']),
      layoutSignature: Json.text(json['layout_signature']),
      resources: Json
          .maps(json['resources'])
          .map<LayoutResource>(LayoutResource.fromJson)
          .toList(growable: false),
    );
  }

  final int blockId;

  /// Top-left cell of the block.
  final int gridX;
  final int gridY;

  /// How many cells the block covers.
  final int spanX;
  final int spanY;

  /// Neighbour ids in the order left, up, right, down. Zero means no neighbour.
  final List<int> around;

  final int displayType;

  /// Server-side suppression: false makes the block non-selectable.
  final bool control;

  final int latestTime;
  final String layoutSignature;

  final List<LayoutResource> resources;

  int get leftId => _neighbour(0);
  int get upId => _neighbour(1);
  int get rightId => _neighbour(2);
  int get downId => _neighbour(3);

  /// The resource the tile draws.
  LayoutResource? get primary => resources.isEmpty ? null : resources.first;

  /// The cell the block spans, in design units.
  Rect rectWith(GridMetrics metrics) => metrics.rect(
        gridX: gridX,
        gridY: gridY,
        spanX: spanX,
        spanY: spanY,
      );

  /// Returns the same block carrying [incoming] resources.
  ///
  /// A layout and its content arrive as two payloads: one describes the grid,
  /// the other the artwork on it. Pairing them produces a new block rather than
  /// mutating either payload.
  LayoutBlock withResources(List<LayoutResource> incoming) => LayoutBlock(
        blockId: blockId,
        gridX: gridX,
        gridY: gridY,
        spanX: spanX,
        spanY: spanY,
        around: around,
        displayType: displayType,
        control: control,
        latestTime: latestTime,
        layoutSignature: layoutSignature,
        resources: incoming,
      );

  int _neighbour(int index) => index < around.length ? around[index] : 0;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'block_id': blockId,
        'grid_xy': <int>[gridX, gridY, gridX + spanX - 1, gridY + spanY - 1],
        'around': around,
        'display_type': displayType,
        'control': control,
        'latest_time': latestTime,
        'layout_signature': layoutSignature,
        'resources':
            resources.map((LayoutResource r) => r.toJson()).toList(growable: false),
      };
}
