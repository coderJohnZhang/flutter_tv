import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/model/common/poster.dart';
import 'package:flutter_tv/util/focus_style.dart';
import 'package:flutter_tv/view/widget/featured_banner.dart';

/// The design canvas, so the banner is laid out at the proportions it is built
/// for and the text panel has the room the real screen gives it.
Future<void> pumpBanner(
  WidgetTester tester,
  Poster poster, {
  bool artworkOnRight = false,
  double leadingInset = 60.0,
  double artworkWidth = 420.0,
  Size artworkSize = const Size(312.0, 175.0),
  IconData? artworkIcon,
}) async {
  tester.view.physicalSize = const Size(1920.0, 1080.0);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: FeaturedBanner(
        poster: poster,
        highlightStyle: FocusHighlightStyle.both,
        onSelect: () {},
        height: 360.0,
        leadingInset: leadingInset,
        artworkOnRight: artworkOnRight,
        artworkWidth: artworkWidth,
        artworkSize: artworkSize,
        artworkIcon: artworkIcon,
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the artwork keeps its own shape instead of filling the banner',
      (WidgetTester tester) async {
    await pumpBanner(
      tester,
      const Poster(
        title: 'Freeview Explore',
        imageUrl: 'images/channels/channel_freeview_explore.webp',
      ),
    );

    final Finder art = find.descendant(
      of: find.byType(FeaturedBanner),
      matching: find.byType(Image),
    );
    expect(art, findsOneWidget);

    expect(tester.getSize(art), const Size(312.0, 175.0));
    expect(tester.getSize(art).width,
        lessThan(tester.getSize(find.byType(FeaturedBanner)).width));
  });

  testWidgets('a block with no artwork still draws its title',
      (WidgetTester tester) async {
    await pumpBanner(
      tester,
      const Poster(title: 'DTV', subtitle: 'Channels'),
    );

    // Asking for a file that is not there would throw rather than fall back.
    expect(find.byType(Image), findsNothing);
    expect(find.text('DTV'), findsOneWidget);
    expect(find.text('Channels'), findsOneWidget);
  });

  testWidgets('the DTV icon and title share a row inside the aligned banner',
      (WidgetTester tester) async {
    await pumpBanner(
      tester,
      const Poster(title: 'DTV'),
      leadingInset: 60.0,
      artworkWidth: 160.0,
      artworkSize: const Size(160.0, 118.0),
      artworkIcon: Icons.live_tv,
    );

    final Rect card = tester.getRect(find.byKey(const ValueKey<String>('featured')));
    final Rect icon = tester.getRect(find.byIcon(Icons.live_tv));
    final Rect title = tester.getRect(find.text('DTV'));

    expect(card.left, 60.0);
    expect(card.right, 1860.0);
    expect(icon.size, const Size(160.0, 118.0));
    expect(tester.widget<Icon>(find.byIcon(Icons.live_tv)).size, 112.0);
    expect(title.left, 252.0);
    expect(icon.right, lessThan(title.left));
  });
}
