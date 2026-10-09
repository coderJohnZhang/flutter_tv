import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/util/app_theme.dart';
import 'package:flutter_tv/util/focus_style.dart';
import 'package:flutter_tv/view/main/page_main.dart';
import 'package:flutter_tv/view/widget/focus_block_widget.dart';
import 'package:flutter_tv/view/widget/focus_box_overlay.dart';
import 'package:flutter_tv/view/widget/launcher_tab_page.dart';
import 'package:flutter_tv/view/widget/title_widget.dart';

/// The shell only looks for blocks inside a tab page, so a test needs one.
class _TestPage extends StatelessWidget implements LauncherTabPage {
  const _TestPage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Mirrors how the app assembles the shell: a Scaffold body holding the shell,
/// which wraps a header column above a tab page.
Future<void> pumpShell(
  WidgetTester tester, {
  double topInset = 0.0,
  double leftInset = 0.0,
}) async {
  await tester.pumpWidget(MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(1280.0, 800.0),
        padding: EdgeInsets.only(top: topInset, left: leftInset),
      ),
      child: Scaffold(
        body: LaunchMainPage(
          tabCount: 1,
          highlightStyle: FocusHighlightStyle.both,
          child: Column(
            children: <Widget>[
              SizedBox(height: topInset + 60.0),
              const SizedBox(height: 120.0, child: TitleWidget(title: 'RECENT')),
              Expanded(
                child: _TestPage(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 40.0 + leftInset,
                        top: 20.0,
                      ),
                      child: FocusBlockWidget(
                        key: const ValueKey<String>('tile'),
                        highlightStyle: FocusHighlightStyle.both,
                        onSelect: () {},
                        child: const SizedBox(width: 320.0, height: 180.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ));
  await tester.pump();
}

Rect? overlayTarget(WidgetTester tester) {
  final FocusBoxOverlay overlay =
      tester.widget<FocusBoxOverlay>(find.byType(FocusBoxOverlay));
  return overlay.controller.target;
}

Future<FocusBlockWidgetState> focusTile(WidgetTester tester) async {
  // Down from the title row moves the focus into the tab page.
  await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
  await tester.pump();
  return tester.state<FocusBlockWidgetState>(
    find.byKey(const ValueKey<String>('tile')),
  );
}

/// The decoration a [DecoratedBox] under [finder] is painted with.

BoxDecoration decorationOf(WidgetTester tester, Finder finder) {
  return tester.widget<DecoratedBox>(finder).decoration as BoxDecoration;
}

void main() {
  testWidgets('the focus box lands exactly on the focused tile',
      (WidgetTester tester) async {
    await pumpShell(tester);
    final FocusBlockWidgetState tile = await focusTile(tester);

    expect(tile.focused, isTrue, reason: 'the tile never took the focus');

    final Rect? target = overlayTarget(tester);
    expect(target, isNotNull, reason: 'the focus box was never placed');
    expect(target, tile.rect, reason: 'tile=${tile.rect}  box=$target');
  });

  testWidgets('the focus box still lands on the tile below a system inset',
      (WidgetTester tester) async {
    await pumpShell(tester, topInset: 24.0, leftInset: 8.0);
    final FocusBlockWidgetState tile = await focusTile(tester);

    expect(tile.focused, isTrue, reason: 'the tile never took the focus');

    final Rect? target = overlayTarget(tester);
    expect(target, tile.rect, reason: 'tile=${tile.rect}  box=$target');
  });

  testWidgets('the box and the tile border come from one definition',
      (WidgetTester tester) async {
    await pumpShell(tester);
    final FocusBlockWidgetState tile = await focusTile(tester);
    expect(tile.focused, isTrue, reason: 'the tile never took the focus');

    final BoxDecoration block = decorationOf(
      tester,
      find.descendant(
        of: find.byType(FocusBlockWidget),
        matching: find.byType(DecoratedBox),
      ),
    );
    final BoxDecoration box = decorationOf(
      tester,
      find.descendant(
        of: find.byType(FocusBoxOverlay),
        matching: find.byType(DecoratedBox),
      ),
    );

    BorderSide side(BoxDecoration d) => (d.border! as Border).top;

    // Equal because both read the same constants, not because both were
    // tuned to look alike.
    expect(side(box).color, side(block).color);
    expect(side(box).width, side(block).width);
    expect(box.borderRadius, block.borderRadius);

    expect(side(box).color, kFocusColor);
    expect(side(box).width, kFocusBorderWidth);
    expect(
      box.borderRadius,
      const BorderRadius.all(Radius.circular(kFocusBorderRadius)),
    );
  });

  testWidgets('the box paints itself rather than a bitmap',
      (WidgetTester tester) async {
    await pumpShell(tester);
    await focusTile(tester);

    expect(
      find.descendant(
        of: find.byType(FocusBoxOverlay),
        matching: find.byType(Image),
      ),
      findsNothing,
      reason: 'the overlay still paints a sprite',
    );
  });
}
