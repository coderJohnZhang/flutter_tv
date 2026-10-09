import '../../model/app/app_catalog.dart';
import '../../model/layout/action_router.dart';
import '../../model/recent/history_entry.dart';
import '../../model/recent/history_recorder.dart';
import '../base/view_model.dart';

/// Apps tab business logic: the catalog of shortcuts, and opening one.
class AppsViewModel implements ViewModel {
  AppsViewModel({
    AppCatalog? catalog,
    ActionRouter? router,
    HistoryRecorder? history,
  })  : _catalog = catalog,
        _router = router ?? ActionRouter(),
        _history = history ?? HistoryRecorder();

  AppCatalog? _catalog;
  final ActionRouter _router;
  final HistoryRecorder _history;

  /// The catalog, read from the bundle the first time it is needed.
  Future<AppCatalog> catalog() async => _catalog ??= await AppCatalog.bundled();

  /// Opens [entry] through the same router every other tile uses.
  ///
  /// An application is not a title, so its entry is recorded as one: the
  /// recent tab separates the two, because a viewer looking for an app is not
  /// looking for something to watch.
  Future<void> launch(AppEntry entry) async {
    await _history.record(
      entry.poster,
      kind: HistoryEntry.kindApp,
      action: entry.action,
    );
    return _router.open(entry.action);
  }

  @override
  void dispose() {}
}
