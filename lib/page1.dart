import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'poster.dart';
import 'key_code.dart';

class Page1Widget extends StatefulWidget {
  const Page1Widget({
    Key key,
    this.turnPage,
  })
      : super(key: key);
  final ValueChanged<int> turnPage;

  @override
  Page1WidgetState createState() => new Page1WidgetState();
}

class Page1WidgetState extends State<Page1Widget>
    with SingleTickerProviderStateMixin {
  static const double SCREEN_WIDTH = 1240.0;
  static const double SCREEN_HEIGHT = 530.0;
  static const double TAB_HEIGHT = 130.0;

  FocusNode focusNode;
  final FocusNode focusNode0 = new FocusNode();
  final FocusNode focusNode1 = new FocusNode();
  final FocusNode focusNode2 = new FocusNode();
  final FocusNode focusNode3 = new FocusNode();
  final FocusNode focusNode4 = new FocusNode();

  final GlobalKey globalKey0 = new GlobalKey();
  final GlobalKey globalKey1 = new GlobalKey();
  final GlobalKey globalKey2 = new GlobalKey();
  final GlobalKey globalKey3 = new GlobalKey();
  final GlobalKey globalKey4 = new GlobalKey();

  final GlobalKey focusBoxKey = new GlobalKey();
  Animation<RelativeRect> rectAnimation;
  AnimationController controller;
  RelativeRect rect;

  @override
  void initState() {
    super.initState();
    controller =
        new AnimationController(duration: kTabScrollDuration, vsync: this);
    controller.addListener(handleAnimation);
    Offset initOffset = const Offset(0.0, 130.0);
    rect = new RelativeRect.fromLTRB(
      initOffset.dx,
      initOffset.dy - TAB_HEIGHT,
      SCREEN_WIDTH - initOffset.dx - kPosters[0].width,
      SCREEN_HEIGHT - initOffset.dy - kPosters[0].height,
    );
    print("page1 initState() rect = " + rect.toString());
    rectAnimation =
        new RelativeRectTween(begin: rect, end: rect.shift(Offset.zero))
            .animate(controller);
    focusNode = focusNode0;
  }

  @override
  void dispose() {
    print('page1 dispose()');
    super.dispose();
    controller.dispose();
  }

  void handleAnimation() {
    setState(() {
      rect = rectAnimation.value;
    });
  }

  void _doFocusAnimation(GlobalKey key, Size newSize) {
    print('page1 _doFocusAnimation');
    final RenderBox objRenderBox = key.currentContext.findRenderObject();
    final Offset objCoordinates =
        objRenderBox.localToGlobal(Offset.zero); //目标控件的屏幕绝对坐标
    print('page1 _doFocusAnimation objCoordinates = $objCoordinates');
    double left = objCoordinates.dx;
    double top = objCoordinates.dy - TAB_HEIGHT;
    double right = SCREEN_WIDTH - objCoordinates.dx - newSize.width;
    double bottom = SCREEN_HEIGHT - objCoordinates.dy - newSize.height;
    RelativeRect newRect = new RelativeRect.fromLTRB(left, top, right, bottom);
    print("page1 _doFocusAnimation rect = " +
        rect.toString() +
        " newRect = " +
        newRect.toString());
    rectAnimation =
        new RelativeRectTween(begin: rect, end: newRect).animate(controller);
    controller.forward();
    controller
      ..value = 0.0
      ..fling();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode);
    var focusBox = new PositionedTransition(
        key: focusBoxKey,
        rect: rectAnimation,
        child: new Image.asset(
          'images/launcher/move_focus.png',
          fit: BoxFit.fill,
        ));
    var content = new Container(
        decoration: new BoxDecoration(
          image: const DecorationImage(
              fit: BoxFit.fill,
              image: const AssetImage('images/launcher/main_bg.jpg')),
        ),
        child: new Column(children: [
          new Expanded(
              child: new Row(children: [
            new Expanded(
              flex: 2,
              child: new RawKeyboardListener(
                  key: globalKey0,
                  focusNode: focusNode0,
                  onKey: (RawKeyEvent event) {
                    if (event is RawKeyDownEvent &&
                        event.data is RawKeyEventDataAndroid) {
                      RawKeyDownEvent rawKeyDownEvent = event;
                      RawKeyEventDataAndroid rawKeyEventDataAndroid =
                          rawKeyDownEvent.data;
                      print("page1 index0 keyCode = " +
                          rawKeyEventDataAndroid.keyCode.toString());
                      switch (rawKeyEventDataAndroid.keyCode) {
                        case KEY_LEFT:
                          if (widget.turnPage != null) {
                            widget.turnPage(KEY_LEFT);
                          }
                          break;
                        case KEY_RIGHT:
                          focusNode = focusNode1;
                          _doFocusAnimation(globalKey1,
                              new Size(kPosters[1].width, kPosters[1].height));
                          break;
                        case KEY_DOWN:
                          focusNode = focusNode2;
                          _doFocusAnimation(globalKey2,
                              new Size(kPosters[2].width, kPosters[2].height));
                          break;
                        case KEY_UP:
                          break;
                        default:
                          break;
                      }
                    }
                  },
                  child: buildPost(kPosters[0])),
            ),
            new Expanded(
              flex: 1,
              child: new RawKeyboardListener(
                  key: globalKey1,
                  focusNode: focusNode1,
                  onKey: (RawKeyEvent event) {
                    if (event is RawKeyDownEvent &&
                        event.data is RawKeyEventDataAndroid) {
                      RawKeyDownEvent rawKeyDownEvent = event;
                      RawKeyEventDataAndroid rawKeyEventDataAndroid =
                          rawKeyDownEvent.data;
                      print("page1 index1 keyCode = " +
                          rawKeyEventDataAndroid.keyCode.toString());
                      switch (rawKeyEventDataAndroid.keyCode) {
                        case KEY_LEFT:
                          focusNode = focusNode0;
                          _doFocusAnimation(globalKey0,
                              new Size(kPosters[0].width, kPosters[0].height));
                          break;
                        case KEY_RIGHT:
                          if (widget.turnPage != null) {
                            widget.turnPage(KEY_RIGHT);
                          }
                          break;
                        case KEY_DOWN:
                          focusNode = focusNode4;
                          _doFocusAnimation(globalKey4,
                              new Size(kPosters[4].width, kPosters[4].height));
                          break;
                        case KEY_UP:
                          break;
                        default:
                          break;
                      }
                    }
                  },
                  child: buildPost(kPosters[1])),
            )
          ])),
          new Expanded(
              child: new Row(children: [
            new Expanded(
              child: new RawKeyboardListener(
                  key: globalKey2,
                  focusNode: focusNode2,
                  onKey: (RawKeyEvent event) {
                    if (event is RawKeyDownEvent &&
                        event.data is RawKeyEventDataAndroid) {
                      RawKeyDownEvent rawKeyDownEvent = event;
                      RawKeyEventDataAndroid rawKeyEventDataAndroid =
                          rawKeyDownEvent.data;
                      print("page1 index2 keyCode = " +
                          rawKeyEventDataAndroid.keyCode.toString());
                      switch (rawKeyEventDataAndroid.keyCode) {
                        case KEY_LEFT:
                          if (widget.turnPage != null) {
                            widget.turnPage(KEY_LEFT);
                          }
                          break;
                        case KEY_RIGHT:
                          focusNode = focusNode3;
                          _doFocusAnimation(globalKey3,
                              new Size(kPosters[3].width, kPosters[3].height));
                          break;
                        case KEY_DOWN:
                          break;
                        case KEY_UP:
                          focusNode = focusNode0;
                          _doFocusAnimation(globalKey0,
                              new Size(kPosters[0].width, kPosters[0].height));
                          break;
                        default:
                          break;
                      }
                    }
                  },
                  child: buildPost(kPosters[2])),
            ),
            new Expanded(
              child: new RawKeyboardListener(
                  key: globalKey3,
                  focusNode: focusNode3,
                  onKey: (RawKeyEvent event) {
                    if (event is RawKeyDownEvent &&
                        event.data is RawKeyEventDataAndroid) {
                      RawKeyDownEvent rawKeyDownEvent = event;
                      RawKeyEventDataAndroid rawKeyEventDataAndroid =
                          rawKeyDownEvent.data;
                      print("page1 index3 keyCode = " +
                          rawKeyEventDataAndroid.keyCode.toString());
                      switch (rawKeyEventDataAndroid.keyCode) {
                        case KEY_LEFT:
                          focusNode = focusNode2;
                          _doFocusAnimation(globalKey2,
                              new Size(kPosters[2].width, kPosters[2].height));
                          break;
                        case KEY_RIGHT:
                          focusNode = focusNode4;
                          _doFocusAnimation(globalKey4,
                              new Size(kPosters[4].width, kPosters[4].height));
                          break;
                        case KEY_DOWN:
                          break;
                        case KEY_UP:
                          focusNode = focusNode0;
                          _doFocusAnimation(globalKey0,
                              new Size(kPosters[0].width, kPosters[0].height));
                          break;
                        default:
                          break;
                      }
                    }
                  },
                  child: buildPost(kPosters[3])),
            ),
            new Expanded(
              child: new RawKeyboardListener(
                  key: globalKey4,
                  focusNode: focusNode4,
                  onKey: (RawKeyEvent event) {
                    if (event is RawKeyDownEvent &&
                        event.data is RawKeyEventDataAndroid) {
                      RawKeyDownEvent rawKeyDownEvent = event;
                      RawKeyEventDataAndroid rawKeyEventDataAndroid =
                          rawKeyDownEvent.data;
                      print("page1 index4 keyCode = " +
                          rawKeyEventDataAndroid.keyCode.toString());
                      switch (rawKeyEventDataAndroid.keyCode) {
                        case KEY_LEFT:
                          focusNode = focusNode3;
                          _doFocusAnimation(globalKey3,
                              new Size(kPosters[3].width, kPosters[3].height));
                          break;
                        case KEY_RIGHT:
                          if (widget.turnPage != null) {
                            widget.turnPage(KEY_RIGHT);
                          }
                          break;
                        case KEY_DOWN:
                          break;
                        case KEY_UP:
                          focusNode = focusNode1;
                          _doFocusAnimation(globalKey1,
                              new Size(kPosters[1].width, kPosters[1].height));
                          break;
                        default:
                          break;
                      }
                    }
                  },
                  child: buildPost(kPosters[4])),
            )
          ]))
        ]));
    return new Stack(children: <Widget>[content, focusBox]);
  }
}

const List<Poster> kPosters = const <Poster>[
  const Poster(
    id: 0,
    name: 'Big Fish & Begonia',
    imagePath: 'images/launcher/ic_post_1.jpg',
    width: 900.0,
    height: 200.0,
  ),
  const Poster(
    id: 1,
    name: 'Line Walker',
    imagePath: 'images/launcher/ic_post_5.jpg',
    width: 600.0,
    height: 200.0,
  ),
  const Poster(
    id: 2,
    name: 'Alice\'s Adventures',
    imagePath: 'images/launcher/ic_post_2.jpg',
    width: 600.0,
    height: 200.0,
  ),
  const Poster(
    id: 3,
    name: 'W: Two Worlds',
    imagePath: 'images/launcher/ic_post_6.jpg',
    width: 600.0,
    height: 200.0,
  ),
  const Poster(
    id: 4,
    name: 'Teenage Mutant Ninja Turtles',
    imagePath: 'images/launcher/ic_post_4.jpg',
    width: 600.0,
    height: 200.0,
  ),
];
