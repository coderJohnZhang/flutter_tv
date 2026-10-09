import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/model/layout/action_router.dart';
import 'package:flutter_tv/model/layout/layout_action.dart';
import 'package:flutter_tv/model/local/device_services.dart';
import 'package:flutter_tv/model/local/platform_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // No host implements the channels under test, which is exactly the desktop
  // case: every call has to come back with a neutral answer instead of throwing.
  group('device services without a host', () {
    final DeviceServices device = DeviceServices.instance;

    test('text services answer with an empty string', () async {
      expect(await device.inputSource(), '');
      expect(await device.clientType(), '');
      expect(await device.mac(), '');
      expect(await device.launcherId(), '');
      expect(await device.currentChannelInfo(), '');
      expect(await device.property('anything'), '');
    });

    test('numeric services answer with zero', () async {
      expect(await device.connectionStatus(), 0);
      expect(await device.volumeCount(), 0);
    });

    test('flag services answer with false', () async {
      expect(await device.isSourceInserted(), isFalse);
      expect(await device.isTeletextOn(), isFalse);
    });

    test('the property reader honours its fallback', () async {
      expect(await device.property('key', fallback: 'none'), 'none');
    });

    test('the network check defaults to available, so the tab still loads', () async {
      // Status 0 means the host said nothing, not that the link is down.
      expect(await device.isNetworkAvailable(), isTrue);
      expect(await PlatformBridge.instance.isNetworkAvailable(), isTrue);
    });

    test('a write to a host that is not there does not throw', () async {
      await device.setInputSource('hdmi1');
      await device.setBacklight('high');
      await device.scaleVideoWindow(0, 0, 1920, 1080);
      await device.openBroadcastPortal();
      await PlatformBridge.instance.launchTarget(<String, dynamic>{'action': 'x'});
    });

    test('the host language is empty rather than an error', () async {
      expect(await PlatformBridge.instance.getCurrentLanguageCode(), '');
    });
  });

  group('locale support', () {
    test('offers more than the translated languages', () {
      final List<String> tags =
          PlatformBridge.instance.supportedLocales().map((l) => l.languageCode).toList();
      expect(tags, contains('en'));
      expect(tags, contains('ja'));
      expect(tags.length, greaterThan(PlatformBridge.translatedLanguageCodes.length));
    });

    test('the translated languages are a subset of what is offered', () {
      final List<String> tags =
          PlatformBridge.instance.supportedLocales().map((l) => l.languageCode).toSet().toList();
      for (final String code in PlatformBridge.translatedLanguageCodes) {
        expect(tags, contains(code));
      }
    });
  });

  group('action router', () {
    test('an empty action goes nowhere', () async {
      final ActionRouter router = ActionRouter();
      await router.open(const LayoutAction());
    });

    test('an action no one claims is handed to the host', () async {
      final ActionRouter router = ActionRouter();
      expect(router.handles('open_media'), isFalse);
      await router.open(const LayoutAction(action: 'open_media'));
      expect(router.handles('open_media'), isFalse);
    });

    test('a registered handler takes the action instead', () async {
      final ActionRouter router = ActionRouter();
      final List<String> handled = <String>[];
      router.register('open_recent', (LayoutAction action) async {
        handled.add(action.action);
        return true;
      });

      expect(router.handles('open_recent'), isTrue);
      await router.open(const LayoutAction(action: 'open_recent'));
      expect(handled, <String>['open_recent']);
    });

    test('a handler that declines passes the action on', () async {
      final ActionRouter router = ActionRouter();
      var called = 0;
      router.register('open_media', (LayoutAction action) async {
        called++;
        return false;
      });

      await router.open(const LayoutAction(action: 'open_media'));
      expect(called, 1);
    });

    test('the whole action reaches the host, first decision wins', () async {
      final ActionRouter router = ActionRouter();
      router.register('open_settings', (LayoutAction action) async => false);

      // Nothing to assert beyond it not throwing: the host is absent, which is
      // the point — an unclaimed action must not fail the launcher.
      await router.open(const LayoutAction(
        action: 'open_settings',
        packageName: 'com.example.settings',
        activityName: 'SettingsActivity',
      ));
    });
  });
}
