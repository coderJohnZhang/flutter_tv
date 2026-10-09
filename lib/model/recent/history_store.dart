import 'dart:async';
import 'dart:io';

import '../local/platform_bridge.dart';
import 'history_entry.dart';

/// Where the launcher keeps what the viewer has opened.
///
/// The interface exists so the launcher does not depend on a filesystem: a host
/// with its own store implements it, and the default keeps everything in memory,
/// which is enough for a desktop and for tests.
abstract class HistoryStore {
  /// The store in force.
  ///
  /// One instance serves every screen that reads or writes the record, because
  /// the history is one thing: the tab that records an entry and the tab that
  /// draws it are different screens looking at the same list.
  static HistoryStore instance = MemoryHistoryStore();

  /// Puts [store] in charge of the record.
  static void install(HistoryStore store) => instance = store;

  /// Every entry, most recent first.
  Future<List<HistoryEntry>> read();

  /// Adds [entry], replacing any earlier entry for the same title.
  Future<void> record(HistoryEntry entry);

  /// Removes the entry with [id].
  Future<void> remove(int id);

  /// Removes everything.
  Future<void> clear();
}

/// A store that keeps entries in memory and forgets them when the app exits.
class MemoryHistoryStore implements HistoryStore {
  MemoryHistoryStore({int limit = defaultLimit}) : _limit = limit;

  /// How many entries a store keeps before the oldest is dropped.
  static const int defaultLimit = 100;

  final int _limit;
  final List<HistoryEntry> _entries = <HistoryEntry>[];

  @override
  Future<List<HistoryEntry>> read() async =>
      List<HistoryEntry>.unmodifiable(_entries);

  @override
  Future<void> record(HistoryEntry entry) async {
    _entries.removeWhere((HistoryEntry existing) => existing.id == entry.id);
    _entries.insert(0, entry);
    if (_entries.length > _limit) {
      _entries.removeRange(_limit, _entries.length);
    }
  }

  @override
  Future<void> remove(int id) async {
    _entries.removeWhere((HistoryEntry entry) => entry.id == id);
  }

  @override
  Future<void> clear() async => _entries.clear();
}

/// A store that keeps one entry per line in a file.
///
/// A file survives a reboot, which is what a launcher needs: the record of what
/// was open before is the point of keeping it at all. One entry per line keeps a
/// partial write from taking the whole record with it.
class FileHistoryStore implements HistoryStore {
  FileHistoryStore(this.directory, {this.fileName = 'history.jsonl', int? limit})
      : _limit = limit ?? MemoryHistoryStore.defaultLimit;

  /// Directory the host makes available for the launcher's own data.
  final String directory;
  final String fileName;
  final int _limit;

  File? _cached;

  Future<File> _file() async {
    final File? cached = _cached;
    if (cached != null) {
      return cached;
    }
    final Directory dir = Directory(directory);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return _cached = File('${dir.path}${Platform.pathSeparator}$fileName');
  }

  @override
  Future<List<HistoryEntry>> read() async {
    try {
      final File file = await _file();
      if (!file.existsSync()) {
        return <HistoryEntry>[];
      }
      final List<String> lines = await file.readAsLines();
      return <HistoryEntry>[
        for (final String line in lines)
          if (HistoryEntry.fromLine(line) case final HistoryEntry entry) entry,
      ];
    } on Object {
      // An unreadable record is treated as an empty one rather than an error:
      // losing the history is bad, failing to start is worse.
      return <HistoryEntry>[];
    }
  }

  @override
  Future<void> record(HistoryEntry entry) async {
    // read() may hand back an immutable list, so the caller edits a copy.
    final List<HistoryEntry> entries = List<HistoryEntry>.of(await read());
    entries.removeWhere((HistoryEntry existing) => existing.id == entry.id);
    entries.insert(0, entry);
    await _write(entries);
  }

  @override
  Future<void> remove(int id) async {
    final List<HistoryEntry> entries = List<HistoryEntry>.of(await read());
    entries.removeWhere((HistoryEntry entry) => entry.id == id);
    await _write(entries);
  }

  @override
  Future<void> clear() => _write(<HistoryEntry>[]);

  Future<void> _write(List<HistoryEntry> entries) async {
    final File file = await _file();
    final Iterable<HistoryEntry> kept = entries.length > _limit
        ? entries.take(_limit)
        : entries;
    await file.writeAsString(
      kept.map((HistoryEntry entry) => '${entry.toLine()}\n').join(),
      flush: true,
    );
  }
}

/// Keeps the record in a file when the host offers a directory for it.
///
/// Called once at start-up. A host that names no directory, or one the launcher
/// cannot write, leaves the in-memory store in place, so the launcher runs the
/// same way either way and only the persistence differs.
Future<void> installHistoryStore() async {
  final String directory = await PlatformBridge.instance.storageDirectory();
  if (directory.isEmpty) {
    return;
  }
  try {
    final Directory target = Directory(directory);
    if (!target.existsSync()) {
      target.createSync(recursive: true);
    }
    HistoryStore.install(FileHistoryStore(directory));
  } on FileSystemException {
    // Not writable: the in-memory store stays.
  }
}
