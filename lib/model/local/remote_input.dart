import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../util/remote_gesture.dart';

/// Continuous input from a remote's touch or pointing surface.
///
/// The key channel carries discrete presses only, so a remote that reports
/// *where* it was touched needs its own path into the launcher. This is a
/// launcher-level contract rather than a platform middleware one: it describes
/// the shape any host can answer, in the same way as the platform channel the
/// runner implements.
///
/// A host owes nothing here. One that answers no such channel simply never sends
/// a message, and the key path is unaffected.
class RemoteInput {
  RemoteInput._();

  /// The channel a host reports on.
  static const String channelName = 'tv_launcher/remote';

  /// A gesture on the wire is a small map of phase and position.
  static const BasicMessageChannel<Object?> channel =
      BasicMessageChannel<Object?>(channelName, JSONMessageCodec());

  static final StreamController<RemoteGesture> _controller =
      StreamController<RemoteGesture>.broadcast();
  static bool _attached = false;

  /// Gestures the host reports, empty when it reports none.
  ///
  /// The stream is shared, so several listeners see every gesture and a listener
  /// that arrives later still sees the ones after it.
  static Stream<RemoteGesture> get gestures {
    if (!_attached) {
      _attached = true;
      channel.setMessageHandler((Object? message) async {
        final RemoteGesture? gesture = decode(message);
        if (gesture != null) {
          _controller.add(gesture);
        }
        return null;
      });
    }
    return _controller.stream;
  }

  /// Reads one channel message, or null when it is not a gesture report.
  ///
  /// A message that is malformed, or that describes a phase this launcher has no
  /// meaning for, is dropped rather than thrown: input arriving from the host is
  /// not allowed to take the launcher down.
  static RemoteGesture? decode(Object? message) {
    if (message is! Map) {
      return null;
    }
    final GesturePhase? phase = gesturePhaseFrom(message['phase']);
    if (phase == null) {
      return null;
    }
    final Object? x = message['x'];
    final Object? y = message['y'];
    if (x is! num || y is! num) {
      return null;
    }
    return RemoteGesture(phase: phase, x: x.toDouble(), y: y.toDouble());
  }

  /// Feeds a gesture in without a platform channel.
  @visibleForTesting
  static void report(RemoteGesture gesture) => _controller.add(gesture);
}
