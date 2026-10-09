import 'package:flutter/widgets.dart';

import 'app.dart';
import 'bootstrap.dart';

/// The launcher's own entry point.
///
/// A deployment does not call this: it composes the launcher with its own
/// integration and runs [TvLauncherApp] itself, so the integration is never a
/// dependency of the launcher. This file exists so the launcher runs on its own —
/// on a desktop for UI work, and in this repository — with no integration
/// present at all.
void main() {
  installDeviceServices();
  runApp(const TvLauncherApp());
}
