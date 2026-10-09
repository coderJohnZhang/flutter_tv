import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/model/common/poster.dart';
import 'package:flutter_tv/view/widget/poster_tile.dart';

void main() {
  testWidgets('the shared poster caption keeps its translucent treatment',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 540.0,
          height: 304.0,
          child: PosterTile(
            poster: const Poster(
              title: 'Chili',
              imageUrl: 'images/apps/app_chili_light.webp',
            ),
          ),
        ),
      ),
    ));

    final Container caption = tester.widget<Container>(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Container && widget.color == const Color(0xAE000000),
      ),
    );
    expect(caption.color, const Color(0xAE000000));

    final Text label = tester.widget<Text>(find.text('Chili'));
    expect(label.style?.color, Colors.white);
    expect(label.style?.fontWeight, FontWeight.w500);
  });
}
