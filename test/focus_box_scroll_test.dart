import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/util/focus_style.dart';
import 'package:flutter_tv/view/main/page_main.dart';
import 'package:flutter_tv/view/widget/focus_block_widget.dart';
import 'package:flutter_tv/view/widget/focus_box_overlay.dart';
import 'package:flutter_tv/view/widget/launcher_tab_page.dart';
import 'package:flutter_tv/view/widget/title_widget.dart';

/// The shell only looks for blocks inside a tab page, so a test needs one.
class _TallPage extends StatelessWidget implements LauncherTabPage {
  const _TallPage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Enough blocks, tall enough, that reaching the end has to scroll the page.
const int _blockCount = 6;
const double _blockHeight = 400.0;

/// A column of blocks taller than the viewport, inside a page that scrolls.
Future<void> pumpShell(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1920.0, 1080.0);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: LaunchMainPage(
        tabCount: 1,
        highlightStyle: FocusHighlightStyle.both,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 60.0),
            const SizedBox(height: 120.0, child: TitleWidget(title: 'RECENT')),
            Expanded(
              child: const _TallPage(
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      primary: true,
                      child: _BlockColumn(),
                    ),
                    Offstage(
                      child: SingleChildScrollView(
                        primary: true,
                        child: SizedBox(height: _blockCount * _blockHeight),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

class _BlockColumn extends StatelessWidget {
  const _BlockColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int i = 0; i < _blockCount; i++)
          Padding(
            padding: const EdgeInsets.only(left: 60.0, top: 24.0),
            child: FocusBlockWidget(
              key: ValueKey<String>('tile_$i'),
              highlightStyle: FocusHighlightStyle.both,
              onSelect: () {},
              child: const SizedBox(width: 320.0, height: _blockHeight),
            ),
          ),
      ],
    );
  }
}

Rect? overlayTarget(WidgetTester tester) {
  final FocusBoxOverlay overlay =
      tester.widget<FocusBoxOverlay>(find.byType(FocusBoxOverlay));
  return overlay.controller.target;
}

/// The block that currently holds the focus.
String focusedBlock(WidgetTester tester) {
  for (int i = 0; i < _blockCount; i++) {
    final FocusBlockWidgetState state = tester
        .state<FocusBlockWidgetState>(find.byKey(ValueKey<String>('tile_$i')));
    if (state.focused) {
      return 'tile_$i';
    }
  }
  fail('no block took the focus');
}

/// The geometry the focus engine reads for the block currently in focus.
Rect blockRect(WidgetTester tester, String key) {
  return tester
      .state<FocusBlockWidgetState>(find.byKey(ValueKey<String>(key)))
      .rect;
}

void main() {
  testWidgets('the box follows a block that a step scrolls the page to',
      (WidgetTester tester) async {
    await pumpShell(tester);

    for (int i = 0; i < _blockCount; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      final String key = focusedBlock(tester);
      expect(overlayTarget(tester), blockRect(tester, key),
          reason: 'the box came off $key once the page settled');
    }
  });

  testWidgets('the box follows a block the page has to scroll back for',
      (WidgetTester tester) async {
    await pumpShell(tester);

    // Down to the end of the page, which scrolls it to the bottom.
    for (int i = 0; i < _blockCount; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
    }
    expect(focusedBlock(tester), 'tile_${_blockCount - 1}');

    // Navigate back to the first block, then out of and back into content.
    for (int i = 1; i < _blockCount; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
    }
    expect(focusedBlock(tester), 'tile_0');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();

    final String key = focusedBlock(tester);
    expect(key, 'tile_0');
    expect(overlayTarget(tester), blockRect(tester, key),
        reason: 'the box stayed where $key used to be');
  });
}
