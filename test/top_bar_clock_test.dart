import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/view/widget/top_bar_clock.dart';

void main() {
  group('formatting', () {
    test('pads both fields to two digits', () {
      expect(TopBarClockState.formatTime(DateTime(2026, 10, 8, 9, 5)), '09:05');
      expect(TopBarClockState.formatTime(DateTime(2026, 10, 8, 23, 59)), '23:59');
      expect(TopBarClockState.formatTime(DateTime(2026, 10, 8, 0, 0)), '00:00');
    });
  });

  group('ticking', () {
    testWidgets('shows the time it was created with', (WidgetTester tester) async {
      DateTime now = DateTime(2026, 10, 8, 9, 5);
      await tester.pumpWidget(
        MaterialApp(home: TopBarClock(clock: () => now)),
      );

      expect(find.text('09:05'), findsOneWidget);
    });

    testWidgets('advances when the minute turns over', (WidgetTester tester) async {
      DateTime now = DateTime(2026, 10, 8, 9, 5);
      await tester.pumpWidget(
        MaterialApp(home: TopBarClock(clock: () => now)),
      );
      expect(find.text('09:05'), findsOneWidget);

      // The alignment timer is set for the rest of the minute, which is a full
      // minute because the time starts on the boundary.
      now = DateTime(2026, 10, 8, 9, 6);
      await tester.pump(const Duration(minutes: 1));
      expect(find.text('09:06'), findsOneWidget);
      expect(find.text('09:05'), findsNothing);
    });

    testWidgets('keeps ticking after the first minute', (WidgetTester tester) async {
      DateTime now = DateTime(2026, 10, 8, 9, 5);
      await tester.pumpWidget(
        MaterialApp(home: TopBarClock(clock: () => now)),
      );

      for (int i = 1; i <= 3; i++) {
        now = DateTime(2026, 10, 8, 9, 5 + i);
        await tester.pump(const Duration(minutes: 1));
        expect(find.text('09:0${5 + i}'), findsOneWidget);
      }
    });

    testWidgets('waits only the rest of the minute when created mid-minute',
        (WidgetTester tester) async {
      DateTime now = DateTime(2026, 10, 8, 9, 5, 40);
      await tester.pumpWidget(
        MaterialApp(home: TopBarClock(clock: () => now)),
      );
      expect(find.text('09:05'), findsOneWidget);

      // Twenty seconds are left, so that is when the minute turns over.
      now = DateTime(2026, 10, 8, 9, 6);
      await tester.pump(const Duration(seconds: 20));
      expect(find.text('09:06'), findsOneWidget);
    });

    testWidgets('stops ticking once it is disposed', (WidgetTester tester) async {
      DateTime now = DateTime(2026, 10, 8, 9, 5);
      await tester.pumpWidget(
        MaterialApp(home: TopBarClock(clock: () => now)),
      );

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      // A pending timer after disposal would trip the framework's own check.
      await tester.pump(const Duration(minutes: 2));
      expect(find.byType(TopBarClock), findsNothing);
    });
  });
}
