import 'package:flutter/services.dart';

/// Remote-control actions the launcher reacts to.
enum NavKey { up, down, left, right, select, back }

/// Hardware key to [NavKey] mapping.
///
/// Logical keys are used instead of raw platform scan codes so a single code
/// path serves every TV platform the launcher targets. A remote that reports
/// arrow keys plus select works identically on Android TV and on a Linux TV OS,
/// where no Android key codes exist at all.
///
/// Kept as a `final` map rather than a `const` one: [LogicalKeyboardKey]
/// overrides `==`, which constant map keys are not allowed to do.
final Map<LogicalKeyboardKey, NavKey> _navKeyMap = <LogicalKeyboardKey, NavKey>{
  LogicalKeyboardKey.arrowUp: NavKey.up,
  LogicalKeyboardKey.arrowDown: NavKey.down,
  LogicalKeyboardKey.arrowLeft: NavKey.left,
  LogicalKeyboardKey.arrowRight: NavKey.right,
  // D-pad centre is reported as select on TVs, enter on keyboards.
  LogicalKeyboardKey.select: NavKey.select,
  LogicalKeyboardKey.enter: NavKey.select,
  LogicalKeyboardKey.numpadEnter: NavKey.select,
  LogicalKeyboardKey.gameButtonA: NavKey.select,
  LogicalKeyboardKey.space: NavKey.select,
  LogicalKeyboardKey.goBack: NavKey.back,
  LogicalKeyboardKey.escape: NavKey.back,
  LogicalKeyboardKey.browserBack: NavKey.back,
};

/// Resolves a hardware key to a launcher action, or null when uninteresting.
NavKey? navKeyFor(LogicalKeyboardKey key) => _navKeyMap[key];
