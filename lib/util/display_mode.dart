import 'package:flutter/services.dart';

/// Puts the launcher on screen the way a television expects it.
///
/// A television has one posture and no system chrome the viewer wants to see, so
/// the launcher holds the landscape orientation and asks the platform to keep its
/// status and navigation bars out of the way. Both are framework calls, so a
/// platform that has no notion of either — a desktop session, a development
/// target — ignores them and the window is left as the runner opened it.
///
/// Applied by `TvLauncherApp` before its first frame. A deployment that wants it
/// applied earlier, or that runs the launcher some other way, can await this
/// itself.
Future<void> applyTvDisplayMode() async {
  await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}
