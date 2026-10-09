/// The launcher's public entry point.
///
/// A deployment depends on this library to run the launcher and supply its own
/// platform integration. Everything else in the package is reachable through it,
/// or through the package's files directly, but this is the one thing a
/// deployment has to know about.
library;

export 'app.dart' show TvLauncherApp;
export 'model/local/device_services.dart' show DeviceServices;
export 'util/display_mode.dart' show applyTvDisplayMode;
