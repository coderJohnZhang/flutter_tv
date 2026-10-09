import 'package:flutter/material.dart';

import '../../model/common/poster.dart';
import '../../model/home/home_layout.dart';
import '../../model/video/video_catalog.dart';
import '../../util/focus_style.dart';
import '../../util/screen_util.dart';
import '../../util/translations.dart';
import '../../viewmodel/video/video_view_model.dart';
import '../widget/content_row.dart';
import '../widget/launcher_tab_page.dart';

/// Video tab: a set of titled rows of titles, the shape a viewer browses when
/// they are looking for something to watch rather than something to open.
///
/// The rows come from the video catalog, so the tab changes with the deployment
/// rather than with the code, and the tab reuses the row widget the home tab
/// uses so both scroll and take focus the same way.
class PageVideo extends StatefulWidget implements LauncherTabPage {
  const PageVideo({super.key, required this.highlightStyle});

  final FocusHighlightStyle highlightStyle;

  @override
  State<PageVideo> createState() => PageVideoState();
}

class PageVideoState extends State<PageVideo> {
  /// Row metrics for the video tab. It draws a catalog rather than the home
  /// layout, so it carries its own, apart from the tile size, which the
  /// catalog owns because it decides whether the artwork is landscape.
  static const double _leadingInset = 60.0;
  static const double _gapX = 24.0;
  static const double _headingHeight = 56.0;
  static const double _rowGap = 24.0;

  HomeLayout _layout = const HomeLayout(
    featured: null,
    rows: <HomeRow>[],
    leadingInset: _leadingInset,
    gapX: _gapX,
    headingHeight: _headingHeight,
    rowGap: _rowGap,
  );

  final VideoViewModel _viewModel = VideoViewModel();

  List<HomeRow> _rows = const <HomeRow>[];
  List<ScrollController> _controllers = const <ScrollController>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final ScrollController controller in _controllers) {
      controller.dispose();
    }
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final VideoCatalog catalog = await _viewModel.catalog();
    final List<HomeRow> rows = catalog.rows;
    if (!mounted) {
      return;
    }
    setState(() {
      _rows = rows;
      _layout = HomeLayout(
        featured: null,
        rows: <HomeRow>[],
        leadingInset: _leadingInset,
        tileWidth: catalog.tileWidth,
        tileHeight: catalog.tileHeight,
        gapX: _gapX,
        headingHeight: _headingHeight,
        rowGap: _rowGap,
      );
      for (final ScrollController controller in _controllers) {
        controller.dispose();
      }
      _controllers = List<ScrollController>.generate(
        rows.length,
        (_) => ScrollController(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screen = ScreenUtil.of(context);

    if (_rows.isEmpty) {
      return Center(
        child: Text(
          Translations.of(context).text('video_empty'),
          style: TextStyle(color: Colors.white54, fontSize: screen.sp(28.0)),
        ),
      );
    }

    return SingleChildScrollView(
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
              onSelect: (Poster poster) => _viewModel.launch(poster),
            ),
            SizedBox(height: screen.h(_rowGap)),
          ],
        ],
      ),
    );
  }
}
