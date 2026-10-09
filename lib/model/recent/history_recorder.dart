import '../common/poster.dart';
import '../layout/layout_action.dart';
import 'history_entry.dart';
import 'recent_model.dart';

/// Writes down what the viewer opened.
///
/// Every tab that can open something records through here, so an entry left by
/// an application and one left by a title have the same shape, and there is one
/// place that decides what opening something means.
class HistoryRecorder {
  HistoryRecorder({RecentModel? model}) : _model = model ?? RecentModel();

  final RecentModel _model;

  /// Records [poster] as opened, with the target it is about to open.
  ///
  /// A tile with no title is not worth remembering, and recording it would put
  /// a blank entry in front of the viewer, so it is dropped.
  Future<void> record(
    Poster poster, {
    String kind = HistoryEntry.kindTitle,
    LayoutAction? action,
  }) {
    if (poster.title.isEmpty) {
      return Future<void>.value();
    }
    return _model.record(HistoryEntry(
      id: entryIdFor(poster.title),
      title: poster.title,
      kind: kind,
      imageUrl: poster.imageUrl,
      target: action ?? const LayoutAction(),
    ));
  }
}

/// The identifier a title is remembered by.
///
/// The record replaces an entry by its identifier, so opening the same title
/// twice has to produce the same number. It comes from the title rather than
/// from the tile's position, which changes with the layout.
int entryIdFor(String title) {
  int hash = 7;
  for (final int unit in title.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}
