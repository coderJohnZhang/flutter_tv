import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/model/common/poster.dart';
import 'package:flutter_tv/model/tv/tv_catalog.dart';
import 'package:flutter_tv/model/layout/action_router.dart';
import 'package:flutter_tv/model/layout/layout_action.dart';
import 'package:flutter_tv/model/local/device_services.dart';
import 'package:flutter_tv/viewmodel/tv/tv_view_model.dart';

/// A platform that answers the tuner, or does not.
class _FakeDevice implements DeviceServices {
  _FakeDevice({
    this.input = '',
    this.channel = '',
    this.inserted = true,
  });

  final String input;
  final String channel;
  final bool inserted;
  bool signalAsked = false;

  @override
  Future<String> inputSource() async => input;

  @override
  Future<String> currentChannelInfo() async => channel;

  @override
  Future<bool> isSourceInserted() async {
    signalAsked = true;
    return inserted;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const TvCatalog _bundled = TvCatalog(
  input: 'DTV',
  heading: 'Channels',
  heroImage: 'images/channels/hero.jpg',
  channels: <TvChannel>[
    TvChannel(
      poster: Poster(blockId: 1, title: 'Blue Valley', imageUrl: 'a.jpg'),
      action: LayoutAction(action: 'tune_channel'),
    ),
    TvChannel(
      poster: Poster(blockId: 2, title: 'Quiet Coast', imageUrl: 'b.jpg'),
      action: LayoutAction(action: 'tune_channel'),
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled DTV identifies its input without borrowing ATV artwork', () async {
    final TvCatalog catalog = await TvCatalog.bundled();

    expect(catalog.input, 'DTV');
    expect(catalog.heroImage, isEmpty);
  });

  group('TvCatalog.fromJson', () {
    test('reads the input, the caption and every channel', () {
      final TvCatalog catalog = TvCatalog.fromJson(<String, dynamic>{
        'input': 'HDMI 1',
        'heading': 'Inputs',
        'heroImage': 'hero.jpg',
        'channels': <dynamic>[
          <String, dynamic>{
            'id': 7,
            'title': 'Blue Valley',
            'subtitle': '01',
            'image': 'a.jpg',
            'action': <String, dynamic>{'action': 'tune_channel'},
          },
          <String, dynamic>{'title': 'Quiet Coast', 'image': 'b.jpg'},
        ],
      });

      expect(catalog.input, 'HDMI 1');
      expect(catalog.heading, 'Inputs');
      expect(catalog.heroImage, 'hero.jpg');
      expect(catalog.channels.length, 2);
      expect(catalog.channels.first.poster.blockId, 7);
      expect(catalog.channels.first.poster.subtitle, '01');
      expect(catalog.channels.first.action.action, 'tune_channel');
    });

    test('a channel without an action carries an empty one', () {
      final TvCatalog catalog = TvCatalog.fromJson(<String, dynamic>{
        'channels': <dynamic>[
          <String, dynamic>{'title': 'Quiet Coast'},
        ],
      });

      expect(catalog.channels.single.action.isEmpty, isTrue);
    });

    test('an empty payload yields an empty catalog rather than throwing', () {
      final TvCatalog catalog = TvCatalog.fromJson(<String, dynamic>{});
      expect(catalog.isEmpty, isTrue);
      expect(catalog.posters, isEmpty);
    });

    test('finds the action belonging to a tile', () {
      expect(_bundled.actionFor(2).action, 'tune_channel');
      expect(_bundled.actionFor(99).isEmpty, isTrue);
    });
  });

  group('TvViewModel', () {
    test('draws the bundled input when no platform answers', () async {
      final _FakeDevice device = _FakeDevice();
      final TvViewModel viewModel =
          TvViewModel(catalog: _bundled, device: device, router: ActionRouter());

      final TvState state = await viewModel.load();

      expect(state.live, isFalse);
      expect(state.input, 'DTV');
      // Nothing is on, so the tab names no channel and the hero keeps the
      // backdrop that belongs to the input.
      expect(state.channelName, '');
      expect(state.heroImage, 'images/channels/hero.jpg');
      expect(state.channels.length, 2);
      // The signal is meaningless with nothing behind it, so it is not asked
      // for and the tab is not told the set has no signal.
      expect(device.signalAsked, isFalse);
      expect(state.hasSignal, isTrue);
    });

    test('shows what the platform reports when it answers', () async {
      final TvViewModel viewModel = TvViewModel(
        catalog: _bundled,
        device: _FakeDevice(input: 'HDMI 1', channel: 'Iron Peak'),
        router: ActionRouter(),
      );

      final TvState state = await viewModel.load();

      expect(state.live, isTrue);
      expect(state.input, 'HDMI 1');
      expect(state.channelName, 'Iron Peak');
      // The artwork stays the catalog's: a tuner names a channel, not a picture.
      expect(state.heroImage, 'images/channels/hero.jpg');
      expect(state.hasSignal, isTrue);
    });

    test('names the channel on air with the tile that goes with it',
        () async {
      final TvViewModel viewModel = TvViewModel(
        catalog: _bundled,
        device: _FakeDevice(input: 'DTV', channel: 'Quiet Coast'),
        router: ActionRouter(),
      );

      final TvState state = await viewModel.load();

      expect(state.channelName, 'Quiet Coast');
      expect(state.heroImage, 'b.jpg');
    });

    test('a platform that reports no signal says so', () async {
      final TvViewModel viewModel = TvViewModel(
        catalog: _bundled,
        device: _FakeDevice(input: 'HDMI 1', inserted: false),
        router: ActionRouter(),
      );

      final TvState state = await viewModel.load();

      expect(state.live, isTrue);
      expect(state.hasSignal, isFalse);
      // No channel was named, so the hero falls back to the input.
      expect(state.channelName, '');
    });

    test('an empty catalog leaves the hero blank rather than failing', () async {
      final TvViewModel viewModel = TvViewModel(
        catalog: const TvCatalog(),
        device: _FakeDevice(),
        router: ActionRouter(),
      );

      final TvState state = await viewModel.load();

      expect(state.channelName, '');
      expect(state.heroImage, '');
      expect(state.channels, isEmpty);
    });
  });
}
