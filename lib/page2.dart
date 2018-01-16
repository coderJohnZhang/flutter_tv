import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'poster.dart';
import 'key_code.dart';
import 'call_back.dart';

class Page2Widget extends StatefulWidget {
  const Page2Widget({
    Key key,
    this.onFocusLeft,
    this.onFocusRight,
    this.onFocusUp,
    this.onFocusDown,
    this.screenSize,
  })
      : super(key: key);
  final OnFocusChangeCallback<GlobalKey, Size> onFocusLeft;
  final OnFocusChangeCallback<GlobalKey, Size> onFocusRight;
  final OnFocusChangeCallback<GlobalKey, Size> onFocusUp;
  final OnFocusChangeCallback<GlobalKey, Size> onFocusDown;
  final Size screenSize;

  @override
  Page2WidgetState createState() => new Page2WidgetState();
}

class Page2WidgetState extends State<Page2Widget> {
  FocusNode focusNode0;
  FocusNode focusNode1;
  FocusNode focusNode2;
  FocusNode focusNode3;

  final GlobalKey globalKey0 = new GlobalKey();
  final GlobalKey globalKey1 = new GlobalKey();
  final GlobalKey globalKey2 = new GlobalKey();
  final GlobalKey globalKey3 = new GlobalKey();
  final GlobalKey globalKey4 = new GlobalKey();

  @override
  void initState() {
    print('page2 initState called.');
    super.initState();
    focusNode0 = new FocusNode();
    focusNode1 = new FocusNode();
    focusNode2 = new FocusNode();
    focusNode3 = new FocusNode();
  }

  @override
  void dispose() {
    print('page2 dispose called.');
    focusNode0.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode0);
    return new Container(
        decoration: new BoxDecoration(
          image: const DecorationImage(
              fit: BoxFit.fill,
              image: const AssetImage('images/launcher/main_bg.jpg')),
        ),
        child: new Row(children: [
          new Expanded(
              flex: 1,
              child: new RawKeyboardListener(
                key: globalKey0,
                focusNode: focusNode0,
                onKey: (RawKeyEvent event) {
                  if (event is RawKeyDownEvent &&
                      event.data is RawKeyEventDataAndroid) {
                    RawKeyDownEvent rawKeyDownEvent = event;
                    RawKeyEventDataAndroid rawKeyEventDataAndroid =
                        rawKeyDownEvent.data;
                    switch (rawKeyEventDataAndroid.keyCode) {
                      case KEY_LEFT:
                        if (widget.onFocusLeft != null) {
                          widget.onFocusLeft(null, null);
                        }
                        break;
                      case KEY_RIGHT:
                        FocusScope.of(context).requestFocus(focusNode1);
                        Size size = new Size(widget.screenSize.width / 3 - 10.0,
                            widget.screenSize.height * 3 / 8 - 10.0);
                        if (widget.onFocusRight != null) {
                          widget.onFocusRight(globalKey1, size);
                        }
                        break;
                      case KEY_DOWN:
                        break;
                      case KEY_UP:
                        break;
                      default:
                        break;
                    }
                  }
                },
                child: buildPost(
                    kPosters[0],
                    new Size(widget.screenSize.width / 3 - 10.0,
                        widget.screenSize.height * 3 / 4 - 10.0)),
              )),
          new Expanded(
              flex: 2,
              child: new Column(children: [
                new Expanded(
                    child: new Row(children: [
                  new Expanded(
                      child: new RawKeyboardListener(
                          key: globalKey1,
                          focusNode: focusNode1,
                          onKey: (RawKeyEvent event) {
                            if (event is RawKeyDownEvent &&
                                event.data is RawKeyEventDataAndroid) {
                              RawKeyDownEvent rawKeyDownEvent = event;
                              RawKeyEventDataAndroid rawKeyEventDataAndroid =
                                  rawKeyDownEvent.data;
                              switch (rawKeyEventDataAndroid.keyCode) {
                                case KEY_LEFT:
                                  FocusScope
                                      .of(context)
                                      .requestFocus(focusNode0);
                                  Size size = new Size(
                                      widget.screenSize.width / 3 - 10.0,
                                      widget.screenSize.height * 3 / 4 - 10.0);
                                  if (widget.onFocusLeft != null) {
                                    widget.onFocusLeft(globalKey0, size);
                                  }
                                  break;
                                case KEY_RIGHT:
                                  FocusScope
                                      .of(context)
                                      .requestFocus(focusNode2);
                                  Size size = new Size(
                                      widget.screenSize.width / 3 - 10.0,
                                      widget.screenSize.height * 3 / 8 - 10.0);
                                  if (widget.onFocusRight != null) {
                                    widget.onFocusRight(globalKey2, size);
                                  }
                                  break;
                                case KEY_DOWN:
                                  FocusScope
                                      .of(context)
                                      .requestFocus(focusNode3);
                                  Size size = new Size(
                                      widget.screenSize.width * 2 / 3 - 10.0,
                                      widget.screenSize.height * 3 / 8 - 10.0);
                                  if (widget.onFocusDown != null) {
                                    widget.onFocusDown(globalKey3, size);
                                  }
                                  break;
                                case KEY_UP:
                                  break;
                                default:
                                  break;
                              }
                            }
                          },
                          child: buildPost(
                              kPosters[1],
                              new Size(widget.screenSize.width / 3 - 10.0,
                                  widget.screenSize.height * 3 / 8 - 10.0)))),
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
                              switch (rawKeyEventDataAndroid.keyCode) {
                                case KEY_LEFT:
                                  FocusScope
                                      .of(context)
                                      .requestFocus(focusNode1);
                                  Size size = new Size(
                                      widget.screenSize.width / 3 - 10.0,
                                      widget.screenSize.height * 3 / 8 - 10.0);
                                  if (widget.onFocusLeft != null) {
                                    widget.onFocusLeft(globalKey1, size);
                                  }
                                  break;
                                case KEY_RIGHT:
                                  if (widget.onFocusRight != null) {
                                    widget.onFocusRight(null, null);
                                  }
                                  break;
                                case KEY_DOWN:
                                  FocusScope
                                      .of(context)
                                      .requestFocus(focusNode3);
                                  Size size = new Size(
                                      widget.screenSize.width * 2 / 3 - 10.0,
                                      widget.screenSize.height * 3 / 8 - 10.0);
                                  if (widget.onFocusDown != null) {
                                    widget.onFocusDown(globalKey3, size);
                                  }
                                  break;
                                case KEY_UP:
                                  break;
                                default:
                                  break;
                              }
                            }
                          },
                          child: buildPost(
                              kPosters[2],
                              new Size(widget.screenSize.width / 3 - 10.0,
                                  widget.screenSize.height * 3 / 8 - 10.0))))
                ])),
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
                            switch (rawKeyEventDataAndroid.keyCode) {
                              case KEY_LEFT:
                                FocusScope.of(context).requestFocus(focusNode0);
                                Size size = new Size(
                                    widget.screenSize.width / 3 - 10.0,
                                    widget.screenSize.height * 3 / 4 - 10.0);
                                if (widget.onFocusLeft != null) {
                                  widget.onFocusLeft(globalKey0, size);
                                }
                                break;
                              case KEY_RIGHT:
                                if (widget.onFocusRight != null) {
                                  widget.onFocusRight(null, null);
                                }
                                break;
                              case KEY_DOWN:
                                break;
                              case KEY_UP:
                                FocusScope.of(context).requestFocus(focusNode2);
                                Size size = new Size(
                                    widget.screenSize.width / 3 - 10.0,
                                    widget.screenSize.height * 3 / 8 - 10.0);
                                if (widget.onFocusUp != null) {
                                  widget.onFocusUp(globalKey2, size);
                                }
                                break;
                              default:
                                break;
                            }
                          }
                        },
                        child: buildPost(
                            kPosters[3],
                            new Size(widget.screenSize.width * 2 / 3 - 10.0,
                                widget.screenSize.height * 3 / 8 - 10.0))))
              ]))
        ]));
  }
}

const List<Poster> kPosters = const <Poster>[
  const Poster(
    id: 0,
    name: 'Line Walker',
    imagePath: 'images/launcher/ic_post_5.jpg',
  ),
  const Poster(
    id: 1,
    name: 'W: Two Worlds',
    imagePath: 'images/launcher/ic_post_6.jpg',
  ),
  const Poster(
    id: 2,
    name: 'The Revenant',
    imagePath: 'images/launcher/ic_post_7.jpg',
  ),
  const Poster(
    id: 3,
    name: 'Warcraft',
    imagePath: 'images/launcher/ic_post_0.jpg',
  ),
];
