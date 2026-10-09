import 'package:flutter/material.dart';

import '../../model/app/app_catalog.dart';
import '../../util/constant.dart';
import '../../util/focus_style.dart';
import '../../util/screen_util.dart';
import '../../viewmodel/app/apps_view_model.dart';
import '../widget/focus_block_widget.dart';
import '../widget/launcher_tab_page.dart';
import '../widget/poster_tile.dart';

/// Apps tab: a grid of application shortcuts.
///
/// Which applications appear comes from the app catalog, not from the widget, so
/// a deployment changes its shortcuts without touching the layout code.
///
/// Every cell has the shape the bundled artwork is drawn in. A cell of any other
/// shape makes the tile zoom into its own picture until the gap is filled, which
/// is what a stretched logo looks like.
class PageApps extends StatefulWidget implements LauncherTabPage {
  const PageApps({super.key, required this.highlightStyle});

  final FocusHighlightStyle highlightStyle;

  @override
  State<PageApps> createState() => PageAppsState();
}

class PageAppsState extends State<PageApps> {
  /// Cells across, and the space between and around them.
  static const int _columns = 3;
  static const double _gap = 24.0;
  static const double _edgeInset = 60.0;

  final AppsViewModel _viewModel = AppsViewModel();

  List<AppEntry> _apps = const <AppEntry>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final AppCatalog catalog = await _viewModel.catalog();
    if (!mounted) {
      return;
    }
    setState(() => _apps = catalog.apps);
  }

  Widget _tile(BuildContext context, int index) {
    return FocusBlockWidget(
      key: ValueKey<String>('apps_$index'),
      highlightStyle: widget.highlightStyle,
      onSelect: () => _viewModel.launch(_apps[index]),
      child: PosterTile(
        poster: _apps[index].poster,
        fontSize: ScreenUtil.of(context).sp(18.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_apps.isEmpty) {
      return const SizedBox.shrink();
    }
    final ScreenUtil screen = ScreenUtil.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        screen.w(_edgeInset),
        screen.h(16.0),
        screen.w(_edgeInset),
        screen.h(16.0),
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _columns,
          mainAxisSpacing: screen.h(_gap),
          crossAxisSpacing: screen.w(_gap),
          childAspectRatio: kArtworkAspect,
        ),
        itemCount: _apps.length,
        itemBuilder: _tile,
      ),
    );
  }
}
