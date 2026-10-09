import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../util/constant.dart';
import '../../util/json_value.dart';
import '../common/poster.dart';
import '../home/home_layout.dart';

/// The rows the video tab offers.
///
/// A video tab is a set of titled rows, which is the same shape the home tab
/// draws, so the catalog produces [HomeRow] values and the tab reuses the row
/// widget the home tab uses.
class VideoCatalog {
  const VideoCatalog(
    this.rows, {
    this.tileWidth = 320.0,
    this.tileHeight = 180.0,
  });

  factory VideoCatalog.fromJson(Map<String, dynamic> json) {
    final List<HomeRow> rows = <HomeRow>[];
    for (final Map<String, dynamic> rawRow in Json.maps(json['rows'])) {
      final List<Map<String, dynamic>> rawItems = Json.maps(rawRow['items']);
      rows.add(HomeRow(
        title: Json.text(rawRow['title']),
        items: <Poster>[
          for (int i = 0; i < rawItems.length; i++)
            Poster(
              blockId: Json.integer(rawItems[i]['id'], i),
              title: Json.text(rawItems[i]['title']),
              subtitle: Json.text(rawItems[i]['subtitle']),
              imageUrl: Json.text(rawItems[i]['image']),
              progress: Json.decimal(rawItems[i]['progress'], 0.0),
            ),
        ],
      ));
    }
    return VideoCatalog(
      rows,
      tileWidth: Json.decimal(json['tileWidth'], 320.0),
      tileHeight: Json.decimal(json['tileHeight'], 180.0),
    );
  }

  /// The catalog bundled with the app.
  static Future<VideoCatalog> bundled() async {
    try {
      final String raw = await rootBundle.loadString(kLocalVideoConfig);
      return VideoCatalog.fromJson(json.decode(raw) as Map<String, dynamic>);
    } on Object {
      // A missing or malformed catalog leaves the tab empty rather than
      // failing to start.
      return const VideoCatalog(<HomeRow>[]);
    }
  }

  final List<HomeRow> rows;

  /// Tile size in design units. A catalog of posters sets these taller than
  /// they are wide, because a poster shown in a landscape tile is cropped to
  /// a band of its artwork.
  final double tileWidth;
  final double tileHeight;

  bool get isEmpty => rows.isEmpty;
}
