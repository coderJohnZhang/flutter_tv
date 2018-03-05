import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tv/http_request.dart';
import 'package:flutter_tv/platform_channel.dart';
import 'tv_launcher.dart';
import 'key_code.dart';

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
    print('TvAppWidget screenSize = $screenSize devicePixelRatio = $devicePixelRatio');
    return new MaterialApp(
      title: 'Flutter Demo',
      home: new MyHomePage(title: 'Home Page'),
      routes: <String, WidgetBuilder>{
        '/a': (BuildContext context) =>
        new PosterDemo(screenSize: screenSize),
        '/b': (BuildContext context) =>
        new HttpDemo(),
        '/c': (BuildContext context) =>
        new PlatformChannel()
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
  FocusNode focusNode0;
  FocusNode focusNode1;
  FocusNode focusNode2;
  Color color0 = Colors.grey;
  Color color1 = Colors.grey;
  Color color2 = Colors.grey;
  bool isFirstIn = true;

  @override
  void initState() {
    print('initState called.');
    super.initState();
    focusNode0 = new FocusNode();
    focusNode0.addListener(_changeColor0);
    focusNode1 = new FocusNode();
    focusNode1.addListener(_changeColor1);
    focusNode2 = new FocusNode();
    focusNode2.addListener(_changeColor2);
  }

  @override
  void dispose() {
    print('dispose called.');
    focusNode0.removeListener(_changeColor0);
    focusNode0.dispose();
    focusNode1.removeListener(_changeColor1);
    focusNode1.dispose();
    focusNode2.removeListener(_changeColor2);
    focusNode2.dispose();
    super.dispose();
  }

  _changeColor0() {
    print("focusNode0.hasFocus = ${focusNode0.hasFocus}");
    setState(() {
      if (focusNode0.hasFocus) {
        color0 = Colors.red;
      } else {
        color0 = Colors.grey;
      }
    });
  }

  _changeColor1() {
    print("focusNode1.hasFocus = ${focusNode1.hasFocus}");
    setState(() {
      if (focusNode1.hasFocus) {
        color1 = Colors.red;
      } else {
        color1 = Colors.grey;
      }
    });
  }

  _changeColor2() {
    print("focusNode2.hasFocus = ${focusNode2.hasFocus}");
    setState(() {
      if (focusNode2.hasFocus) {
        color2 = Colors.red;
      } else {
        color2 = Colors.grey;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstIn) {
      FocusScope.of(context).requestFocus(focusNode0);
      isFirstIn = false;
    }
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Column(
            children: <Widget>[
              new Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 5.0, top: 150.0),
                child: new RawKeyboardListener(
                  focusNode: focusNode0,
                  onKey: (RawKeyEvent event) {
                    if (event is RawKeyDownEvent &&
                        event.data is RawKeyEventDataAndroid) {
                      RawKeyDownEvent rawKeyDownEvent = event;
                      RawKeyEventDataAndroid rawKeyEventDataAndroid =
                          rawKeyDownEvent.data;
                      print("tv launcher sample ${rawKeyEventDataAndroid
                          .keyCode}");
                      switch (rawKeyEventDataAndroid.keyCode) {
                        case KEY_CENTER:
                          Navigator.of(context).pushNamed('/a');
                          break;
                        case KEY_UP:
                          FocusScope.of(context).requestFocus(focusNode2);
                          break;
                        case KEY_DOWN:
                          FocusScope.of(context).requestFocus(focusNode1);
                          break;
                        default:
                          break;
                      }
                    }
                  },
                  child: new RaisedButton(
                    child: new Container(
                        alignment: Alignment.center,
                        width: 160.0,
                        child: new Text('tv launcher sample')),
                    color: color0,
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
                  focusNode: focusNode1,
                  onKey: (RawKeyEvent event) {
                    if (event is RawKeyDownEvent &&
                        event.data is RawKeyEventDataAndroid) {
                      RawKeyDownEvent rawKeyDownEvent = event;
                      RawKeyEventDataAndroid rawKeyEventDataAndroid =
                          rawKeyDownEvent.data;
                      print("http request sample ${rawKeyEventDataAndroid
                          .keyCode}");
                      switch (rawKeyEventDataAndroid.keyCode) {
                        case KEY_CENTER:
                          Navigator.of(context).pushNamed('/b');
                          break;
                        case KEY_UP:
                          FocusScope.of(context).requestFocus(focusNode0);
                          break;
                        case KEY_DOWN:
                          FocusScope.of(context).requestFocus(focusNode2);
                          break;
                        default:
                          break;
                      }
                    }
                  },
                  child: new RaisedButton(
                    child: new Container(
                        alignment: Alignment.center,
                        width: 160.0,
                        child: new Text('http request sample')),
                    color: color1,
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
                  focusNode: focusNode2,
                  onKey: (RawKeyEvent event) {
                    if (event is RawKeyDownEvent &&
                        event.data is RawKeyEventDataAndroid) {
                      RawKeyDownEvent rawKeyDownEvent = event;
                      RawKeyEventDataAndroid rawKeyEventDataAndroid =
                          rawKeyDownEvent.data;
                      print("file operation sample ${rawKeyEventDataAndroid
                          .keyCode}");
                      switch (rawKeyEventDataAndroid.keyCode) {
                        case KEY_CENTER:
                          Navigator.of(context).pushNamed('/c');
                          break;
                        case KEY_UP:
                          FocusScope.of(context).requestFocus(focusNode1);
                          break;
                        case KEY_DOWN:
                          FocusScope.of(context).requestFocus(focusNode0);
                          break;
                        default:
                          break;
                      }
                    }
                  },
                  child: new RaisedButton(
                    child: new Container(
                        alignment: Alignment.center,
                        width: 160.0,
                        child: new Text('platform channel sample')),
                    color: color2,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/c');
                    },
                  ),
                ),
              ),
            ]
        ));
  }
}