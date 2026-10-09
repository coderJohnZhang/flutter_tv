import 'package:flutter/material.dart';

import '../../model/common/poster.dart';
import '../../model/layout/layout_home_mapper.dart';
import '../../util/focus_style.dart';
import '../../util/screen_util.dart';
import '../../viewmodel/home/home_view_model.dart';
import '../widget/content_row.dart';
import '../widget/featured_banner.dart';
import '../widget/launcher_tab_page.dart';

/// Home tab, laid out the way a modern TV launcher is: a featured banner over a
/// stack of horizontally scrolling rows.
///
/// The rows area scrolls vertically and each row scrolls horizontally, so both
/// axes of focus-driven scrolling are exercised. When the source has more rows
/// than fit, reaching the bottom of the vertical scroll pulls the next page in.
class PageHome extends StatefulWidget implements LauncherTabPage {
  const PageHome({super.key, required this.highlightStyle});

  final FocusHighlightStyle highlightStyle;

  @override
  State<PageHome> createState() => PageHomeState();
}

class PageHomeState extends State<PageHome> {
  /// Distance from the bottom of the rows area that triggers the next page.
  static const double _loadMoreThreshold = 480.0;

  final HomeViewModel _viewModel = HomeViewModel();
  final ScrollController _verticalController = ScrollController();

  /// One controller per row, so scrolling one row never moves the others.
  List<ScrollController> _rowControllers = const <ScrollController>[];

  MappedHome? _home;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _verticalController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _verticalController.removeListener(_onScroll);
    _verticalController.dispose();
    for (final ScrollController controller in _rowControllers) {
      controller.dispose();
    }
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final MappedHome home = await _viewModel.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _home = home;
      _syncControllers(home.layout.rows.length);
    });
  }

  void _onScroll() {
    if (_loadingMore || !_viewModel.canLoadMore) {
      return;
    }
    if (_verticalController.position.extentAfter > _loadMoreThreshold) {
      return;
    }
    _loadMore();
  }

  Future<void> _loadMore() async {
    final MappedHome? current = _home;
    if (current == null) {
      return;
    }
    setState(() => _loadingMore = true);
    final MappedHome? next = await _viewModel.loadMore(current);
    if (!mounted) {
      return;
    }
    setState(() {
      _loadingMore = false;
      if (next != null) {
        _home = next;
        _syncControllers(next.layout.rows.length);
      }
    });
  }

  /// Keeps one controller per row, reusing the ones already scrolling.
  ///
  /// A later page only adds rows, so the controllers that own a scroll position
  /// must survive it; replacing them all would jump every row back to its start.
  void _syncControllers(int rowCount) {
    if (_rowControllers.length > rowCount) {
      for (int i = rowCount; i < _rowControllers.length; i++) {
        _rowControllers[i].dispose();
      }
      _rowControllers = _rowControllers.sublist(0, rowCount);
      return;
    }
    if (_rowControllers.length == rowCount) {
      return;
    }
    _rowControllers = <ScrollController>[
      ..._rowControllers,
      for (int i = _rowControllers.length; i < rowCount; i++) ScrollController(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final MappedHome? home = _home;
    if (home == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final ScreenUtil screen = ScreenUtil.of(context);
    final Poster? featured = home.layout.featured;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (featured != null)
          FeaturedBanner(
            poster: featured,
            highlightStyle: widget.highlightStyle,
            leadingInset: home.layout.leadingInset,
            height: screen.h(360.0),
            onSelect: () =>
                _viewModel.launch(featured, action: home.actionFor(featured.blockId)),
          ),
        Expanded(
          child: SingleChildScrollView(
            controller: _verticalController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: screen.h(home.layout.rowGap)),
                for (int i = 0; i < home.layout.rows.length; i++) ...<Widget>[
                  ContentRow(
                    row: home.layout.rows[i],
                    rowIndex: i,
                    layout: home.layout,
                    controller: _rowControllers[i],
                    highlightStyle: widget.highlightStyle,
                    onSelect: (Poster poster) => _viewModel.launch(
                      poster,
                      action: home.actionFor(poster.blockId),
                    ),
                  ),
                  SizedBox(height: screen.h(home.layout.rowGap)),
                ],
                if (_loadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
