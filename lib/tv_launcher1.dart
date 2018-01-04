import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'key_code.dart';

class PosterDemo extends StatelessWidget {
  const PosterDemo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => new PosterHome();
}

class PosterHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const PosterGridPage();
  }
}

// Displays a grid of poster cards.
class PosterGridPage extends StatefulWidget {
  const PosterGridPage({Key key}) : super(key: key);

  @override
  _PosterGridPageState createState() => new _PosterGridPageState();
}

class _PosterGridPageState extends State<PosterGridPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  FocusNode focusNode;
  RelativeRect rect = const RelativeRect.fromLTRB(5.0, 90.0, 815.0, 280.0);
  Animation<RelativeRect> rectAnimation;
  AnimationController controller;
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    focusNode = new FocusNode();
    controller = new AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    rectAnimation =
        new RelativeRectTween(begin: rect, end: rect.shift(Offset.zero))
            .animate(controller);
    controller.addListener(handleAnimation);

    _controller = new ScrollController();
  }

  // 释放对象使用的资源
  @override
  void dispose() {
    print('dispose()');
    super.dispose();
    focusNode.dispose();
    controller.dispose();
    _controller.dispose();
  }

  void handleAnimation() {
    //print('handleAnimation()');
    setState(() {
      rect = rectAnimation.value;
    });
  }

  void moveLeft() {
    print('moveLeft() _controller.offset = ' + _controller.offset.toString());
    if (rect.left < 150) {
      _controller.animateTo(-150.0,
          duration: const Duration(milliseconds: 100), curve: Curves.ease);
      if (_controller.offset != 0.0) {
        rectAnimation = new RelativeRectTween(
                begin: rect, end: rect.shift(new Offset(750.0, 0.0)))
            .animate(controller);
        controller.forward();
        controller
          ..value = 0.0
          ..fling();
      }
    } else {
      rectAnimation = new RelativeRectTween(
              begin: rect, end: rect.shift(new Offset(-150.0, 0.0)))
          .animate(controller);
      controller.forward();
      controller
        ..value = 0.0
        ..fling();
    }
  }

  int count = 0;

  void moveRight() {
    print('moveRight() _controller.offset = ' + _controller.offset.toString());
    if (_controller.offset == 300.0) {
      count++;
    } else {
      count = 0;
    }
    print('moveRight() count = $count');
    if (rect.right < 150) {
      if (count < 5) {
        _controller.animateTo(_controller.offset + 150.0,
            duration: const Duration(milliseconds: 100), curve: Curves.ease);
        rectAnimation = new RelativeRectTween(
                begin: rect, end: rect.shift(new Offset(-750.0, 0.0)))
            .animate(controller);
        controller.forward();
        controller
          ..value = 0.0
          ..fling();
      }
    } else {
      rectAnimation = new RelativeRectTween(
              begin: rect, end: rect.shift(new Offset(150.0, 0.0)))
          .animate(controller);
      controller.forward();
      controller
        ..value = 0.0
        ..fling();
    }
  }

  void moveUp() {
    if (rect.bottom < 150) {
      rectAnimation = new RelativeRectTween(
              begin: rect, end: rect.shift(new Offset(0.0, -165.0)))
          .animate(controller);
      controller.forward();
      controller
        ..value = 0.0
        ..fling();
    }
  }

  void moveDown() {
    if (rect.top < 150) {
      rectAnimation = new RelativeRectTween(
              begin: rect, end: rect.shift(new Offset(0.0, 165.0)))
          .animate(controller);
      controller.forward();
      controller
        ..value = 0.0
        ..fling();
    }
  }

  @override
  Widget build(BuildContext context) {
    //print('build()');
    FocusScope.of(context).requestFocus(focusNode);
    var focusBox = new PositionedTransition(
        rect: rectAnimation,
        child: new Container(
            width: 150.0,
            height: 150.0,
            child: new Image.asset(
              'images/launcher/move_focus.png',
              fit: BoxFit.fill,
            )));
    var content = new Container(
        decoration: new BoxDecoration(
            image: const DecorationImage(
                fit: BoxFit.fill,
                image: const AssetImage('images/launcher/main_bg.jpg'))),
        child: new ListView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            itemExtent: 150.0,
            padding: const EdgeInsets.only(bottom: 8.0),
            children: kPosters.map((Poster poster) {
              return new Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(
                      left: 8.0, top: 100.0, right: 8.0, bottom: 100.0),
                  child: new PosterCard(poster: poster));
            }).toList()));

    var container =
        new Container(child: new Stack(children: <Widget>[content, focusBox]));
    return new RawKeyboardListener(
        focusNode: focusNode,
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent &&
              event.data is RawKeyEventDataAndroid) {
            RawKeyDownEvent rawKeyDownEvent = event;
            RawKeyEventDataAndroid rawKeyEventDataAndroid =
                rawKeyDownEvent.data;
            print("keyCode = " + rawKeyEventDataAndroid.keyCode.toString());
            switch (rawKeyEventDataAndroid.keyCode) {
              case KEY_LEFT:
                if (!moreThanLastKeyTime(200)) {
                  print(
                      "continue press less than the200-millisecond interval.");
                } else {
                  moveLeft();
                }
                break;
              case KEY_RIGHT:
                if (!moreThanLastKeyTime(200)) {
                  print(
                      "continue press less than the200-millisecond interval.");
                } else {
                  moveRight();
                }
                break;
              case KEY_DOWN:
                if (!moreThanLastKeyTime(200)) {
                  print(
                      "continue press less than the200-millisecond interval.");
                } else {
                  moveDown();
                }
                break;
              case KEY_UP:
                if (!moreThanLastKeyTime(200)) {
                  print(
                      "continue press less than the200-millisecond interval.");
                } else {
                  moveUp();
                }
                break;
              default:
                break;
            }
          }
        },
        child: new Scaffold(
          key: scaffoldKey,
          body: container,
        ));
  }
}

int lastKeyTime = 0;
bool isAllowClick;

bool moreThanLastKeyTime(int value) {
  DateTime time = new DateTime.now();
  int curTime = time.millisecondsSinceEpoch;
  if ((curTime - lastKeyTime) > value) {
    isAllowClick = true;
  } else {
    isAllowClick = false;
  }
  lastKeyTime = curTime;
  return isAllowClick;
}

// A card with the poster's image, author, and title.
class PosterCard extends StatelessWidget {
  const PosterCard({Key key, this.poster}) : super(key: key);
  final Poster poster;

  @override
  Widget build(BuildContext context) {
    return buildItem(poster.imagePath, poster.name);
  }

  Column buildItem(String imgPath, String text) {
    return new Column(children: [
      new Expanded(child: buildPost(imgPath, text)),
      new Expanded(child: buildPost(imgPath, text))
    ]);
  }
}

Stack buildPost(String imgPath, String text) {
  return new Stack(children: <Widget>[
    new Container(
        width: 150.0,
        height: 150.0,
        child: new Image.asset(imgPath, fit: BoxFit.fill)),
    new Positioned(
        left: 35.0,
        top: 130.0,
        child: new Container(
          decoration: new BoxDecoration(color: Colors.black),
          child: new Text(
            text,
            style: new TextStyle(
              color: Colors.white,
              fontSize: 10.0,
              fontFamily: 'serif',
            ),
          ),
        )),
  ]);
}

class Poster {
  const Poster({this.name, this.imagePath});

  final String name;
  final String imagePath;
}

const List<Poster> kPosters = const <Poster>[
  const Poster(
    name: 'Animation test1',
    imagePath: 'images/launcher/ic_post_1.jpg',
  ),
  const Poster(
    name: 'Animation test2',
    imagePath: 'images/launcher/ic_post_2.jpg',
  ),
  const Poster(
    name: 'Animation test3',
    imagePath: 'images/launcher/ic_post_3.jpg',
  ),
  const Poster(
    name: 'Animation test4',
    imagePath: 'images/launcher/ic_post_4.jpg',
  ),
  const Poster(
    name: 'Animation test5',
    imagePath: 'images/launcher/ic_post_5.jpg',
  ),
  const Poster(
    name: 'Animation test6',
    imagePath: 'images/launcher/ic_post_6.jpg',
  ),
  const Poster(
    name: 'Animation test7',
    imagePath: 'images/launcher/ic_post_7.jpg',
  ),
  const Poster(
    name: 'Animation test8',
    imagePath: 'images/launcher/ic_post_8.jpg',
  ),
  const Poster(
    name: 'Animation test1',
    imagePath: 'images/launcher/ic_post_1.jpg',
  ),
];
