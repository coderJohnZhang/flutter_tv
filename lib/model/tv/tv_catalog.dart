import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../util/constant.dart';
import '../../util/json_value.dart';
import '../common/poster.dart';
import '../layout/layout_action.dart';

/// One channel, and what selecting it asks the platform to do.
class TvChannel {
  const TvChannel({required this.poster, required this.action});

  final Poster poster;

  /// Kept verbatim and handed to the host, so the launcher carries no table of
  /// channel names or tuner commands.
  final LayoutAction action;
}

/// The channels the TV tab offers, and the input they belong to.
///
/// A television tab is the tuner: what the set is showing, and what it could
/// switch to. A tuner offers a flat list rather than the rows a browsing tab
/// uses, so this catalog is a list and not a set of rows.
class TvCatalog {
  const TvCatalog({
    this.input = '',
    this.heading = '',
    this.heroImage = '',
    this.channels = const <TvChannel>[],
  });

  factory TvCatalog.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> raw = Json.maps(json['channels']);
    return TvCatalog(
      input: Json.text(json['input']),
      heading: Json.text(json['heading']),
      heroImage: Json.text(json['heroImage']),
      channels: <TvChannel>[
        for (int i = 0; i < raw.length; i++)
          TvChannel(
            poster: Poster(
              blockId: Json.integer(raw[i]['id'], i),
              title: Json.text(raw[i]['title']),
              subtitle: Json.text(raw[i]['subtitle']),
              imageUrl: Json.text(raw[i]['image']),
            ),
            action: Json.map(raw[i]['action']).isEmpty
                ? const LayoutAction()
                : LayoutAction.fromJson(Json.map(raw[i]['action'])),
          ),
      ],
    );
  }

  /// The catalog bundled with the app.
  static Future<TvCatalog> bundled() async {
    try {
      final String raw = await rootBundle.loadString(kLocalTvConfig);
      return TvCatalog.fromJson(json.decode(raw) as Map<String, dynamic>);
    } on Object {
      // A missing or malformed catalog leaves the tab empty rather than
      // failing to start.
      return const TvCatalog();
    }
  }

  /// The input the channel list belongs to, named as the platform names it.
  final String input;

  /// Caption above the channel list.
  final String heading;

  /// Backdrop for the input, shown while the platform names no channel.
  ///
  /// A tuner reports a channel by name rather than by picture, so the tab needs
  /// one image of its own. Once a channel is named, that channel's own tile
  /// holds the art instead.
  final String heroImage;

  final List<TvChannel> channels;

  /// The tiles to draw, in list order.
  List<Poster> get posters =>
      <Poster>[for (final TvChannel channel in channels) channel.poster];

  /// What the channel drawn as [blockId] asks for, or an empty action.
  LayoutAction actionFor(int blockId) {
    for (final TvChannel channel in channels) {
      if (channel.poster.blockId == blockId) {
        return channel.action;
      }
    }
    return const LayoutAction();
  }

  bool get isEmpty => channels.isEmpty;
}
