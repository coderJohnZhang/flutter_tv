import 'package:flutter/material.dart';

import '../../model/common/poster.dart';
import '../../model/home/home_layout.dart';
import '../../model/tv/tv_catalog.dart';
import '../../util/focus_style.dart';
import '../../util/screen_util.dart';
import '../../util/translations.dart';
import '../../viewmodel/tv/tv_view_model.dart';
import '../widget/content_row.dart';
import '../widget/featured_banner.dart';
import '../widget/launcher_tab_page.dart';

/// TV tab: the tuner — what the set is on, above the channels it can switch to.
///
/// The channel list comes from the bundled catalog and the caption on the hero
/// comes from the platform when one answers, so the tab reflects the set it is
/// installed on without the widget knowing what a tuner is. With no platform it
/// renders from the catalog alone, which is what makes a desktop a usable way to
/// work on it.
class PageTv extends StatefulWidget implements LauncherTabPage {
  const PageTv({super.key, required this.highlightStyle});

  final FocusHighlightStyle highlightStyle;

  @override
  State<PageTv> createState() => PageTvState();
}

class PageTvState extends State<PageTv> {
  /// Metrics for the channel row. The tab draws a catalog rather than the home
  /// layout, so it carries its own.
  static const double _leadingInset = 60.0;
  static const double _tileWidth = 341.0;
  static const double _tileHeight = 180.0;
  static const double _gapX = 24.0;
  static const double _headingHeight = 56.0;
  static const double _rowGap = 24.0;
  static const double _heroHeight = 320.0;

  static const HomeLayout _layout = HomeLayout(
    featured: null,
    rows: <HomeRow>[],
    leadingInset: _leadingInset,
    tileWidth: _tileWidth,
    tileHeight: _tileHeight,
    gapX: _gapX,
    headingHeight: _headingHeight,
    rowGap: _rowGap,
  );

  final TvViewModel _viewModel = TvViewModel();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _rowController = ScrollController();

  TvState? _state;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _rowController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final TvState state = await _viewModel.load();
    if (!mounted) {
      return;
    }
    setState(() => _state = state);
  }

  @override
  Widget build(BuildContext context) {
    final TvState? state = _state;
    if (state == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final ScreenUtil screen = ScreenUtil.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FeaturedBanner(
          poster: _hero(context, state),
          highlightStyle: widget.highlightStyle,
          leadingInset: _leadingInset,
          height: screen.h(_heroHeight),
          artworkWidth: 160.0,
          artworkSize: const Size(160.0, 118.0),
          artworkIcon: Icons.live_tv,
          onSelect: () =>
              _tune(state, state.channels.isEmpty ? null : state.channels.first),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _verticalController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: screen.h(_rowGap)),
                if (state.channels.isNotEmpty)
                  ContentRow(
                    row: HomeRow(title: state.heading, items: state.channels),
                    rowIndex: 0,
                    layout: _layout,
                    controller: _rowController,
                    highlightStyle: widget.highlightStyle,
                    onSelect: (Poster poster) => _tune(state, poster),
                  ),
                SizedBox(height: screen.h(_rowGap)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// The channel on screen, captioned with the input it is on.
  ///
  /// A tuner reports a name rather than a picture, so the artwork comes from
  /// the catalog. When the platform reports no signal the caption says so
  /// instead of naming an input that is not carrying anything, and when no
  /// channel is named at all the hero falls back to the input, which is the one
  /// thing certainly true about the set.
  Poster _hero(BuildContext context, TvState state) {
    final bool named = state.channelName.isNotEmpty;
    return Poster(
      title: named ? state.channelName : state.input,
      subtitle: state.live && !state.hasSignal
          ? Translations.of(context).text('tv_no_signal')
          : (named ? state.input : ''),
      imageUrl: state.heroImage,
    );
  }

  Future<void> _tune(TvState state, Poster? poster) async {
    if (poster == null) {
      return;
    }
    final TvCatalog catalog = await _viewModel.catalog();
    await _viewModel.tune(poster, action: catalog.actionFor(poster.blockId));
  }
}
