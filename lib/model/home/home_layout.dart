import '../../util/json_value.dart';
import '../common/poster.dart';

/// One horizontally scrolling row of tiles with a heading above it.
class HomeRow {
  const HomeRow({required this.title, required this.items});

  final String title;
  final List<Poster> items;
}

/// Home tab layout: an optional featured banner followed by content rows.
///
/// This mirrors the shape of a modern TV launcher, where the viewer moves down
/// through rows and sideways through the tiles inside a row. Only the metric
/// values are parsed here; the widgets do the actual placement.
class HomeLayout {
  const HomeLayout({
    required this.featured,
    required this.rows,
    this.leadingInset = 60.0,
    this.tileWidth = 320.0,
    this.tileHeight = 180.0,
    this.gapX = 24.0,
    this.headingHeight = 56.0,
    this.rowGap = 24.0,
  });

  /// Large banner at the top of the tab. Null when the config omits it.
  final Poster? featured;

  final List<HomeRow> rows;

  /// Left inset shared by row headings and the first tile of each row.
  final double leadingInset;

  final double tileWidth;
  final double tileHeight;
  final double gapX;

  /// Height reserved for the heading above each row.
  final double headingHeight;

  final double rowGap;

  /// Vertical distance from one row heading to the next.
  double get rowStride => headingHeight + tileHeight + rowGap;

  /// Total height of the rows area, used to size the vertical scroll view.
  double get contentHeight =>
      rows.isEmpty ? 0.0 : rows.length * rowStride - rowGap;

  factory HomeLayout.fromJson(Map<String, dynamic> json) {
    return HomeLayout(
      featured: json['featured'] == null
          ? null
          : _poster(Json.map(json['featured']), 0),
      leadingInset: Json.decimal(json['leadingInset'], 60.0),
      tileWidth: Json.decimal(json['tileWidth'], 320.0),
      tileHeight: Json.decimal(json['tileHeight'], 180.0),
      gapX: Json.decimal(json['gapX'], 24.0),
      headingHeight: Json.decimal(json['headingHeight'], 56.0),
      rowGap: Json.decimal(json['rowGap'], 24.0),
      rows: <HomeRow>[
        for (final Map<String, dynamic> rawRow in Json.maps(json['rows']))
          _row(rawRow),
      ],
    );
  }

  static HomeRow _row(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> rawItems = Json.maps(json['items']);
    return HomeRow(
      title: Json.text(json['title']),
      items: <Poster>[
        for (int i = 0; i < rawItems.length; i++) _poster(rawItems[i], i),
      ],
    );
  }

  static Poster _poster(Map<String, dynamic> json, int index) {
    return Poster(
      blockId: index,
      title: Json.text(json['title']),
      subtitle: Json.text(json['subtitle']),
      imageUrl: Json.text(json['image']),
      progress: Json.decimal(json['progress'], 0.0),
    );
  }
}
