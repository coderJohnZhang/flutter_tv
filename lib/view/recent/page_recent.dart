import 'package:flutter/material.dart';

import '../../model/common/poster.dart';
import '../../model/home/home_layout.dart';
import '../../model/recent/history_entry.dart';
import '../../model/recent/recent_model.dart';
import '../../util/focus_style.dart';
import '../../util/screen_util.dart';
import '../../util/translations.dart';
import '../../viewmodel/recent/recent_view_model.dart';
import '../widget/content_row.dart';
import '../widget/focus_block_widget.dart';
import '../widget/launcher_tab_page.dart';
import 'page_recent_all.dart';

/// The recent tab: what the viewer opened, grouped into today and earlier.
///
/// The page is a view over the launcher's history, so it is built from the same
/// rows the home tab uses. Groups the store left empty are not drawn, and a
/// viewer with no history gets a message rather than an empty grid — which is
/// what a launcher has to show the very first time it runs.
class PageRecent extends StatefulWidget implements LauncherTabPage {
  const PageRecent({
    super.key,
    required this.highlightStyle,
    this.active = true,
  });

  final FocusHighlightStyle highlightStyle;

  /// True while this is the tab on screen.
  ///
  /// The other tabs write to the same record, so this one is only current as
  /// of the last time it was shown.
  final bool active;

  @override
  State<PageRecent> createState() => PageRecentState();
}

class PageRecentState extends State<PageRecent> {
  /// True while the full record is on screen rather than the glance at it.
  bool _showAll = false;

  /// Row metrics used by the recent rows. The home tab's config does not apply
  /// here, because the recent tab draws a record rather than a layout.
  static const double _leadingInset = 60.0;
  static const double _tileWidth = 320.0;
  static const double _tileHeight = 180.0;
  static const double _gapX = 24.0;
  static const double _headingHeight = 56.0;
  static const double _rowGap = 24.0;

  final RecentViewModel _viewModel = RecentViewModel();

  List<HomeRow> _rows = const <HomeRow>[];
  Map<int, HistoryEntry> _entries = const <int, HistoryEntry>{};
  List<ScrollController> _controllers = const <ScrollController>[];
  bool _loaded = false;

  HomeLayout get _layout => const HomeLayout(
        featured: null,
        rows: <HomeRow>[],
        leadingInset: _leadingInset,
        tileWidth: _tileWidth,
        tileHeight: _tileHeight,
        gapX: _gapX,
        headingHeight: _headingHeight,
        rowGap: _rowGap,
      );

  bool get isEmpty => _loaded && _rows.isEmpty;

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void didUpdateWidget(PageRecent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Coming back into view is when the record may have grown.
    if (widget.active && !oldWidget.active) {
      reload();
    }
  }

  @override
  void dispose() {
    for (final ScrollController controller in _controllers) {
      controller.dispose();
    }
    _viewModel.dispose();
    super.dispose();
  }

  /// Shows the full record.
  void _openAll() => setState(() => _showAll = true);

  /// Returns from the full record, which may have removed entries.
  Future<void> _closeAll() async {
    setState(() => _showAll = false);
    await reload();
  }

  /// Reads the history again, as the tab does when it comes back into view.
  Future<void> reload() async {
    final Map<String, List<HistoryEntry>> byDay =
        await _viewModel.grouped(HistoryEntry.kindTitle);
    if (!mounted) {
      return;
    }
    final List<HomeRow> rows = <HomeRow>[
      for (final MapEntry<String, List<HistoryEntry>> group in byDay.entries)
        HomeRow(
          title: _caption(group.key),
          items: group.value.map(_poster).toList(growable: false),
        ),
    ];
    setState(() {
      _loaded = true;
      _rows = rows;
      _entries = <int, HistoryEntry>{
        for (final List<HistoryEntry> group in byDay.values)
          for (final HistoryEntry entry in group) entry.id: entry,
      };
      for (final ScrollController controller in _controllers) {
        controller.dispose();
      }
      _controllers = List<ScrollController>.generate(
        rows.length,
        (_) => ScrollController(),
      );
    });
  }

  /// Opens the entry behind a tile again.
  ///
  /// A tile only carries what it draws, so the entry it stands for is the one
  /// recorded under the same identifier.
  Future<void> _open(int id) async {
    final HistoryEntry? entry = _entries[id];
    if (entry != null) {
      await _viewModel.reopen(entry);
    }
  }

  /// Forgets the whole record, then shows what is left of it.
  Future<void> clear() async {
    await _viewModel.clear();
    await reload();
  }

  /// One focusable action in the tab's header.
  Widget _buildAction(ScreenUtil screen, String label, VoidCallback onSelect) {
    return FocusBlockWidget(
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
    );
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
    if (_showAll) {
      return PageRecentAll(
        highlightStyle: widget.highlightStyle,
        viewModel: _viewModel,
        onBack: _closeAll,
      );
    }
    if (_rows.isEmpty) {
      return Center(
        child: Text(
          translations.text('recent_empty'),
          style: TextStyle(color: Colors.white54, fontSize: screen.sp(28.0)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: screen.w(_leadingInset),
            top: screen.h(8.0),
          ),
          child: SizedBox(
            width: screen.w(_tileWidth),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildAction(
                    screen,
                    translations.text('recent_view_all'),
                    _openAll,
                  ),
                ),
                SizedBox(width: screen.w(12.0)),
                Expanded(
                  child: _buildAction(
                    screen,
                    translations.text('recent_clear'),
                    clear,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: screen.h(_rowGap)),
                for (int i = 0; i < _rows.length; i++) ...<Widget>[
                  ContentRow(
                    row: _rows[i],
                    rowIndex: i,
                    layout: _layout,
                    controller: _controllers[i],
                    highlightStyle: widget.highlightStyle,
                    onSelect: (Poster poster) => _open(poster.blockId),
                  ),
                  SizedBox(height: screen.h(_rowGap)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
