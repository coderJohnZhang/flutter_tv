import '../local/platform_bridge.dart';
import 'layout_action.dart';

/// Handles one action inside the launcher and reports whether it did.
///
/// Returning false passes the action on to the host, so a handler only has to
/// claim the actions it really owns.
typedef LocalActionHandler = Future<bool> Function(LayoutAction action);

/// Opens the target behind a tile.
///
/// A layout tells a tile what to do in three possible ways, and the launcher
/// takes them in the order that needs the least knowledge of the host:
///
/// 1. A [LocalActionHandler] registered for the action name, when the launcher
///    itself is the right place to handle it — switching a tab, for instance.
/// 2. The host, through [PlatformBridge.launchTarget], which is handed the
///    whole action and resolves the component or the URI itself.
///
/// Nothing here carries a list of target names. The name travels with the
/// action and whoever can resolve it does so, so a deployment can change what a
/// tile opens without changing the launcher.
class ActionRouter {
  ActionRouter({PlatformBridge? bridge})
      : _bridge = bridge ?? PlatformBridge.instance;

  final PlatformBridge _bridge;
  final Map<String, LocalActionHandler> _handlers = <String, LocalActionHandler>{};

  /// Routes [name] to [handler] inside the launcher.
  void register(String name, LocalActionHandler handler) {
    _handlers[name] = handler;
  }

  /// True when the launcher handles [name] itself rather than passing it on.
  bool handles(String name) => _handlers.containsKey(name);

  /// Opens [action], locally when possible and through the host otherwise.
  Future<void> open(LayoutAction action) async {
    if (action.isEmpty) {
      return;
    }
    final LocalActionHandler? handler = _handlers[action.action];
    if (handler != null && await handler(action)) {
      return;
    }
    await _bridge.launchTarget(action.toJson());
  }
}
