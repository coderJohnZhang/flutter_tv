import 'package:flutter/material.dart';
import 'dart:ui' show window;
import 'page0.dart';
import 'page1.dart';
import 'page2.dart';
import 'page3.dart';

class _Page {
  _Page({
    this.icon,
    this.text,
    this.widget,
  });

  final IconData icon;
  final String text;
  final Widget widget;
}

class PosterDemo extends StatefulWidget {
  @override
  _PosterDemoState createState() => new _PosterDemoState();
}

class _PosterDemoState extends State<PosterDemo> with TickerProviderStateMixin {
  TabController _tabController;
  List<_Page> _allPages;
  Animation<RelativeRect> rectAnimation;
  AnimationController focusController;
  RelativeRect rect;
  final Size screenSize = window.physicalSize / window.devicePixelRatio;

  @override
  void initState() {
    print('initState() screenSize = $screenSize');
    super.initState();
    _allPages = <_Page>[
      new _Page(
          icon: Icons.event,
          text: 'EVENT',
          widget: new Page0Widget(
            screenSize: screenSize,
            onFocusLeft: (GlobalKey key, Size size) {
              print('page0 onFocusLeft key = $key size = $size');
              if (key == null && size == null) {
                previousPage();
              } else {
                _doFocusAnimation(key, size);
              }
            },
            onFocusRight: (GlobalKey key, Size size) {
              print('page0 onFocusRight key = $key size = $size');
              if (key == null && size == null) {
                nextPage();
                Offset offset = new Offset(0.0, screenSize.height / 4);
                Size size = new Size(screenSize.width * 2 / 3 - 10.0,
                    screenSize.height * 3 / 8 - 10.0);
                initialFocusAnimation(offset, size);
              } else {
                _doFocusAnimation(key, size);
              }
            },
            onFocusUp: (GlobalKey key, Size size) {
              print('page0 onFocusUp key = $key size = $size');
              if (key == null && size == null) {} else {
                _doFocusAnimation(key, size);
              }
            },
            onFocusDown: (GlobalKey key, Size size) {
              print('page0 onFocusDown key = $key size = $size');
              if (key == null && size == null) {} else {
                _doFocusAnimation(key, size);
              }
            },
          )),
      new _Page(
          icon: Icons.home,
          text: 'HOME',
          widget: new Page1Widget(
            screenSize: screenSize,
            onFocusLeft: (GlobalKey key, Size size) {
              print('page1 onFocusLeft key = $key size = $size');
              if (key == null && size == null) {
                previousPage();
                Offset offset = new Offset(0.0, screenSize.height / 4);
                Size size = new Size(screenSize.width / 3 - 10.0,
                    screenSize.height * 3 / 8 - 10.0);
                initialFocusAnimation(offset, size);
              } else {
                _doFocusAnimation(key, size);
              }
            },
            onFocusRight: (GlobalKey key, Size size) {
              print('page1 onFocusRight key = $key size = $size');
              if (key == null && size == null) {
                nextPage();
                Offset offset = new Offset(0.0, screenSize.height / 4);
                Size size = new Size(screenSize.width / 3 - 10.0,
                    screenSize.height * 3 / 4 - 10.0);
                initialFocusAnimation(offset, size);
              } else {
                _doFocusAnimation(key, size);
              }
            },
            onFocusUp: (GlobalKey key, Size size) {
              print('page1 onFocusUp key = $key size = $size');
              if (key == null && size == null) {} else {
                _doFocusAnimation(key, size);
              }
            },
            onFocusDown: (GlobalKey key, Size size) {
              print('page1 onFocusDown key = $key size = $size');
              if (key == null && size == null) {} else {
                _doFocusAnimation(key, size);
              }
            },
          )),
      new _Page(
          icon: Icons.airplay,
          text: 'AIRPLAY',
          widget: new Page2Widget(
            screenSize: screenSize,
            onFocusLeft: (GlobalKey key, Size size) {
              print('page2 onFocusLeft key = $key size = $size');
              if (key == null && size == null) {
                previousPage();
                Offset offset = new Offset(0.0, screenSize.height / 4);
                Size size = new Size(screenSize.width * 2 / 3 - 10.0,
                    screenSize.height * 3 / 8 - 10.0);
                initialFocusAnimation(offset, size);
              } else {
                _doFocusAnimation(key, size);
              }
            },
            onFocusRight: (GlobalKey key, Size size) {
              print('page2 onFocusRight key = $key size = $size');
              if (key == null && size == null) {
                nextPage();
                Offset offset = new Offset(0.0, screenSize.height / 4);
                Size size = new Size(screenSize.width / 3 - 10.0,
                    screenSize.height * 3 / 4 - 10.0);
                initialFocusAnimation(offset, size);
              } else {
                _doFocusAnimation(key, size);
              }
            },
            onFocusUp: (GlobalKey key, Size size) {
              print('page2 onFocusUp key = $key size = $size');
              if (key == null && size == null) {} else {
                _doFocusAnimation(key, size);
              }
            },
            onFocusDown: (GlobalKey key, Size size) {
              print('page2 onFocusDown key = $key size = $size');
              if (key == null && size == null) {} else {
                _doFocusAnimation(key, size);
              }
            },
          )),
      new _Page(
          icon: Icons.language,
          text: 'LANGUAGE',
          widget: new Page3Widget(
            screenSize: screenSize,
            onFocusLeft: (GlobalKey key, Size size) {
              print('page3 onFocusLeft key = $key size = $size');
              if (key == null && size == null) {
                previousPage();
                Offset offset = new Offset(0.0, screenSize.height / 4);
                Size size = new Size(screenSize.width / 3 - 10.0,
                    screenSize.height * 3 / 4 - 10.0);
                initialFocusAnimation(offset, size);
              } else {
                _doFocusAnimation(key, size);
              }
            },
            onFocusRight: (GlobalKey key, Size size) {
              print('page3 onFocusRight key = $key size = $size');
              if (key == null && size == null) {
                nextPage();
              } else {
                _doFocusAnimation(key, size);
              }
            },
            onFocusUp: (GlobalKey key, Size size) {
              print('page3 onFocusUp key = $key size = $size');
              if (key == null && size == null) {} else {
                _doFocusAnimation(key, size);
              }
            },
            onFocusDown: (GlobalKey key, Size size) {
              print('page3 onFocusDown key = $key size = $size');
              if (key == null && size == null) {} else {
                _doFocusAnimation(key, size);
              }
            },
          ))
    ];

    _tabController = new TabController(vsync: this, length: _allPages.length);

    focusController = new AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    focusController.addListener(handleAnimation);
    Offset initOffset = new Offset(0.0, screenSize.height / 4);
    Size size =
        new Size(screenSize.width / 3 - 10.0, screenSize.height * 3 / 8 - 10.0);
    initialFocusAnimation(initOffset, size);
  }

  void handleAnimation() {
    setState(() {
      rect = rectAnimation.value;
    });
  }

  void previousPage() {
    if (_tabController.index > 0) {
      _tabController.index--;
    }
    _tabController.animateTo(_tabController.index,
        duration: kTabScrollDuration, curve: Curves.ease);
    print("current index = " + _tabController.index.toString());
  }

  void nextPage() {
    if (_tabController.index < _allPages.length - 1) {
      _tabController.index++;
    }
    _tabController.animateTo(_tabController.index,
        duration: kTabScrollDuration, curve: Curves.ease);
    print("current index = " + _tabController.index.toString());
  }

  void _doFocusAnimation(GlobalKey key, Size newSize) {
    print('_doFocusAnimation()');
    final RenderBox objRenderBox = key.currentContext.findRenderObject();
    final Offset objCoordinates =
        objRenderBox.localToGlobal(Offset.zero); //目标控件的屏幕绝对坐标
    print('_doFocusAnimation objCoordinates = $objCoordinates');
    double left = objCoordinates.dx;
    double top = objCoordinates.dy - screenSize.height / 4;
    double right = screenSize.width - objCoordinates.dx - newSize.width - 10.0;
    double bottom =
        screenSize.height - objCoordinates.dy - newSize.height - 10.0;
    RelativeRect newRect = new RelativeRect.fromLTRB(left, top, right, bottom);
    print("_doFocusAnimation rect = " +
        rect.toString() +
        " newRect = " +
        newRect.toString());
    rectAnimation = new RelativeRectTween(begin: rect, end: newRect)
        .animate(focusController);
    focusController.forward();
    focusController
      ..value = 0.0
      ..fling();
  }

  void initialFocusAnimation(Offset initOffset, Size size) {
    print('initialFocusAnimation()');
    rect = new RelativeRect.fromLTRB(
      initOffset.dx,
      initOffset.dy - screenSize.height / 4,
      screenSize.width - initOffset.dx - size.width - 10.0,
      screenSize.height - initOffset.dy - size.height - 10.0,
    );
    print("initialFocusAnimation() rect = " + rect.toString());
    rectAnimation =
        new RelativeRectTween(begin: rect, end: rect.shift(Offset.zero))
            .animate(focusController);
    focusController.forward();
    focusController
      ..value = 0.0
      ..fling();
  }

  // 释放对象使用的资源
  @override
  void dispose() {
    _tabController.dispose();
    focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          backgroundColor: Colors.black,
          bottom: new TabBar(
            indicatorColor: const Color(0x00000000),
            labelColor: Colors.green,
            labelStyle: new TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: 'serif',
            ),
            unselectedLabelColor: Colors.white,
            // 控件的选择和动画状态
            controller: _tabController,
            // 标签栏是否可以水平滚动
            isScrollable: true,
            // 标签控件的列表
            tabs: _allPages.map((_Page page) {
              return new Tab(text: page.text, icon: new Icon(page.icon));
            }).toList(),
          )),
      body: buildContent(),
    );
  }

  Stack buildContent() {
    var focusBox = new PositionedTransition(
        rect: rectAnimation,
        child: new Image.asset(
          'images/launcher/move_focus.png',
          fit: BoxFit.fill,
        ));
    var content = new TabBarView(
      // 控件的选择和动画状态
      controller: _tabController,
      // 每个标签一个控件
      children: _allPages.map((_Page page) {
        return new Container(key: new ObjectKey(page.icon), child: page.widget);
      }).toList(),
    );
    return new Stack(children: <Widget>[content, focusBox]);
  }
}
