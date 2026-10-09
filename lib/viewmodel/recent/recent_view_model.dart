import '../../model/layout/action_router.dart';
import '../../model/recent/history_entry.dart';
import '../../model/recent/recent_model.dart';
import '../base/view_model.dart';

/// The recent tab, and the record it draws from.
///
/// The tab is a view over the history the launcher keeps: it groups the entries
/// the way the viewer expects to find them, and it is where an entry is removed
/// or the whole record cleared. Everything it shows comes from the store, so the
/// tab survives a restart and a host that supplies its own store works unchanged.
class RecentViewModel implements ViewModel {
  RecentViewModel({RecentModel? model, ActionRouter? router})
      : _model = model ?? RecentModel(),
        _router = router ?? ActionRouter();

  final RecentModel _model;
  final ActionRouter _router;

  /// Entries of one [kind], grouped into today and earlier.
  Future<Map<String, List<HistoryEntry>>> grouped(String kind) =>
      _model.grouped(kind);

  /// Entries of one [kind], most recent first.
  Future<List<HistoryEntry>> entries(String kind) => _model.ofKind(kind);

  /// Everything, most recent first.
  Future<List<HistoryEntry>> all() => _model.all();

  /// Records that the viewer opened [entry].
  Future<void> record(HistoryEntry entry) => _model.record(entry);

  /// Opens [entry] again.
  ///
  /// The target is the one the entry was recorded with, so reopening goes
  /// where it went the first time without the tab knowing what it was.
  Future<void> reopen(HistoryEntry entry) => _router.open(entry.target);

  /// Forgets one entry.
  Future<void> forget(int id) => _model.forget(id);

  /// Forgets everything.
  Future<void> clear() => _model.clear();

  @override
  void dispose() {}
}
