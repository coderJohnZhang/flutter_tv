import 'package:flutter/foundation.dart';

import '../../model/layout/action_router.dart';
import '../../model/layout/layout_action.dart';
import '../../model/local/device_services.dart';
import '../base/view_model.dart';

/// Shell state: which tab is selected, and leaving the launcher.
///
/// A [ValueNotifier] is sufficient for a single index: the page rebuilds
/// through a [ValueListenableBuilder] that listens to it.
class MainViewModel implements ViewModel {
  MainViewModel({DeviceServices? device, ActionRouter? router})
      : _device = device ?? DeviceServices.instance,
        _router = router ?? ActionRouter();

  final DeviceServices _device;
  final ActionRouter _router;

  final ValueNotifier<int> pageIndex = ValueNotifier<int>(0);

  /// Selects the tab at [index], ignoring out-of-range values.
  void selectPage(int index, {int tabCount = 0}) {
    if (index < 0 || (tabCount > 0 && index >= tabCount)) {
      return;
    }
    pageIndex.value = index;
  }

  /// Asks the host to dispose of the launcher.
  ///
  /// What leaving a launcher means belongs to the platform — closing the app,
  /// returning to another home screen, or refusing — so the request is only made
  /// here and never interpreted. The host may ignore it, which is what leaves a
  /// desktop build running.
  Future<void> leave() => _device.finishSelf();

  /// Asks whoever can resolve [action] to open the surface it names.
  ///
  /// The launcher names the surface a status bar entry stands for and never
  /// interprets it, so what an input source or a network menu actually is stays
  /// with the host.
  Future<void> openSurface(String action) =>
      _router.open(LayoutAction(action: action));

  @override
  void dispose() => pageIndex.dispose();
}
