import 'model/local/device_services.dart';

/// Installs the platform integration, if there is one.
///
/// A deployment that has one replaces this file with its own version, which
/// installs its [DeviceServices]. Left as it is, no integration is installed
/// and the launcher runs against the neutral implementation.
void installDeviceServices() {
  // No integration: the launcher runs against the neutral implementation.
}
