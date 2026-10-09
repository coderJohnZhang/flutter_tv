import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/util/focus_style.dart';
import 'package:flutter_tv/view/widget/focus_block_widget.dart';

void main() {
  Future<GlobalKey<FocusBlockWidgetState>> pumpBlock(
    WidgetTester tester, {
    FocusHighlightStyle style = FocusHighlightStyle.border,
    VoidCallback? onSelect,
  }) async {
    final GlobalKey<FocusBlockWidgetState> key =
        GlobalKey<FocusBlockWidgetState>();
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: FocusBlockWidget(
          key: key,
          highlightStyle: style,
          onSelect: onSelect,
          child: const SizedBox(width: 100.0, height: 100.0),
        ),
      ),
    ));
    return key;
  }

  Border? currentBorder(WidgetTester tester) {
    final DecoratedBox box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(FocusBlockWidget),
        matching: find.byType(DecoratedBox),
      ),
    );
    final Decoration decoration = box.decoration;
    return decoration is BoxDecoration ? decoration.border as Border? : null;
  }

  testWidgets('border style draws a border only while focused',
      (WidgetTester tester) async {
    final GlobalKey<FocusBlockWidgetState> key = await pumpBlock(tester);

    expect(key.currentState!.focused, isFalse);
    expect(currentBorder(tester), isNull);

    key.currentState!.setFocus(true);
    await tester.pump();

    expect(key.currentState!.focused, isTrue);
    expect(currentBorder(tester), isNotNull);

    key.currentState!.setFocus(false);
    await tester.pump();
    expect(currentBorder(tester), isNull);
  });

  testWidgets('overlay style leaves the block untouched', (WidgetTester tester) async {
    final GlobalKey<FocusBlockWidgetState> key =
        await pumpBlock(tester, style: FocusHighlightStyle.overlay);

    key.currentState!.setFocus(true);
    await tester.pump();

    expect(key.currentState!.focused, isTrue);
    expect(currentBorder(tester), isNull);
  });

  testWidgets('select fires the callback', (WidgetTester tester) async {
    int activated = 0;
    final GlobalKey<FocusBlockWidgetState> key =
        await pumpBlock(tester, onSelect: () => activated++);

    key.currentState!.select();
    expect(activated, 1);
  });

  testWidgets('calculates its bounds in global coordinates', (WidgetTester tester) async {
    final GlobalKey<FocusBlockWidgetState> key = await pumpBlock(tester);

    key.currentState!.calculateRenderRect();
    final Rect rect = key.currentState!.rect;

    expect(rect.width, 100.0);
    expect(rect.height, 100.0);
    // Centred in an 800x600 test window.
    expect(rect.left, 350.0);
    expect(rect.top, 250.0);
  });
}
