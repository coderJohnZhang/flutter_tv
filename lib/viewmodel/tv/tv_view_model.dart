import '../../model/common/poster.dart';
import '../../model/layout/action_router.dart';
import '../../model/layout/layout_action.dart';
import '../../model/local/device_services.dart';
import '../../model/recent/history_recorder.dart';
import '../../model/tv/tv_catalog.dart';
import '../base/view_model.dart';

/// What the TV tab draws.
class TvState {
  const TvState({
    required this.input,
    required this.heading,
    required this.channelName,
    required this.heroImage,
    required this.channels,
    required this.live,
    required this.hasSignal,
  });

  /// The input the set is on.
  final String input;

  /// Caption above the channel list.
  final String heading;

  /// The name of the channel on screen.
  final String channelName;

  /// Artwork behind [channelName], or the input's backdrop when nothing is on.
  final String heroImage;

  final List<Poster> channels;

  /// True when the platform answered the tuner.
  final bool live;

  /// The state of the signal on [input]. Only meaningful while [live].
  final bool hasSignal;
}

/// TV tab business logic.
///
/// One view, two sources, the same shape as the home tab. When a platform
/// answers the tuner the tab shows what the set is actually on; otherwise it
/// shows the bundled channel list. Either way the tab renders, so a desktop —
/// where nothing answers — is a usable way to work on it.
class TvViewModel implements ViewModel {
  TvViewModel({
    TvCatalog? catalog,
    DeviceServices? device,
    ActionRouter? router,
    HistoryRecorder? history,
  })  : _catalog = catalog,
        _device = device ?? DeviceServices.instance,
        _router = router ?? ActionRouter(),
        _history = history ?? HistoryRecorder();

  final DeviceServices _device;
  final ActionRouter _router;
  final HistoryRecorder _history;
  TvCatalog? _catalog;

  /// The catalog, read from the bundle the first time it is needed.
  Future<TvCatalog> catalog() async => _catalog ??= await TvCatalog.bundled();

  Future<TvState> load() async {
    final TvCatalog bundled = await catalog();
    final String reportedInput = await _device.inputSource();
    final String reportedChannel = await _device.currentChannelInfo();

    // A platform counts as present once it has named something. The signal is
    // asked for only after that, because with no platform its answer cannot be
    // told apart from a set that really has no signal.
    final bool live = reportedInput.isNotEmpty || reportedChannel.isNotEmpty;

    return TvState(
      input: reportedInput.isNotEmpty ? reportedInput : bundled.input,
      heading: bundled.heading,
      channelName: reportedChannel,
      heroImage: _artworkFor(bundled, reportedChannel),
      channels: bundled.posters,
      live: live,
      hasSignal: live ? await _device.isSourceInserted() : true,
    );
  }

  /// The art behind the channel the platform named, or the input's backdrop.
  ///
  /// A tuner hands over a name and no picture, and the catalog is the only
  /// thing that can turn one into the other. With nothing named the hero keeps
  /// the input's own backdrop, so it never shows a channel the set is not on.
  String _artworkFor(TvCatalog catalog, String channelName) {
    if (channelName.isNotEmpty) {
      for (final Poster poster in catalog.posters) {
        if (poster.title.toLowerCase() == channelName.toLowerCase()) {
          return poster.imageUrl;
        }
      }
    }
    return catalog.heroImage;
  }

  /// Opens [poster], preferring the target the catalog attached to it.
  Future<void> tune(Poster poster, {LayoutAction? action}) async {
    await _history.record(poster, action: action);
    if (action != null && !action.isEmpty) {
      return _router.open(action);
    }
  }

  @override
  void dispose() {}
}
