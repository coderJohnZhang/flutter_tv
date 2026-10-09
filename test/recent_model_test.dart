import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tv/model/layout/layout_action.dart';
import 'package:flutter_tv/model/recent/history_entry.dart';
import 'package:flutter_tv/model/recent/history_store.dart';
import 'package:flutter_tv/model/recent/recent_model.dart';

HistoryEntry _entry(
  int id,
  String title, {
  String kind = HistoryEntry.kindTitle,
  DateTime? at,
}) =>
    HistoryEntry(
      id: id,
      title: title,
      kind: kind,
      imageUrl: 'i$id.jpg',
      openedAt: at,
      target: LayoutAction(action: 'open_$id'),
    );

void main() {
  // The store is a shared instance, so a test that builds a record without
  // naming one must not inherit the previous test's entries.
  setUp(() => HistoryStore.install(MemoryHistoryStore()));

  group('entry serialisation', () {
    test('survives a round trip through one line', () {
      final HistoryEntry original = _entry(
        7,
        'Harbour Town',
        at: DateTime(2026, 10, 8, 21, 30),
      );
      final HistoryEntry? restored = HistoryEntry.fromLine(original.toLine());

      expect(restored, isNotNull);
      expect(restored!.id, 7);
      expect(restored.title, 'Harbour Town');
      expect(restored.imageUrl, 'i7.jpg');
      expect(restored.openedAt, DateTime(2026, 10, 8, 21, 30));
      expect(restored.target.action, 'open_7');
    });

    test('a blank line reads as nothing', () {
      expect(HistoryEntry.fromLine(''), isNull);
      expect(HistoryEntry.fromLine('   '), isNull);
    });

    test('an entry without a time is still written and read back', () {
      final String line = _entry(1, 'No time').toLine();
      expect(line.contains('opened_at'), isFalse);
      expect(HistoryEntry.fromLine(line)?.openedAt, isNull);
    });

    test('an entry with no time is never on any day', () {
      expect(_entry(1, 'No time').isOn(DateTime(2026, 10, 8)), isFalse);
    });

    test('tells an application from a title', () {
      expect(_entry(1, 'Store', kind: HistoryEntry.kindApp).isApp, isTrue);
      expect(_entry(1, 'Store', kind: HistoryEntry.kindApp).isTitle, isFalse);
      expect(_entry(2, 'Film').isTitle, isTrue);
    });
  });

  group('memory store', () {
    test('keeps the most recent entry first', () async {
      final MemoryHistoryStore store = MemoryHistoryStore();
      await store.record(_entry(1, 'One'));
      await store.record(_entry(2, 'Two'));

      expect(
        (await store.read()).map((HistoryEntry e) => e.title),
        <String>['Two', 'One'],
      );
    });

    test('recording the same id again replaces it and moves it to the front', () async {
      final MemoryHistoryStore store = MemoryHistoryStore();
      await store.record(_entry(1, 'One'));
      await store.record(_entry(2, 'Two'));
      await store.record(_entry(1, 'One again'));

      final List<HistoryEntry> entries = await store.read();
      expect(entries.length, 2);
      expect(entries.first.title, 'One again');
      expect(entries.last.title, 'Two');
    });

    test('drops the oldest entry once the limit is reached', () async {
      final MemoryHistoryStore store = MemoryHistoryStore(limit: 2);
      await store.record(_entry(1, 'One'));
      await store.record(_entry(2, 'Two'));
      await store.record(_entry(3, 'Three'));

      expect(
        (await store.read()).map((HistoryEntry e) => e.id),
        <int>[3, 2],
      );
    });

    test('removes one entry, and all of them', () async {
      final MemoryHistoryStore store = MemoryHistoryStore();
      await store.record(_entry(1, 'One'));
      await store.record(_entry(2, 'Two'));

      await store.remove(1);
      expect((await store.read()).single.id, 2);

      await store.clear();
      expect(await store.read(), isEmpty);
    });
  });

  group('file store', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('history_test');
    });

    tearDown(() async {
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
      }
    });

    test('records survive a new store over the same directory', () async {
      final FileHistoryStore first = FileHistoryStore(dir.path);
      await first.record(_entry(1, 'One', at: DateTime(2026, 10, 8)));
      await first.record(_entry(2, 'Two', at: DateTime(2026, 10, 8)));

      // A second store stands in for the app being started again.
      final List<HistoryEntry> reread =
          await FileHistoryStore(dir.path).read();
      expect(reread.length, 2);
      expect(reread.first.title, 'Two');
      expect(reread.first.openedAt, DateTime(2026, 10, 8));
    });

    test('an empty directory reads as no history rather than an error', () async {
      expect(await FileHistoryStore(dir.path).read(), isEmpty);
    });

    test('a corrupt line is skipped and the rest still reads', () async {
      final FileHistoryStore store = FileHistoryStore(dir.path);
      await store.record(_entry(1, 'One'));

      final File file = File('${dir.path}${Platform.pathSeparator}history.jsonl');
      await file.writeAsString(
        'not json at all\n${_entry(2, 'Two').toLine()}\n',
        flush: true,
      );

      final List<HistoryEntry> entries = await FileHistoryStore(dir.path).read();
      expect(entries.single.title, 'Two');
    });

    test('removing and clearing are written through', () async {
      final FileHistoryStore store = FileHistoryStore(dir.path);
      await store.record(_entry(1, 'One'));
      await store.record(_entry(2, 'Two'));

      await store.remove(1);
      expect((await FileHistoryStore(dir.path).read()).single.id, 2);

      await store.clear();
      expect(await FileHistoryStore(dir.path).read(), isEmpty);
    });
  });

  group('grouping', () {
    final DateTime now = DateTime(2026, 10, 8, 20, 0);

    test('splits today from everything earlier', () {
      final RecentModel model = RecentModel(clock: () => now);
      final Map<String, List<HistoryEntry>> groups = model.groupByDay(
        <HistoryEntry>[
          _entry(1, 'Today', at: DateTime(2026, 10, 8, 9, 0)),
          _entry(2, 'Earlier', at: DateTime(2026, 10, 7, 23, 0)),
          _entry(3, 'Also today', at: DateTime(2026, 10, 8, 19, 0)),
        ],
        now: now,
      );

      expect(groups[RecentModel.groupToday]!.map((HistoryEntry e) => e.id), <int>[1, 3]);
      expect(groups[RecentModel.groupEarlier]!.map((HistoryEntry e) => e.id), <int>[2]);
    });

    test('leaves out a group that has nothing in it', () {
      final RecentModel model = RecentModel(clock: () => now);
      final Map<String, List<HistoryEntry>> groups = model.groupByDay(
        <HistoryEntry>[_entry(1, 'Earlier', at: DateTime(2026, 1, 1))],
        now: now,
      );

      expect(groups.containsKey(RecentModel.groupToday), isFalse);
      expect(groups[RecentModel.groupEarlier]!.single.id, 1);
    });

    test('an entry with no time is counted as earlier', () {
      final RecentModel model = RecentModel(clock: () => now);
      final Map<String, List<HistoryEntry>> groups = model.groupByDay(
        <HistoryEntry>[_entry(1, 'Unknown')],
        now: now,
      );
      expect(groups[RecentModel.groupEarlier]!.single.id, 1);
    });

    test('a midwinter day is not confused with the year boundary', () {
      final RecentModel model = RecentModel(clock: () => DateTime(2027, 1, 1, 0, 30));
      final Map<String, List<HistoryEntry>> groups = model.groupByDay(
        <HistoryEntry>[_entry(1, 'Last year', at: DateTime(2026, 12, 31, 23, 0))],
        now: DateTime(2027, 1, 1, 0, 30),
      );
      expect(groups[RecentModel.groupEarlier]!.single.id, 1);
    });
  });

  group('recording', () {
    test('stamps the current time when none was given', () async {
      final DateTime now = DateTime(2026, 10, 8, 12, 0);
      final RecentModel model = RecentModel(clock: () => now);
      await model.record(_entry(1, 'One'));

      expect((await model.all()).single.openedAt, now);
    });

    test('keeps a time the caller supplied', () async {
      final DateTime opened = DateTime(2026, 10, 7, 8, 0);
      final RecentModel model = RecentModel(clock: () => DateTime(2026, 10, 8));
      await model.record(_entry(1, 'One', at: opened));

      expect((await model.all()).single.openedAt, opened);
    });

    test('filters by kind', () async {
      final RecentModel model = RecentModel();
      await model.record(_entry(1, 'Store', kind: HistoryEntry.kindApp));
      await model.record(_entry(2, 'Film'));

      expect((await model.ofKind(HistoryEntry.kindApp)).single.id, 1);
      expect((await model.ofKind(HistoryEntry.kindTitle)).single.id, 2);
    });

    test('groups one kind by day', () async {
      final DateTime now = DateTime(2026, 10, 8, 20, 0);
      final RecentModel model = RecentModel(clock: () => now);
      await model.record(_entry(1, 'Today', at: now));
      await model.record(_entry(2, 'Yesterday', at: DateTime(2026, 10, 7)));
      await model.record(_entry(3, 'An app', kind: HistoryEntry.kindApp, at: now));

      final Map<String, List<HistoryEntry>> groups =
          await model.grouped(HistoryEntry.kindTitle, now: now);
      expect(groups[RecentModel.groupToday]!.single.id, 1);
      expect(groups[RecentModel.groupEarlier]!.single.id, 2);
    });

    test('forgets one entry and then everything', () async {
      final RecentModel model = RecentModel();
      await model.record(_entry(1, 'One'));
      await model.record(_entry(2, 'Two'));

      await model.forget(1);
      expect((await model.all()).single.id, 2);

      await model.clear();
      expect(await model.all(), isEmpty);
    });
  });
}
