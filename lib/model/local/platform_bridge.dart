import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../util/locale_catalog.dart';

/// Bridge to the host platform.
///
/// Android TV and a Linux TV OS both implement the same channel, so no
/// platform-specific code is needed on the Dart side. Every call degrades to a
/// safe default when the host does not implement it, which keeps the app
/// runnable on a plain desktop for UI work.
class PlatformBridge {
  PlatformBridge._();

  static final PlatformBridge instance = PlatformBridge._();

  static const MethodChannel channel = MethodChannel('tv_launcher/platform');

  /// Languages the launcher ships translations for. Anything else in
  /// [supportedLocales] falls back to English.
  static const List<String> translatedLanguageCodes = <String>['en', 'zh'];

  /// Locales a host may offer the viewer.
  ///
  /// This is the full catalog rather than only the translated languages, because
  /// a service can be asked for a locale the launcher has no bundle for; the
  /// text then falls back to English while the request still names it.
  List<Locale> supportedLocales() => LocaleCatalog.locales;

  /// A directory the launcher may keep its own files in, or empty.
  ///
  /// Asked of the host rather than taken from a plugin, because which directory
  /// is writable and survives a restart is a property of the platform. A host
  /// that answers nothing leaves the launcher keeping its history in memory.
  Future<String> storageDirectory() async {
    try {
      final String? directory =
          await channel.invokeMethod<String>('storageDirectory');
      return directory ?? '';
    } on MissingPluginException {
      // Host without storage: the history stays in memory.
      return '';
    } on PlatformException {
      return '';
    }
  }

  Future<bool> isNetworkAvailable() async {
    try {
      final bool? available =
          await channel.invokeMethod<bool>('isNetworkAvailable');
      return available ?? true;
    } on MissingPluginException {
      return true;
    } on PlatformException {
      return true;
    }
  }

  /// Asks the host to launch the application identified by [action].
  Future<void> launchApp(String action, {String extra = ''}) async {
    try {
      await channel.invokeMethod<void>('launchApp', <String, dynamic>{
        'action': action,
        'extra': extra,
      });
    } on MissingPluginException {
      // Host without app launching support: nothing to do.
    } on PlatformException {
      // Launch refused by the host.
    }
  }

  /// Language the host is running in, or an empty string when it does not say.
  ///
  /// Sent with every layout request so a service can answer in the viewer's
  /// language. An empty answer is not a failure: the launcher then relies on its
  /// own bundled translations.
  Future<String> getCurrentLanguageCode() async {
    try {
      final String? code =
          await channel.invokeMethod<String>('getCurrentLanguageCode');
      return code ?? '';
    } on MissingPluginException {
      return '';
    } on PlatformException {
      return '';
    }
  }

  /// Asks the host to open a layout target.
  ///
  /// The map carries whichever fields the service filled in — a logical action
  /// name, an explicit component, or a URI — and the host decides how to resolve
  /// it, so the launcher needs no table of target names of its own.
  Future<void> launchTarget(Map<String, dynamic> target) async {
    try {
      await channel.invokeMethod<void>('launchTarget', target);
    } on MissingPluginException {
      // Host without target launching support: nothing to do.
    } on PlatformException {
      // Target refused by the host.
    }
  }
}
