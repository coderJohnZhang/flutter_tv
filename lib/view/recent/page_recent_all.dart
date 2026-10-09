import 'package:flutter/material.dart';

import '../../model/common/poster.dart';
import '../../model/recent/history_entry.dart';
import '../../model/recent/recent_model.dart';
import '../../util/focus_style.dart';
import '../../util/screen_util.dart';
import '../../util/translations.dart';
import '../../viewmodel/recent/recent_view_model.dart';
import '../widget/focus_block_widget.dart';
import 'recent_tile.dart';

/// Everything the viewer has opened, grouped by day and editable.
///
/// The recent tab shows a glance at the history; this is the full record behind
/// it. It is where entries are actually removed, because removal is a deliberate
/// act: the tab asks first, marks what would go, and only then forgets it — a
/// remote has no undo.
class PageRecentAll extends StatefulWidget {
  const PageRecentAll({
    super.key,
    required this.highlightStyle,
    required this.viewModel,
    required this.onBack,
  });

  final FocusHighlightStyle highlightStyle;
  final RecentViewModel viewModel;

  /// Returns to the summary the tab shows first.
  final VoidCallback onBack;

  @override
  State<PageRecentAll> createState() => PageRecentAllState();
}

class PageRecentAllState extends State<PageRecentAll> {
  /// How wide one tile is, in design units. Matches the tab's own rows.
  static const double _tileWidth = 320.0;

  /// How tall one tile is, in design units.
  static const double _tileHeight = 180.0;

  List<HistoryEntry> _entries = const <HistoryEntry>[];
  Map<String, List<HistoryEntry>> _groups = const <String, List<HistoryEntry>>{};
  final Set<int> _marked = <int>{};
  bool _deleteMode = false;
  bool _loaded = false;

  int get markedCount => _marked.length;
  bool get deleteMode => _deleteMode;

  @override
  void initState() {
    super.initState();
    reload();
  }

  /// Reads the history again.
  Future<void> reload() async {
    final List<HistoryEntry> entries = await widget.viewModel.all();
    if (!mounted) {
      return;
    }
    setState(() {
      _loaded = true;
      _entries = entries;
      _groups = RecentModel().groupByDay(entries);
      _marked.removeWhere(
        (int id) => !entries.any((HistoryEntry entry) => entry.id == id),
      );
      if (_entries.isEmpty) {
        _deleteMode = false;
      }
    });
  }

  /// Enters delete mode, or leaves it and forgets everything that was marked.
  Future<void> toggleDeleteMode() async {
    if (!_deleteMode) {
      setState(() => _deleteMode = true);
      return;
    }
    for (final int id in _marked.toList()) {
      await widget.viewModel.forget(id);
    }
    await reload();
    if (mounted) {
      setState(() {
        _deleteMode = false;
        _marked.clear();
      });
    }
  }

  /// Marks an entry, or opens it when the tab is not editing.
  Future<void> _activate(BuildContext context, HistoryEntry entry) async {
    if (_deleteMode) {
      setState(() {
        if (!_marked.remove(entry.id)) {
          _marked.add(entry.id);
        }
      });
      return;
    }
    if (entry.target.isEmpty) {
      return;
    }
    // Opening an entry is the deployment's to resolve; the tab only asks.
    if (context.mounted) {
      widget.onBack();
    }
  }

  String _caption(String group) {
    final Translations translations = Translations.of(context);
    return group == RecentModel.groupToday
        ? translations.text('recent_today')
        : translations.text('recent_earlier');
  }

  static Poster _poster(HistoryEntry entry) => Poster(
        blockId: entry.id,
        title: entry.title,
        imageUrl: entry.imageUrl,
      );

  @override
  Widget build(BuildContext context) {
    final Translations translations = Translations.of(context);
    final ScreenUtil screen = ScreenUtil.of(context);

    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildHeader(context, translations, screen),
        Expanded(
          child: _entries.isEmpty
              ? Center(
                  child: Text(
                    translations.text('recent_empty'),
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: screen.sp(28.0),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screen.w(60.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (final MapEntry<String, List<HistoryEntry>> group
                          in _groups.entries) ...<Widget>[
                        _buildGroupHeading(screen, _caption(group.key)),
                        _buildGroup(screen, group.value),
                      ],
                      SizedBox(height: screen.h(24.0)),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Translations translations,
    ScreenUtil screen,
  ) {
    final String label = !_deleteMode
        ? translations.text('recent_delete')
        : markedCount == 0
            ? translations.text('recent_delete_cancel')
            : translations.text('recent_delete_confirm');

    return Padding(
      padding: EdgeInsets.only(left: screen.w(60.0), top: screen.h(8.0)),
      child: Row(
        children: <Widget>[
          _buildAction(screen, translations.text('recent_back'), widget.onBack),
          SizedBox(width: screen.w(16.0)),
          _buildAction(screen, label, toggleDeleteMode),
        ],
      ),
    );
  }

  Widget _buildAction(ScreenUtil screen, String label, VoidCallback onSelect) {
    return SizedBox(
      width: screen.w(240.0),
      child: FocusBlockWidget(
        key: ValueKey<String>('recent_action_$label'),
        highlightStyle: widget.highlightStyle,
        onSelect: onSelect,
        child: Padding(
          padding: EdgeInsets.all(screen.w(12.0)),
          child: Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: screen.sp(22.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHeading(ScreenUtil screen, String title) {
    return Padding(
      padding: EdgeInsets.only(top: screen.h(24.0), bottom: screen.h(8.0)),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white70,
          fontSize: screen.sp(28.0),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGroup(ScreenUtil screen, List<HistoryEntry> entries) {
    return Wrap(
      spacing: screen.w(24.0),
      runSpacing: screen.h(24.0),
      children: <Widget>[
        for (final HistoryEntry entry in entries)
          SizedBox(
            width: screen.w(_tileWidth),
            height: screen.h(_tileHeight),
            child: RecentTile(
              key: ValueKey<String>('recent_${entry.id}'),
              poster: _poster(entry),
              highlightStyle: widget.highlightStyle,
              marked: _marked.contains(entry.id),
              deleteMode: _deleteMode,
              onSelect: () => _activate(context, entry),
            ),
          ),
      ],
    );
  }
}
