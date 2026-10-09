import 'dart:async';

import 'package:flutter/material.dart';

/// The clock in the status bar.
///
/// It owns its own timer and rebuilds only itself, so the rest of the shell is
/// not rebuilt on every tick. The first tick is aligned to the next minute
/// boundary and only then becomes a one-minute period: a plain one-minute
/// period started at an arbitrary second would change the displayed minute up to
/// a minute late, which is visible on a clock.
///
/// The time source is injectable so the ticking can be tested without waiting for
/// a real minute to pass.
class TopBarClock extends StatefulWidget {
  const TopBarClock({
    super.key,
    this.clock,
    this.color = Colors.grey,
    this.fontSize = 32.0,
  });

  /// Reads the current time. Defaults to the system clock.
  final DateTime Function()? clock;

  final Color color;

  /// Font size in design units.
  final double fontSize;

  @override
  State<TopBarClock> createState() => TopBarClockState();
}

class TopBarClockState extends State<TopBarClock> {
  Timer? _timer;
  late DateTime _now;

  /// The time shown, for tests to read.
  String get label => formatTime(_now);

  DateTime _read() => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _now = _read();
    _align();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Waits out the rest of the current minute, then ticks once a minute.
  void _align() {
    final int secondsLeft = 60 - _now.second;
    _timer = Timer(Duration(seconds: secondsLeft), () {
      if (!mounted) {
        return;
      }
      setState(() => _now = _read());
      _timer = Timer.periodic(const Duration(minutes: 1), (Timer _) {
        if (mounted) {
          setState(() => _now = _read());
        }
      });
    });
  }

  /// Formats [time] the way a status bar shows it, in twenty-four hours.
  static String formatTime(DateTime time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(color: widget.color, fontSize: widget.fontSize),
    );
  }
}
