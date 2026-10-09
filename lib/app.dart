import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'model/local/platform_bridge.dart';
import 'model/recent/history_store.dart';
import 'util/app_theme.dart';
import 'util/constant.dart';
import 'util/display_mode.dart';
import 'util/focus_style.dart';
import 'util/screen_util.dart';
import 'util/scroll_behavior.dart';
import 'util/translations.dart';
import 'view/app/page_app.dart';
import 'view/home/page_home.dart';
import 'view/recent/page_recent.dart';
import 'view/main/page_main.dart';
import 'view/tv/page_tv.dart';
import 'view/video/page_video.dart';
import 'view/widget/title_widget.dart';
import 'view/widget/top_bar_clock.dart';
import 'view/widget/topbar_widget.dart';
import 'viewmodel/base/view_model.dart';
import 'viewmodel/main/main_view_model.dart';

/// The launcher application a deployment runs.
///
/// It owns the television posture as well as the widget tree: the platform's own
/// bars are kept out of the way and the orientation is held to landscape before
/// the first frame, so the launcher never appears half-dressed on a television.
class TvLauncherApp extends StatefulWidget {
  const TvLauncherApp({super.key});

  @override
  State<TvLauncherApp> createState() => _TvLauncherAppState();
}

class _TvLauncherAppState extends State<TvLauncherApp> {
  @override
  void initState() {
    super.initState();
    unawaited(applyTvDisplayMode());
    unawaited(installHistoryStore());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Launcher',
      debugShowCheckedModeBanner: false,
      theme: buildLauncherTheme(),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        Translations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: PlatformBridge.instance.supportedLocales(),
      scrollBehavior: const TvScrollBehavior(),
      home: ViewModelProvider<MainViewModel>(
        viewModel: MainViewModel(),
        child: const LauncherShell(),
      ),
    );
  }
}

/// The launcher's three-band skeleton: status bar, tab titles, content.
///
/// Focus scheduling between the bands is owned entirely by [LaunchMainPage].
class LauncherShell extends StatefulWidget {
  const LauncherShell({super.key});

  @override
  State<LauncherShell> createState() => _LauncherShellState();
}

class _LauncherShellState extends State<LauncherShell> {
  /// Switch to change how the focused block is highlighted across the whole app.
  static const FocusHighlightStyle _highlightStyle = FocusHighlightStyle.both;

  static const List<String> _tabs = <String>[
    kTabRecent,
    kTabHome,
    kTabMovies,
    kTabTv,
    kTabApps,
  ];

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screen = ScreenUtil.of(context);
    final MainViewModel mainViewModel =
        ViewModelProvider.of<MainViewModel>(context);

    final List<Widget> titles = <Widget>[
      for (final String tab in _tabs)
        TitleWidget(key: ValueKey<String>('title_$tab'), title: tab),
    ];
    return Scaffold(
      body: LaunchMainPage(
        tabCount: _tabs.length,
        highlightStyle: _highlightStyle,
        onExit: mainViewModel.leave,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(kBackgroundAsset),
            ),
          ),
          child: Column(
            children: <Widget>[
              _buildStatusBar(context, screen),
              _buildTitleBar(screen, titles),
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: mainViewModel.pageIndex,
                  builder: (BuildContext context, int index, Widget? child) {
                    return IndexedStack(
                      index: index,
                      children: <Widget>[
                        PageRecent(
                          highlightStyle: _highlightStyle,
                          active: index == 0,
                        ),
                        PageHome(highlightStyle: _highlightStyle),
                        PageVideo(highlightStyle: _highlightStyle),
                        PageTv(highlightStyle: _highlightStyle),
                        PageApps(highlightStyle: _highlightStyle),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context, ScreenUtil screen) {
    final MainViewModel mainViewModel =
        ViewModelProvider.of<MainViewModel>(context);

    return SizedBox(
      height: screen.h(60.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TopBarWidget(
            icon: Icons.input,
            label: Translations.of(context).text('source'),
            onSelect: () => mainViewModel.openSurface(kActionInputSource),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screen.w(10.0)),
            child: TopBarWidget(
              icon: Icons.wifi,
              label: Translations.of(context).text('wifi'),
              onSelect: () => mainViewModel.openSurface(kActionNetwork),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: screen.w(10.0), right: screen.w(20.0)),
            child: TopBarClock(fontSize: screen.sp(32.0)),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBar(ScreenUtil screen, List<Widget> titles) {
    return Container(
      width: double.infinity,
      height: screen.h(120.0),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: screen.w(20.0)),
      child: Row(children: titles),
    );
  }
}
