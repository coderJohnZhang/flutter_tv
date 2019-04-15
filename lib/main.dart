import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tv/http_request.dart';
import 'package:flutter_tv/platform_channel.dart';

import 'key_code.dart';
import 'tv_launcher.dart';

void main() {
  runApp(new MaterialApp(
    //showPerformanceOverlay: true,
    title: 'Flutter Study',
    home: new TvAppWidget(),
  ));
}

class TvAppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    print(
        'TvAppWidget screenSize = $screenSize devicePixelRatio = $devicePixelRatio');
    return new MaterialApp(
      title: 'Flutter Demo',
      home: new MyHomePage(title: 'Home Page'),
      routes: <String, WidgetBuilder>{
        '/a': (BuildContext context) => new PosterDemo(screenSize: screenSize),
        '/b': (BuildContext context) => new HttpDemo(),
        '/c': (BuildContext context) => new PlatformChannel()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<FocusNode> focusNodes = List();
  bool isFirstIn = true;

  @override
  void initState() {
    print('initState called.');
    super.initState();
    for (int i = 0; i < 3; i++) {
      FocusNode focus = FocusNode();
      focusNodes.add(focus);
    }
  }

  @override
  void dispose() {
    print('dispose called.');
    for (int i = 0; i < 3; i++) {
      focusNodes[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstIn) {
      FocusScope.of(context).requestFocus(focusNodes[0]);
      isFirstIn = false;
    }
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Column(children: <Widget>[
          new Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 5.0, top: 150.0),
            child: new RawKeyboardListener(
              focusNode: focusNodes[0],
              onKey: (RawKeyEvent event) {
                if (event is RawKeyDownEvent &&
                    event.data is RawKeyEventDataAndroid) {
                  RawKeyDownEvent rawKeyDownEvent = event;
                  RawKeyEventDataAndroid rawKeyEventDataAndroid =
                      rawKeyDownEvent.data;
                  print("tv launcher sample ${rawKeyEventDataAndroid.keyCode}");
                  switch (rawKeyEventDataAndroid.keyCode) {
                    case KEY_CENTER:
                      Navigator.of(context).pushNamed('/a');
                      break;
                    case KEY_UP:
                      FocusScope.of(context).requestFocus(focusNodes[2]);
                      break;
                    case KEY_DOWN:
                      FocusScope.of(context).requestFocus(focusNodes[1]);
                      break;
                    default:
                      break;
                  }
                  setState(() {});
                }
              },
              child: new RaisedButton(
                child: new Container(
                    alignment: Alignment.center,
                    width: 160.0,
                    child: new Text('tv launcher sample')),
                color: focusNodes[0].hasFocus ? Colors.red : Colors.grey,
                onPressed: () {
                  Navigator.of(context).pushNamed('/a');
                },
              ),
            ),
          ),
          new Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(5.0),
            child: new RawKeyboardListener(
              focusNode: focusNodes[1],
              onKey: (RawKeyEvent event) {
                if (event is RawKeyDownEvent &&
                    event.data is RawKeyEventDataAndroid) {
                  RawKeyDownEvent rawKeyDownEvent = event;
                  RawKeyEventDataAndroid rawKeyEventDataAndroid =
                      rawKeyDownEvent.data;
                  print(
                      "http request sample ${rawKeyEventDataAndroid.keyCode}");
                  switch (rawKeyEventDataAndroid.keyCode) {
                    case KEY_CENTER:
                      Navigator.of(context).pushNamed('/b');
                      break;
                    case KEY_UP:
                      FocusScope.of(context).requestFocus(focusNodes[0]);
                      break;
                    case KEY_DOWN:
                      FocusScope.of(context).requestFocus(focusNodes[2]);
                      break;
                    default:
                      break;
                  }
                  setState(() {});
                }
              },
              child: new RaisedButton(
                child: new Container(
                    alignment: Alignment.center,
                    width: 160.0,
                    child: new Text('http request sample')),
                color: focusNodes[1].hasFocus ? Colors.red : Colors.grey,
                onPressed: () {
                  Navigator.of(context).pushNamed('/b');
                },
              ),
            ),
          ),
          new Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(5.0),
            child: new RawKeyboardListener(
              focusNode: focusNodes[2],
              onKey: (RawKeyEvent event) {
                if (event is RawKeyDownEvent &&
                    event.data is RawKeyEventDataAndroid) {
                  RawKeyDownEvent rawKeyDownEvent = event;
                  RawKeyEventDataAndroid rawKeyEventDataAndroid =
                      rawKeyDownEvent.data;
                  print(
                      "platform channel sample ${rawKeyEventDataAndroid.keyCode}");
                  switch (rawKeyEventDataAndroid.keyCode) {
                    case KEY_CENTER:
                      Navigator.of(context).pushNamed('/c');
                      break;
                    case KEY_UP:
                      FocusScope.of(context).requestFocus(focusNodes[1]);
                      break;
                    case KEY_DOWN:
                      FocusScope.of(context).requestFocus(focusNodes[0]);
                      break;
                    default:
                      break;
                  }
                  setState(() {});
                }
              },
              child: new RaisedButton(
                child: new Container(
                    alignment: Alignment.center,
                    width: 160.0,
                    child: new Text('platform channel sample')),
                color: focusNodes[2].hasFocus ? Colors.red : Colors.grey,
                onPressed: () {
                  Navigator.of(context).pushNamed('/c');
                },
              ),
            ),
          ),
        ]));
  }
}
