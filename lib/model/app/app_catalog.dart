import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../util/constant.dart';
import '../../util/json_value.dart';
import '../common/poster.dart';
import '../layout/layout_action.dart';

/// One application shortcut, with the target it opens.
class AppEntry {
  const AppEntry({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.action = const LayoutAction(),
  });

  factory AppEntry.fromJson(Map<String, dynamic> json) {
    return AppEntry(
      id: Json.integer(json['id']),
      title: Json.text(json['title']),
      imageUrl: Json.text(json['image']),
      action: LayoutAction.fromJson(Json.map(json['action'])),
    );
  }

  final int id;
  final String title;
  final String imageUrl;
  final LayoutAction action;

  Poster get poster => Poster(blockId: id, title: title, imageUrl: imageUrl);
}

/// The applications the apps tab offers.
///
/// A deployment decides which applications are on the launcher, so the list
/// lives in a config rather than in the widget. It is read from an asset here
/// and can be replaced by a service payload of the same shape.
class AppCatalog {
  const AppCatalog(this.apps);

  factory AppCatalog.fromJson(Map<String, dynamic> json) {
    return AppCatalog(
      Json.maps(json['apps']).map<AppEntry>(AppEntry.fromJson).toList(growable: false),
    );
  }

  /// The catalog bundled with the app.
  static Future<AppCatalog> bundled() async {
    try {
      final String raw = await rootBundle.loadString(kLocalAppConfig);
      return AppCatalog.fromJson(json.decode(raw) as Map<String, dynamic>);
    } on Object {
      // A missing or malformed catalog leaves the tab empty rather than
      // failing to start.
      return const AppCatalog(<AppEntry>[]);
    }
  }

  final List<AppEntry> apps;

  bool get isEmpty => apps.isEmpty;

  /// The entry with [id], or null.
  AppEntry? byId(int id) {
    for (final AppEntry entry in apps) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }
}
