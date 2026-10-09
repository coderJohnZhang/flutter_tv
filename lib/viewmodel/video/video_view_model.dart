import '../../model/common/poster.dart';
import '../../model/home/home_layout.dart';
import '../../model/recent/history_recorder.dart';
import '../../model/video/video_catalog.dart';
import '../base/view_model.dart';

/// Video tab business logic: the rows of titles the tab offers.
class VideoViewModel implements ViewModel {
  VideoViewModel({VideoCatalog? catalog, HistoryRecorder? history})
      : _catalog = catalog,
        _history = history ?? HistoryRecorder();

  VideoCatalog? _catalog;
  final HistoryRecorder _history;

  /// The catalog, read from the bundle the first time it is needed.
  Future<VideoCatalog> catalog() async =>
      _catalog ??= await VideoCatalog.bundled();

  /// The rows to draw, empty until the catalog has been read.
  Future<List<HomeRow>> rows() async => (await catalog()).rows;

  /// Records that the viewer opened [poster].
  ///
  /// A deployment's own catalog carries no target per title, so what opening
  /// one means is the host's to decide and there is nothing to route here.
  Future<void> launch(Poster poster) => _history.record(poster);

  @override
  void dispose() {}
}
