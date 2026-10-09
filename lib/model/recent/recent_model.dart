import 'history_entry.dart';
import 'history_store.dart';

/// What the viewer has opened, arranged the way the recent tab draws it.
///
/// A television's history is read in two directions at once: by kind, because
/// applications and titles are not the same thing to a viewer, and by recency,
/// because what was on today feels different from what was on last week. This
/// holds the entries and answers both groupings, so the widgets only decide how
/// to draw them.
class RecentModel {
  RecentModel({HistoryStore? store, DateTime Function()? clock})
      : _store = store ?? HistoryStore.instance,
        _clock = clock ?? DateTime.now;

  /// Name of the first group, for entries opened today.
  static const String groupToday = 'today';

  /// Name of the second group, for anything older.
  static const String groupEarlier = 'earlier';

  final HistoryStore _store;
  final DateTime Function() _clock;

  /// Everything the viewer opened, most recent first.
  Future<List<HistoryEntry>> all() => _store.read();

  /// Records that the viewer opened [entry], stamping it with the current time.
  ///
  /// The time is set here rather than by the caller so every entry carries the
  /// same notion of "now" the grouping will later read it against.
  Future<void> record(HistoryEntry entry) =>
      _store.record(entry.copyWith(openedAt: entry.openedAt ?? _clock()));

  /// Forgets the entry with [id].
  Future<void> forget(int id) => _store.remove(id);

  /// Forgets everything.
  Future<void> clear() => _store.clear();

  /// The entries of one [kind], most recent first.
  Future<List<HistoryEntry>> ofKind(String kind) async {
    final List<HistoryEntry> entries = await all();
    return <HistoryEntry>[
      for (final HistoryEntry entry in entries)
        if (entry.kind == kind) entry,
    ];
  }

  /// Groups [entries] into today's and everything earlier.
  ///
  /// An empty group is left out rather than returned empty, so the caller can
  /// draw what it is given without checking for a heading with nothing under it.
  Map<String, List<HistoryEntry>> groupByDay(
    List<HistoryEntry> entries, {
    DateTime? now,
  }) {
    final DateTime today = now ?? _clock();
    final List<HistoryEntry> todayEntries = <HistoryEntry>[];
    final List<HistoryEntry> earlierEntries = <HistoryEntry>[];
    for (final HistoryEntry entry in entries) {
      (entry.isOn(today) ? todayEntries : earlierEntries).add(entry);
    }

    return <String, List<HistoryEntry>>{
      if (todayEntries.isNotEmpty) groupToday: todayEntries,
      if (earlierEntries.isNotEmpty) groupEarlier: earlierEntries,
    };
  }

  /// The entries of [kind], grouped into today and earlier.
  Future<Map<String, List<HistoryEntry>>> grouped(
    String kind, {
    DateTime? now,
  }) async =>
      groupByDay(await ofKind(kind), now: now);
}
