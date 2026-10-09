import '../../model/common/poster.dart';
import '../../model/home/home_model.dart';
import '../../model/layout/action_router.dart';
import '../../model/layout/layout_action.dart';
import '../../model/layout/layout_column.dart';
import '../../model/layout/layout_home_mapper.dart';
import '../../model/layout/layout_source.dart';
import '../../model/layout/layout_tab.dart';
import '../../model/layout/layout_template.dart';
import '../../model/layout/page_result.dart';
import '../../model/local/device_services.dart';
import '../../model/local/platform_bridge.dart';
import '../../model/recent/history_recorder.dart';
import '../../util/constant.dart';
import '../base/view_model.dart';

/// Home tab business logic.
///
/// One view, two sources. When a layout service is configured and the device is
/// online the tab is drawn from the service payload and its columns are paged in
/// as the viewer reaches the end; otherwise the bundled config is drawn and
/// there is nothing to page. A failure on the service path falls back to the
/// bundled config, so the tab always renders.
class HomeViewModel implements ViewModel {
  HomeViewModel({
    LayoutHomeMapper mapper = const LayoutHomeMapper(),
    LayoutSource? source,
    DeviceServices? device,
    ActionRouter? router,
    HistoryRecorder? history,
  })  : _mapper = mapper,
        _source = source,
        _device = device ?? DeviceServices.instance,
        _router = router ?? ActionRouter(),
        _history = history ?? HistoryRecorder();

  /// Name of the tab the home feed is taken from.
  static const String homeTabName = 'home';

  final HomeModel _bundled = HomeModel.instance;
  final PlatformBridge _bridge = PlatformBridge.instance;
  final LayoutHomeMapper _mapper;
  final DeviceServices _device;
  final ActionRouter _router;
  final HistoryRecorder _history;

  LayoutSource? _source;
  LayoutTemplate? _template;
  LayoutTab? _tab;
  int _nextPageNo = 1;
  bool _hasMoreColumns = false;

  /// True while the column list has not been reported as finished.
  bool get canLoadMore => _hasMoreColumns;

  /// Loads the first screen of the home feed.
  Future<MappedHome> load() async {
    if (!_hasService || !await _bridge.isNetworkAvailable()) {
      return _bundledFeed();
    }

    final LayoutSource source = await _resolveSource();
    final LayoutTemplate? template = await source.template();
    if (template == null) {
      return _bundledFeed();
    }

    final LayoutTemplate merged =
        template.merge(await source.content(template.templateId));
    final LayoutTab? tab = merged.tabNamed(homeTabName) ?? merged.defaultTab;
    if (tab == null) {
      return _bundledFeed();
    }

    _template = merged;
    _tab = tab;
    _nextPageNo = 1;
    // Columns are paged and a service need not announce how many it holds, so
    // the first request is what discovers whether there are any at all.
    _hasMoreColumns = true;
    return _mapper.map(tab: tab);
  }

  /// Appends the next page of columns, or null when there is nothing to add.
  Future<MappedHome?> loadMore(MappedHome current) async {
    final LayoutTab? tab = _tab;
    if (!_hasMoreColumns || tab == null) {
      return null;
    }

    final PageResult<LayoutColumn>? page =
        await (await _resolveSource()).columns(
      templateId: _template?.templateId ?? 0,
      tabId: tab.tabId,
      tabName: tab.name,
      pageNo: _nextPageNo,
    );
    if (page == null) {
      // The request failed rather than the list ending, so the page number and
      // the flag are left alone and a later scroll can ask again.
      return null;
    }

    _hasMoreColumns = page.hasMore;
    _nextPageNo = page.nextPageNo;
    if (page.isEmpty) {
      return null;
    }
    return _mapper.appendColumns(current, page.items);
  }

  /// Opens [poster], preferring the target the service attached to it.
  Future<void> launch(Poster poster, {LayoutAction? action}) async {
    await _history.record(poster, action: action);
    if (action != null && !action.isEmpty) {
      return _router.open(action);
    }
    return _bridge.launchApp(poster.title, extra: poster.imageUrl);
  }

  /// True when a layout service can be reached, by injection or configuration.
  bool get _hasService => _source != null || RemoteLayoutSource.isConfigured;

  Future<MappedHome> _bundledFeed() async =>
      MappedHome(layout: await _bundled.local());

  Future<LayoutSource> _resolveSource() async {
    final LayoutSource? existing = _source;
    if (existing != null) {
      return existing;
    }

    final RemoteLayoutSource source = RemoteLayoutSource(
      appVersion: kAppVersion,
      context: await _deviceContext(),
    );
    // A launcher the service has never seen carries no identifier, so it enrols
    // once and keeps what it was given. A deployment that identifies devices
    // another way simply does not answer, and enrolment is skipped.
    if ((await _device.launcherId()).isEmpty) {
      final String? assigned = await source.enrol();
      if (assigned != null) {
        await _device.setLauncherId(assigned);
      }
    }
    return _source = source;
  }

  /// What the device is, as the layout service needs to hear it.
 ///
  /// The launcher asks the host for every value rather than shipping any of its
  /// own, so the same build serves every deployment. A host that answers nothing
  /// yields an empty context, which the service treats as "unknown device".
  Future<Map<String, String>> _deviceContext() async {
    return <String, String>{
      'client_type': await _device.clientType(),
      'sys_version': await _device.systemVersion(),
      'device_id': await _device.deviceId(),
      'device_number': await _device.deviceNumber(),
      'project_id': await _device.projectId(),
      'launcher_id': await _device.launcherId(),
      'mac': await _device.mac(),
      'video_provider': await _device.videoProvider(),
      'zone': await _device.timeZone(),
      'language': await _bridge.getCurrentLanguageCode(),
    }..removeWhere((String key, String value) => value.isEmpty);
  }

  @override
  void dispose() {}
}
