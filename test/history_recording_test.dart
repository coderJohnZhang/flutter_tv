import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/model/app/app_catalog.dart';
import 'package:flutter_tv/model/recent/history_entry.dart';
import 'package:flutter_tv/model/recent/history_recorder.dart';
import 'package:flutter_tv/model/recent/history_store.dart';
import 'package:flutter_tv/model/recent/recent_model.dart';
import 'package:flutter_tv/model/common/poster.dart';
import 'package:flutter_tv/viewmodel/app/apps_view_model.dart';
import 'package:flutter_tv/viewmodel/home/home_view_model.dart';
import 'package:flutter_tv/viewmodel/recent/recent_view_model.dart';
import 'package:flutter_tv/viewmodel/video/video_view_model.dart';

void main() {
  // Opening something also hands a target to the host, which reaches a method
  // channel, so the binding has to exist even though no host answers.
  TestWidgetsFlutterBinding.ensureInitialized();

  // The record is one shared instance, so each test starts from an empty one.
  setUp(() => HistoryStore.install(MemoryHistoryStore()));

  group('opening something records it', () {
    test('a title opened on the home tab reaches the recent tab', () async {
      await HomeViewModel().launch(
        const Poster(blockId: 1, title: 'Netflix', imageUrl: 'netflix.webp'),
      );

      // A different screen reading the record is the point: the tab that opens
      // and the tab that shows what was opened are not the same screen.
      final List<HistoryEntry> entries =
          await RecentViewModel().entries(HistoryEntry.kindTitle);

      expect(entries.single.title, 'Netflix');
      expect(entries.single.imageUrl, 'netflix.webp');
      expect(entries.single.openedAt, isNotNull);
    });

    test('a title opened on the video tab reaches the recent tab', () async {
      await VideoViewModel().launch(
        const Poster(blockId: 2, title: 'Feature 01', imageUrl: 'p1.webp'),
      );

      final List<HistoryEntry> entries =
          await RecentViewModel().entries(HistoryEntry.kindTitle);
      expect(entries.single.title, 'Feature 01');
    });

    test('an application is recorded as an application, not a title', () async {
      const AppEntry store = AppEntry(
        id: 3,
        title: 'App Store',
        imageUrl: 'store.webp',
      );
      await AppsViewModel().launch(store);

      final RecentViewModel recent = RecentViewModel();
      final List<HistoryEntry> apps =
          await recent.entries(HistoryEntry.kindApp);
      final List<HistoryEntry> titles =
          await recent.entries(HistoryEntry.kindTitle);

      expect(apps.single.title, 'App Store');
      expect(titles, isEmpty);
    });

    test('a tile with no title is not worth remembering', () async {
      await HomeViewModel().launch(const Poster(blockId: 4));
      expect(await RecentViewModel().all(), isEmpty);
    });

    test('opening the same thing twice replaces its entry', () async {
      final HomeViewModel home = HomeViewModel();
      const Poster poster = Poster(blockId: 5, title: 'Netflix');

      await home.launch(poster);
      await home.launch(poster);

      expect(await RecentViewModel().all(), hasLength(1));
    });
  });

  group('entryIdFor', () {
    test('is the same for the same title', () {
      expect(entryIdFor('Netflix'), entryIdFor('Netflix'));
    });

    test('differs between titles', () {
      expect(entryIdFor('Netflix'), isNot(entryIdFor('YouTube')));
    });

    test('is derived from the title, not from the position on screen', () {
      // Two posters for the same title at different positions in a layout are
      // the same thing to the viewer, so they share an entry.
      expect(
        entryIdFor(const Poster(blockId: 1, title: 'ITV').title),
        entryIdFor(const Poster(blockId: 99, title: 'ITV').title),
      );
    });
  });

  group('the record survives being handed on', () {
    test('a later record over the same store sees what was written', () async {
      await HistoryRecorder().record(const Poster(blockId: 6, title: 'MUBI'));

      final RecentModel reopened = RecentModel(store: HistoryStore.instance);
      expect((await reopened.all()).single.title, 'MUBI');
    });
  });
}
