import 'dart:convert';

import '../layout/layout_action.dart';
import '../../util/json_value.dart';

/// One thing the viewer opened, and when.
///
/// The launcher keeps this so the viewer can find their way back to what they
/// were doing, which on a television is the main way a title is resumed. The
/// entry stores the time it was opened rather than a formatted date, so the
/// grouping into today and earlier is decided when it is read, not when it is
/// written.
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.title,
    this.kind = '',
    this.imageUrl = '',
    this.openedAt,
    this.target = const LayoutAction(),
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    final int? millis = json['opened_at'] == null
        ? null
        : Json.integer(json['opened_at']);
    return HistoryEntry(
      id: Json.integer(json['id']),
      title: Json.text(json['title']),
      kind: Json.text(json['kind']),
      imageUrl: Json.text(json['image']),
      openedAt: millis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(millis),
      target: LayoutAction.fromJson(Json.map(json['target'])),
    );
  }

  /// Identifier of the entry, unique per title.
  final int id;

  final String title;

  /// What the entry is: an application or a title, as the host names it.
  final String kind;

  final String imageUrl;

  /// When the viewer opened it. Null when the host never recorded a time.
  final DateTime? openedAt;

  /// Where reopening it leads.
  final LayoutAction target;

  /// True when the entry falls on the same day as [day].
  ///
  /// An entry with no recorded time is never "today": it would otherwise drift
  /// into the first group forever.
  bool isOn(DateTime day) {
    final DateTime? when = openedAt;
    if (when == null) {
      return false;
    }
    return when.year == day.year && when.month == day.month && when.day == day.day;
  }

  bool get isApp => kind == kindApp;
  bool get isTitle => kind == kindTitle;

  /// Kinds the launcher distinguishes when grouping.
  static const String kindApp = 'app';
  static const String kindTitle = 'title';

  HistoryEntry copyWith({DateTime? openedAt}) => HistoryEntry(
        id: id,
        title: title,
        kind: kind,
        imageUrl: imageUrl,
        openedAt: openedAt ?? this.openedAt,
        target: target,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'kind': kind,
        'image': imageUrl,
        if (openedAt != null) 'opened_at': openedAt!.millisecondsSinceEpoch,
        'target': target.toJson(),
      };

  /// The entry as one line, which is the form the store keeps it in.
  String toLine() => json.encode(toJson());

  /// Reads back one line written by [toLine].
  ///
  /// A line that cannot be read is reported as nothing rather than thrown: the
  /// store keeps one entry per line precisely so that a partial write costs one
  /// entry instead of the whole record.
  static HistoryEntry? fromLine(String line) {
    final String trimmed = line.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    try {
      final dynamic decoded = json.decode(trimmed);
      return decoded is Map
          ? HistoryEntry.fromJson(decoded.cast<String, dynamic>())
          : null;
    } on FormatException {
      return null;
    }
  }

  @override
  String toString() => 'HistoryEntry($id, $title, $kind)';
}
