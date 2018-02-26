import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'poster.dart';
import 'key_code.dart';
import 'call_back.dart';

class Page1Widget extends StatefulWidget {
  const Page1Widget({
    Key key,
    this.onFocusLeft,
    this.onFocusRight,
    this.onFocusUp,
    this.onFocusDown,
    this.screenSize,
  }) : super(key: key);
  final OnFocusChangeCallback<GlobalKey, Size> onFocusLeft;
  final OnFocusChangeCallback<GlobalKey, Size> onFocusRight;
  final OnFocusChangeCallback<GlobalKey, Size> onFocusUp;
  final OnFocusChangeCallback<GlobalKey, Size> onFocusDown;
  final Size screenSize;

  @override
  Page1WidgetState createState() => new Page1WidgetState();
}

class Page1WidgetState extends State<Page1Widget> {
  FocusNode focusNode0;
  FocusNode focusNode1;
  FocusNode focusNode2;
  FocusNode focusNode3;
  FocusNode focusNode4;

  final GlobalKey globalKey0 = new GlobalKey();
  final GlobalKey globalKey1 = new GlobalKey();
  final GlobalKey globalKey2 = new GlobalKey();
  final GlobalKey globalKey3 = new GlobalKey();
  final GlobalKey globalKey4 = new GlobalKey();

  @override
  void initState() {
    print('page1 initState called.');
    super.initState();
    focusNode0 = new FocusNode();
    focusNode1 = new FocusNode();
    focusNode2 = new FocusNode();
    focusNode3 = new FocusNode();
    focusNode4 = new FocusNode();
  }

  @override
  void dispose() {
    print('page1 dispose called.');
    focusNode0.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
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
                          switch (rawKeyEventDataAndroid.keyCode) {
                            case KEY_LEFT:
                              if (widget.onFocusLeft != null) {
                                widget.onFocusLeft(null, null);
                              }
                              break;
                            case KEY_RIGHT:
                              FocusScope.of(context).requestFocus(focusNode1);
                              Size size = new Size(
                                  widget.screenSize.width / 3 - 10.0,
                                  widget.screenSize.height * 3 / 8 - 10.0);
                              if (widget.onFocusRight != null) {
                                widget.onFocusRight(globalKey1, size);
                              }
                              break;
                            case KEY_DOWN:
                              FocusScope.of(context).requestFocus(focusNode2);
                              Size size = new Size(
                                  widget.screenSize.width / 3 - 10.0,
                                  widget.screenSize.height * 3 / 8 - 10.0);
                              if (widget.onFocusDown != null) {
                                widget.onFocusDown(globalKey2, size);
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
                          kPosters[0],
                          new Size(widget.screenSize.width * 2 / 3 - 10.0,
                              widget.screenSize.height * 3 / 8 - 10.0))),
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
                          switch (rawKeyEventDataAndroid.keyCode) {
                            case KEY_LEFT:
                              FocusScope.of(context).requestFocus(focusNode0);
                              Size size = new Size(
                                  widget.screenSize.width * 2 / 3 - 10.0,
                                  widget.screenSize.height * 3 / 8 - 10.0);
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
                              FocusScope.of(context).requestFocus(focusNode4);
                              Size size = new Size(
                                  widget.screenSize.width / 3 - 10.0,
                                  widget.screenSize.height * 3 / 8 - 10.0);
                              if (widget.onFocusDown != null) {
                                widget.onFocusDown(globalKey4, size);
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
                              widget.screenSize.height * 3 / 8 - 10.0))),
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
                          switch (rawKeyEventDataAndroid.keyCode) {
                            case KEY_LEFT:
                              if (widget.onFocusLeft != null) {
                                widget.onFocusLeft(null, null);
                              }
                              break;
                            case KEY_RIGHT:
                              FocusScope.of(context).requestFocus(focusNode3);
                              Size size = new Size(
                                  widget.screenSize.width / 3 - 10.0,
                                  widget.screenSize.height * 3 / 8 - 10.0);
                              if (widget.onFocusRight != null) {
                                widget.onFocusRight(globalKey3, size);
                              }
                              break;
                            case KEY_DOWN:
                              break;
                            case KEY_UP:
                              FocusScope.of(context).requestFocus(focusNode0);
                              Size size = new Size(
                                  widget.screenSize.width * 2 / 3 - 10.0,
                                  widget.screenSize.height * 3 / 8 - 10.0);
                              if (widget.onFocusUp != null) {
                                widget.onFocusUp(globalKey0, size);
                              }
                              break;
                            default:
                              break;
                          }
                        }
                      },
                      child: buildPost(
                          kPosters[2],
                          new Size(widget.screenSize.width / 3 - 10.0,
                              widget.screenSize.height * 3 / 8 - 10.0))),
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
                          switch (rawKeyEventDataAndroid.keyCode) {
                            case KEY_LEFT:
                              FocusScope.of(context).requestFocus(focusNode2);
                              Size size = new Size(
                                  widget.screenSize.width / 3 - 10.0,
                                  widget.screenSize.height * 3 / 8 - 10.0);
                              if (widget.onFocusLeft != null) {
                                widget.onFocusLeft(globalKey2, size);
                              }
                              break;
                            case KEY_RIGHT:
                              FocusScope.of(context).requestFocus(focusNode4);
                              Size size = new Size(
                                  widget.screenSize.width / 3 - 10.0,
                                  widget.screenSize.height * 3 / 8 - 10.0);
                              if (widget.onFocusRight != null) {
                                widget.onFocusRight(globalKey4, size);
                              }
                              break;
                            case KEY_DOWN:
                              break;
                            case KEY_UP:
                              FocusScope.of(context).requestFocus(focusNode0);
                              Size size = new Size(
                                  widget.screenSize.width * 2 / 3 - 10.0,
                                  widget.screenSize.height * 3 / 8 - 10.0);
                              if (widget.onFocusUp != null) {
                                widget.onFocusUp(globalKey0, size);
                              }
                              break;
                            default:
                              break;
                          }
                        }
                      },
                      child: buildPost(
                          kPosters[3],
                          new Size(widget.screenSize.width / 3 - 10.0,
                              widget.screenSize.height * 3 / 8 - 10.0))),
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
                          switch (rawKeyEventDataAndroid.keyCode) {
                            case KEY_LEFT:
                              FocusScope.of(context).requestFocus(focusNode3);
                              Size size = new Size(
                                  widget.screenSize.width / 3 - 10.0,
                                  widget.screenSize.height * 3 / 8 - 10.0);
                              if (widget.onFocusLeft != null) {
                                widget.onFocusLeft(globalKey3, size);
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
                              FocusScope.of(context).requestFocus(focusNode1);
                              Size size = new Size(
                                  widget.screenSize.width / 3 - 10.0,
                                  widget.screenSize.height * 3 / 8 - 10.0);
                              if (widget.onFocusRight != null) {
                                widget.onFocusUp(globalKey1, size);
                              }
                              break;
                            default:
                              break;
                          }
                        }
                      },
                      child: buildPost(
                          kPosters[4],
                          new Size(widget.screenSize.width / 3 - 10.0,
                              widget.screenSize.height * 3 / 8 - 10.0))),
                )
              ]))
        ]));
  }
}

const List<Poster> kPosters = const <Poster>[
  const Poster(
    id: 0,
    name: 'Big Fish & Begonia',
    imagePath: 'images/launcher/ic_post_1.jpg',
  ),
  const Poster(
    id: 1,
    name: 'Line Walker',
    imagePath: 'images/launcher/ic_post_5.jpg',
  ),
  const Poster(
    id: 2,
    name: 'Alice\'s Adventures',
    imagePath: 'images/launcher/ic_post_2.jpg',
  ),
  const Poster(
    id: 3,
    name: 'W: Two Worlds',
    imagePath: 'images/launcher/ic_post_6.jpg',
  ),
  const Poster(
    id: 4,
    name: 'Teenage Mutant Ninja Turtles',
    imagePath: 'images/launcher/ic_post_4.jpg',
  ),
];
