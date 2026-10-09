import '../../util/grid_metrics.dart';
import '../common/poster.dart';
import '../home/home_layout.dart';
import 'layout_action.dart';
import 'layout_block.dart';
import 'layout_column.dart';
import 'layout_resource.dart';
import 'layout_tab.dart';

/// A home layout ready to draw, together with the target behind every tile.
///
/// The grid payload says nothing about rows and banners, which is what the home
/// page draws, so the mapping loses the original structure. Keeping the targets
/// alongside the posters restores what the mapping would otherwise drop: a tile
/// is still selectable by its own action rather than by its caption.
class MappedHome {
  const MappedHome({
    required this.layout,
    this.actions = const <int, LayoutAction>{},
  });

  final HomeLayout layout;

  /// Selectable target per block id. Blocks without one are absent.
  final Map<int, LayoutAction> actions;

  LayoutAction? actionFor(int blockId) => actions[blockId];
}

/// Projects a grid layout onto the rows and banner the home page draws.
///
/// The two shapes are not the same: a service describes a tab as a grid of
/// blocks, while the home page draws a banner over horizontal rows. Rather than
/// teach the widgets about grids, this mapper is the single place that decides
/// which block becomes the banner and in what order the rest become rows.
class LayoutHomeMapper {
  const LayoutHomeMapper({
    this.bannerSpan = 2,
    this.headingHeight = 56.0,
    this.rowGap = 24.0,
    this.tileWidthFallback = 320.0,
    this.tileHeightFallback = 180.0,
    this.gapFallback = 24.0,
  });

  /// How many cells a top-row block must span to be promoted to the banner.
  final int bannerSpan;

  final double headingHeight;
  final double rowGap;

  /// Tile metrics used when the payload omits `block_size`.
  final double tileWidthFallback;
  final double tileHeightFallback;
  final double gapFallback;

  /// Maps a tab, plus whatever columns have been fetched for it.
  MappedHome map({
    required LayoutTab tab,
    List<LayoutColumn> columns = const <LayoutColumn>[],
  }) {
    final Map<int, LayoutAction> actions = <int, LayoutAction>{};
    final LayoutBlock? bannerBlock = _bannerBlock(tab);
    if (bannerBlock != null) {
      _record(bannerBlock, actions);
    }

    final List<HomeRow> rows = _tabRows(tab, bannerBlock, actions);
    final MappedHome columnRows = rowsOf(columns);

    final GridMetrics metrics = tab.metrics;
    return MappedHome(
      layout: HomeLayout(
        featured: bannerBlock == null ? null : _poster(bannerBlock),
        rows: <HomeRow>[...rows, ...columnRows.layout.rows],
        leadingInset: metrics.leadingInset,
        tileWidth: _size(metrics.width(1), tileWidthFallback),
        tileHeight: _size(metrics.height(1), tileHeightFallback),
        gapX: _size(metrics.spaceX, gapFallback),
        headingHeight: headingHeight,
        rowGap: rowGap,
      ),
      actions: <int, LayoutAction>{...actions, ...columnRows.actions},
    );
  }

  /// Turns each column into one row, captioned by the column itself.
  MappedHome rowsOf(List<LayoutColumn> columns) {
    final Map<int, LayoutAction> actions = <int, LayoutAction>{};
    final List<HomeRow> rows = <HomeRow>[];
    for (final LayoutColumn column in columns) {
      final List<Poster> items = <Poster>[];
      for (final LayoutBlock block in column.blocks) {
        final Poster? poster = _record(block, actions);
        if (poster != null) {
          items.add(poster);
        }
      }
      if (items.isEmpty) {
        continue;
      }
      rows.add(HomeRow(title: column.caption.value, items: items));
    }
    return MappedHome(
      layout: HomeLayout(featured: null, rows: rows),
      actions: actions,
    );
  }

  /// Appends further columns to an already mapped home, as a later page.
  ///
  /// The banner and the metrics belong to the tab, so they carry over from
  /// [base] unchanged; only rows and targets are added.
  MappedHome appendColumns(MappedHome base, List<LayoutColumn> columns) {
    if (columns.isEmpty) {
      return base;
    }
    final MappedHome more = rowsOf(columns);
    return MappedHome(
      layout: HomeLayout(
        featured: base.layout.featured,
        rows: <HomeRow>[...base.layout.rows, ...more.layout.rows],
        leadingInset: base.layout.leadingInset,
        tileWidth: base.layout.tileWidth,
        tileHeight: base.layout.tileHeight,
        gapX: base.layout.gapX,
        headingHeight: base.layout.headingHeight,
        rowGap: base.layout.rowGap,
      ),
      actions: <int, LayoutAction>{...base.actions, ...more.actions},
    );
  }

  /// The block a tab promotes to its banner, if any.
  ///
  /// Only the topmost grid row can hold the banner, because the banner sits
  /// above every other row. Within it the widest block wins, which is how a
  /// service marks a hero tile without a dedicated field.
  LayoutBlock? _bannerBlock(LayoutTab tab) {
    final List<int> gridRows = tab.gridRows;
    if (gridRows.isEmpty) {
      return null;
    }
    final int top = gridRows.first;
    LayoutBlock? best;
    for (final LayoutBlock block in tab.blocks) {
      if (block.gridY != top || block.spanX < bannerSpan) {
        continue;
      }
      if (best == null || _area(block) > _area(best)) {
        best = block;
      }
    }
    return best;
  }

  List<HomeRow> _tabRows(
    LayoutTab tab,
    LayoutBlock? banner,
    Map<int, LayoutAction> actions,
  ) {
    final Map<int, List<LayoutBlock>> byRow = <int, List<LayoutBlock>>{};
    for (final LayoutBlock block in tab.orderedBlocks) {
      if (identical(block, banner) || block.blockId == banner?.blockId) {
        continue;
      }
      byRow.putIfAbsent(block.gridY, () => <LayoutBlock>[]).add(block);
    }

    final List<int> gridRows = byRow.keys.toList()..sort();
    final List<HomeRow> rows = <HomeRow>[];
    for (int i = 0; i < gridRows.length; i++) {
      final List<Poster> items = <Poster>[];
      for (final LayoutBlock block in byRow[gridRows[i]]!) {
        final Poster? poster = _record(block, actions);
        if (poster != null) {
          items.add(poster);
        }
      }
      if (items.isEmpty) {
        continue;
      }
      rows.add(HomeRow(
        // The tab has one caption, so only the row that opens it is headed.
        title: rows.isEmpty ? tab.title.value : '',
        items: items,
      ));
    }
    return rows;
  }

  static int _area(LayoutBlock block) => block.spanX * block.spanY;

  /// The tile a block draws, or null when nothing should be drawn.
  static Poster? _poster(LayoutBlock block) {
    final LayoutResource? resource = block.primary;
    if (resource == null || !resource.isDisplayable) {
      return null;
    }
    return Poster(
      blockId: block.blockId,
      title: resource.title,
      subtitle: resource.name == resource.title ? '' : resource.name,
      imageUrl: resource.imageUrl,
    );
  }

  /// Records the block's target and hands back its tile.
  static Poster? _record(LayoutBlock block, Map<int, LayoutAction> actions) {
    final LayoutAction? target = block.primary?.target;
    if (target != null && !target.isEmpty) {
      actions[block.blockId] = target;
    }
    return _poster(block);
  }

  static double _size(double value, double fallback) =>
      value > 1.0 ? value : fallback;
}
