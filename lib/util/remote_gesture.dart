import 'nav_key.dart';

/// Stage a continuous gesture has reached.
enum GesturePhase { start, move, end, cancel }

/// Reads a phase from the name a host reports, or null when it is not one.
GesturePhase? gesturePhaseFrom(Object? name) => switch (name) {
      'start' => GesturePhase.start,
      'move' => GesturePhase.move,
      'end' => GesturePhase.end,
      'cancel' => GesturePhase.cancel,
      _ => null,
    };

/// One report from a remote's continuous input surface.
///
/// [x] and [y] are positions on the surface. Only their change between reports
/// carries meaning, so the origin and the unit are the host's to choose.
class RemoteGesture {
  const RemoteGesture({
    required this.phase,
    required this.x,
    required this.y,
  });

  final GesturePhase phase;
  final double x;
  final double y;
}

/// Turns a drag on a remote's input surface into remote-control steps.
///
/// A remote that reports where it was touched rather than which key was pressed
/// still has to drive a launcher, so a drag is read as a run of presses: the
/// direction the finger travels is the direction sent, and a press is emitted
/// once the finger has travelled [step] from wherever the last press was sent.
///
/// Two properties follow from re-anchoring after every press. A single long drag
/// covers several blocks instead of one, and a reversal within one drag is acted
/// on at once rather than having to first undo the distance already covered.
/// The axis is decided per press, by whichever of the two directions the finger
/// has travelled furthest, so a diagonal drag stays predictable.
class RemoteGestureTranslator {
  RemoteGestureTranslator({double step = 1.0}) : _step = step;

  double _step;

  /// Travel that amounts to one press, in the units the host reports.
  double get step => _step;

  set step(double value) {
    if (value > 0) {
      _step = value;
    }
  }

  bool _tracking = false;
  double _anchorX = 0.0;
  double _anchorY = 0.0;

  /// Takes one report and returns the press it amounts to, if any.
  NavKey? accept(RemoteGesture gesture) {
    switch (gesture.phase) {
      case GesturePhase.start:
        _tracking = true;
        _anchorX = gesture.x;
        _anchorY = gesture.y;
        return null;
      case GesturePhase.end:
      case GesturePhase.cancel:
        _tracking = false;
        return null;
      case GesturePhase.move:
        break;
    }
    if (!_tracking) {
      return null;
    }

    // Travelling towards an edge sends that direction, so the finger leads and
    // the focus follows, the way a D-pad behaves.
    final double travelX = _anchorX - gesture.x;
    final double travelY = _anchorY - gesture.y;

    final NavKey direction;
    if (travelX.abs() >= travelY.abs()) {
      if (travelX.abs() < _step) {
        return null;
      }
      direction = travelX >= 0.0 ? NavKey.left : NavKey.right;
    } else {
      if (travelY.abs() < _step) {
        return null;
      }
      direction = travelY >= 0.0 ? NavKey.up : NavKey.down;
    }

    _anchorX = gesture.x;
    _anchorY = gesture.y;
    return direction;
  }

  /// Forgets any drag in progress, for when the surface stops reporting.
  void reset() {
    _tracking = false;
    _anchorX = 0.0;
    _anchorY = 0.0;
  }
}
