import 'package:flutter/services.dart';

/// The device-level services the launcher needs from its platform.
///
/// A TV launcher sits close to the hardware: it reads the input source, the
/// network, the tuner, the panel and the sound, and it asks the system to change
/// them. None of that is portable, so the implementation belongs to the platform
/// and reaches the launcher through a method channel.
///
/// This is the port, and it is deliberately only an interface. Whoever integrates
/// the launcher supplies the implementation, because only they know which
/// services their platform exposes and what they are called.
///
/// Every method has to be answerable when no platform is present at all, because
/// the launcher also runs on a desktop for UI work. That is the job of
/// [UnavailableDeviceServices], which is installed until an integration replaces
/// it.
abstract interface class DeviceServices {
  /// The implementation in force.
  ///
  /// Starts as the neutral one, so the launcher runs before any integration has
  /// had a chance to install itself.
  static DeviceServices instance = const UnavailableDeviceServices();

  /// Puts [services] in charge of device calls.
  static void install(DeviceServices services) => instance = services;

  // --- Input source -------------------------------------------------------

  /// The input the viewer is on.
  Future<String> inputSource();

  /// Switches to [source], named as [inputSource] reports it.
  Future<void> setInputSource(String source);

  /// True when a signal is present on the current input.
  Future<bool> isSourceInserted();

  /// The state of the signal on the current input.
  Future<String> signalState();

  // --- Picture ------------------------------------------------------------

  /// The screen mode.
  Future<String> screenMode();

  /// Asks for a screen mode by name.
  Future<void> setScreenMode(String mode);

  /// The dynamic backlight setting.
  Future<String> backlight();

  /// Applies a dynamic backlight setting by name.
  Future<void> setBacklight(String value);

  /// The panel size.
  Future<String> panelSize();

  /// Scales the video window on screen.
  Future<void> scaleVideoWindow(int x, int y, int width, int height);

  // --- Sound --------------------------------------------------------------

  /// True when teletext subtitles are on.
  Future<bool> isTeletextOn();

  /// Turns teletext subtitles on or off.
  Future<void> setTeletext(bool enabled);

  // --- Network ------------------------------------------------------------

  /// The addressing of the connection.
  Future<String> networkInfo();

  /// The kind of connection.
  Future<String> networkType();

  /// The connection state: 0 not connected, 1 has an address, 2 has the internet.
  Future<int> connectionStatus();

  /// The access point the device last joined.
  Future<String> lastConnectedAccessPoint();

  /// True when the device can reach the internet.
  Future<bool> isNetworkAvailable();

  // --- Tuner --------------------------------------------------------------

  /// The channel being watched.
  Future<String> currentChannelInfo();

  /// The identifier of the channel being watched.
  Future<String> currentChannelId();

  /// The channel with [channelId].
  Future<String> channelInfoById(String channelId);

  // --- System -------------------------------------------------------------

  /// The system time as the platform reports it.
  Future<String> systemTime();

  /// The system property [key], or [fallback] when it is unset.
  Future<String> property(String key, {String fallback});

  /// Sets a system property.
  Future<void> setProperty(String key, String value);

  /// How many removable volumes are mounted.
  Future<int> volumeCount();

  /// The state of the removable storage.
  Future<String> usbStatus();

  /// The country the device is configured for.
  Future<String> country();

  /// The time zone the device is configured for.
  Future<String> timeZone();

  /// Opens the broadcast portal.
  Future<void> openBroadcastPortal();

  /// Ends the launcher's own activity.
  Future<void> finishSelf();

  /// Asks the platform to start the activity named by [actionName].
  Future<void> startActivity(String actionName, Uint8List extraData);

  // --- Identity -----------------------------------------------------------

  /// The model the device identifies itself by.
  Future<String> clientType();

  /// The operating system version.
  Future<String> systemVersion();

  /// The hardware address of the device.
  Future<String> mac();

  /// The serial number of the device.
  Future<String> deviceNumber();

  /// The identifier the device is known by.
  Future<String> deviceId();

  /// The identifier of the deployment the device belongs to.
  Future<String> projectId();

  /// The identifier the layout service assigned to this launcher.
  Future<String> launcherId();

  /// Stores the identifier the layout service assigned.
  Future<void> setLauncherId(String id);

  /// Describes what the device can play.
  Future<String> videoProvider();
}

/// The implementation in force when no integration is installed.
///
/// Every read reports nothing and every write is ignored. The answers are chosen
/// so the UI degrades rather than breaks: the launcher opens, the layout falls
/// back to its bundled config, and a desktop run looks like a device with no
/// middleware — which is exactly what it is.
class UnavailableDeviceServices implements DeviceServices {
  const UnavailableDeviceServices();

  @override
  Future<String> inputSource() async => '';
  @override
  Future<void> setInputSource(String source) async {}
  @override
  Future<bool> isSourceInserted() async => false;
  @override
  Future<String> signalState() async => '';

  @override
  Future<String> screenMode() async => '';
  @override
  Future<void> setScreenMode(String mode) async {}
  @override
  Future<String> backlight() async => '';
  @override
  Future<void> setBacklight(String value) async {}
  @override
  Future<String> panelSize() async => '';
  @override
  Future<void> scaleVideoWindow(int x, int y, int width, int height) async {}

  @override
  Future<bool> isTeletextOn() async => false;
  @override
  Future<void> setTeletext(bool enabled) async {}

  @override
  Future<String> networkInfo() async => '';
  @override
  Future<String> networkType() async => '';
  @override
  Future<int> connectionStatus() async => 0;
  @override
  Future<String> lastConnectedAccessPoint() async => '';

  /// Reports an available network.
  ///
  /// A device that says nothing has not said it is offline, and a launcher that
  /// assumed the worst would refuse to load its feed on every platform that does
  /// not implement this call.
  @override
  Future<bool> isNetworkAvailable() async => true;

  @override
  Future<String> currentChannelInfo() async => '';
  @override
  Future<String> currentChannelId() async => '';
  @override
  Future<String> channelInfoById(String channelId) async => '';

  @override
  Future<String> systemTime() async => '';
  @override
  Future<String> property(String key, {String fallback = ''}) async => fallback;
  @override
  Future<void> setProperty(String key, String value) async {}
  @override
  Future<int> volumeCount() async => 0;
  @override
  Future<String> usbStatus() async => '';
  @override
  Future<String> country() async => '';
  @override
  Future<String> timeZone() async => '';
  @override
  Future<void> openBroadcastPortal() async {}
  @override
  Future<void> finishSelf() async {}
  @override
  Future<void> startActivity(String actionName, Uint8List extraData) async {}

  @override
  Future<String> clientType() async => '';
  @override
  Future<String> systemVersion() async => '';
  @override
  Future<String> mac() async => '';
  @override
  Future<String> deviceNumber() async => '';
  @override
  Future<String> deviceId() async => '';
  @override
  Future<String> projectId() async => '';
  @override
  Future<String> launcherId() async => '';
  @override
  Future<void> setLauncherId(String id) async {}
  @override
  Future<String> videoProvider() async => '';
}
