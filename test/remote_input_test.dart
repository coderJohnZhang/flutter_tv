import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tv/model/local/remote_input.dart';
import 'package:flutter_tv/util/nav_key.dart';
import 'package:flutter_tv/util/remote_gesture.dart';
import 'package:flutter_tv/view/main/page_main.dart';
import 'package:flutter_tv/view/widget/title_widget.dart';
import 'package:flutter_tv/view/widget/topbar_widget.dart';

RemoteGesture _report(GesturePhase phase, double x, double y) =>
    RemoteGesture(phase: phase, x: x, y: y);

void main() {
  group('RemoteGestureTranslator', () {
    test('a drag shorter than one step sends nothing', () {
      final RemoteGestureTranslator translator =
          RemoteGestureTranslator(step: 100.0)
            ..accept(_report(GesturePhase.start, 500.0, 500.0));

      expect(translator.accept(_report(GesturePhase.move, 450.0, 500.0)),
          isNull);
    });

    test('travel towards an edge sends that direction', () {
      final RemoteGestureTranslator left = RemoteGestureTranslator(step: 100.0)
        ..accept(_report(GesturePhase.start, 500.0, 500.0));
      expect(left.accept(_report(GesturePhase.move, 380.0, 500.0)), NavKey.left);

      final RemoteGestureTranslator right = RemoteGestureTranslator(step: 100.0)
        ..accept(_report(GesturePhase.start, 500.0, 500.0));
      expect(
          right.accept(_report(GesturePhase.move, 620.0, 500.0)), NavKey.right);

      final RemoteGestureTranslator up = RemoteGestureTranslator(step: 100.0)
        ..accept(_report(GesturePhase.start, 500.0, 500.0));
      expect(up.accept(_report(GesturePhase.move, 500.0, 380.0)), NavKey.up);

      final RemoteGestureTranslator down = RemoteGestureTranslator(step: 100.0)
        ..accept(_report(GesturePhase.start, 500.0, 500.0));
      expect(
          down.accept(_report(GesturePhase.move, 500.0, 620.0)), NavKey.down);
    });

    test('one long drag covers several blocks', () {
      final RemoteGestureTranslator translator =
          RemoteGestureTranslator(step: 100.0)
            ..accept(_report(GesturePhase.start, 500.0, 500.0));

      final List<NavKey?> sent = <NavKey?>[
        translator.accept(_report(GesturePhase.move, 390.0, 500.0)),
        translator.accept(_report(GesturePhase.move, 280.0, 500.0)),
        translator.accept(_report(GesturePhase.move, 170.0, 500.0)),
      ];

      expect(sent, <NavKey>[NavKey.left, NavKey.left, NavKey.left]);
    });

    test('a reversal mid-drag is acted on without undoing the distance', () {
      final RemoteGestureTranslator translator =
          RemoteGestureTranslator(step: 100.0)
            ..accept(_report(GesturePhase.start, 500.0, 500.0));
      expect(translator.accept(_report(GesturePhase.move, 380.0, 500.0)),
          NavKey.left);

      // Still 120 short of the original origin, but a full step back from where
      // the last press was sent.
      expect(translator.accept(_report(GesturePhase.move, 500.0, 500.0)),
          NavKey.right);
    });

    test('the axis the finger travelled furthest decides the direction', () {
      final RemoteGestureTranslator translator =
          RemoteGestureTranslator(step: 100.0)
            ..accept(_report(GesturePhase.start, 500.0, 500.0));

      expect(translator.accept(_report(GesturePhase.move, 380.0, 420.0)),
          NavKey.left);
    });

    test('a diagonal below the step on both axes sends nothing', () {
      final RemoteGestureTranslator translator =
          RemoteGestureTranslator(step: 100.0)
            ..accept(_report(GesturePhase.start, 500.0, 500.0));

      expect(translator.accept(_report(GesturePhase.move, 430.0, 440.0)),
          isNull);
    });

    test('a move outside a drag sends nothing', () {
      final RemoteGestureTranslator translator =
          RemoteGestureTranslator(step: 100.0);

      expect(translator.accept(_report(GesturePhase.move, 100.0, 100.0)),
          isNull);
    });

    test('the drag ends on end and on cancel alike', () {
      for (final GesturePhase ending in <GesturePhase>[
        GesturePhase.end,
        GesturePhase.cancel,
      ]) {
        final RemoteGestureTranslator translator =
            RemoteGestureTranslator(step: 100.0)
              ..accept(_report(GesturePhase.start, 500.0, 500.0));
        expect(translator.accept(_report(ending, 500.0, 500.0)), isNull);
        expect(translator.accept(_report(GesturePhase.move, 100.0, 500.0)),
            isNull);
      }
    });

    test('a step of zero or less is refused', () {
      final RemoteGestureTranslator translator =
          RemoteGestureTranslator(step: 100.0)..step = 0.0;
      expect(translator.step, 100.0);
      translator.step = -5.0;
      expect(translator.step, 100.0);
    });

    test('reset forgets a drag in progress', () {
      final RemoteGestureTranslator translator =
          RemoteGestureTranslator(step: 100.0)
            ..accept(_report(GesturePhase.start, 500.0, 500.0))
            ..reset();

      expect(translator.accept(_report(GesturePhase.move, 100.0, 500.0)),
          isNull);
    });
  });

  group('RemoteInput.decode', () {
    test('reads a well-formed report', () {
      final RemoteGesture? gesture = RemoteInput.decode(<String, Object?>{
        'phase': 'move',
        'x': 12,
        'y': 34.5,
      });

      expect(gesture, isNotNull);
      expect(gesture!.phase, GesturePhase.move);
      expect(gesture.x, 12.0);
      expect(gesture.y, 34.5);
      expect(RemoteInput.channelName, 'tv_launcher/remote');
    });

    test('drops a message it cannot read', () {
      expect(RemoteInput.decode(null), isNull);
      expect(RemoteInput.decode('move'), isNull);
      expect(RemoteInput.decode(<String, Object?>{'phase': 'move'}), isNull);
      expect(RemoteInput.decode(<String, Object?>{'phase': 'loc', 'x': 1, 'y': 2}),
          isNull);
      expect(
        RemoteInput.decode(
            <String, Object?>{'phase': 'move', 'x': 'left', 'y': 2}),
        isNull,
      );
    });
  });

  group('back at the home position', () {
    testWidgets('is offered to the host', (WidgetTester tester) async {
      int exits = 0;
      await tester.pumpWidget(MaterialApp(
        home: LaunchMainPage(
          tabCount: 1,
          onExit: () => exits++,
          child: const TitleWidget(title: 'RECENT'),
        ),
      ));
      await tester.pump();

      // Escape resolves to a physical key in the test simulator, and the
      // mapping reads it as a back press on the same path as a remote.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(exits, 1);
    });

    testWidgets('steps off the status bar before leaving',
        (WidgetTester tester) async {
      int exits = 0;
      await tester.pumpWidget(MaterialApp(
        home: LaunchMainPage(
          tabCount: 1,
          onExit: () => exits++,
          child: const Column(
            children: <Widget>[
              TopBarWidget(icon: Icons.wifi, label: 'wifi'),
              TitleWidget(title: 'RECENT'),
            ],
          ),
        ),
      ));
      await tester.pump();

      // Up from the titles moves the focus onto the status bar, where back still
      // has somewhere to go.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      // Escape resolves to a physical key in the test simulator, and the
      // mapping reads it as a back press on the same path as a remote.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(exits, 0);

      // Escape resolves to a physical key in the test simulator, and the
      // mapping reads it as a back press on the same path as a remote.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(exits, 1);
    });

    testWidgets('is absorbed when no host asks for it',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: LaunchMainPage(
          tabCount: 1,
          child: TitleWidget(title: 'RECENT'),
        ),
      ));
      await tester.pump();

      // Escape resolves to a physical key in the test simulator, and the
      // mapping reads it as a back press on the same path as a remote.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
    });
  });

  group('selecting', () {
    testWidgets('activates the status bar entry that holds the focus',
        (WidgetTester tester) async {
      int opened = 0;
      await tester.pumpWidget(MaterialApp(
        home: LaunchMainPage(
          tabCount: 1,
          child: Column(
            children: <Widget>[
              TopBarWidget(
                icon: Icons.input,
                label: 'source',
                onSelect: () => opened++,
              ),
              const TitleWidget(title: 'RECENT'),
            ],
          ),
        ),
      ));
      await tester.pump();

      // Up from the titles puts the focus on the status bar, where the entry is
      // focusable: selecting it has to reach it rather than being swallowed.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pump();

      expect(opened, 1);
    });

    testWidgets('does nothing where there is nothing to activate',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: LaunchMainPage(
          tabCount: 1,
          child: TitleWidget(title: 'RECENT'),
        ),
      ));
      await tester.pump();

      // The title row is a position, not a control, so selecting it is absorbed.
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pump();
    });
  });
}
