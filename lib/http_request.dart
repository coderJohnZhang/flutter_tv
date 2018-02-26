import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'key_code.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _ipAddress = 'Unknown';
  FocusNode focusNode;
  bool _active = false;

  _getIPAddress() async {
    print("_active = $_active");
    var url = 'https://httpbin.org/ip';
    var httpClient = new HttpClient();

    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        var json = await response.transform(UTF8.decoder).join();
        var data = JSON.decode(json);
        result = data['origin'];
      } else {
        result =
        'Error getting IP address:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'Failed getting IP address';
    }

    // If the widget was removed from the tree while the message was in flight,
    // we want to discard the reply rather than calling setState to update our
    // non-existent appearance.
    if (!mounted) return;

    setState(() {
      _ipAddress = result;
      _active = !_active;
    });
  }

  @override
  void initState() {
    print('initState called.');
    super.initState();
    focusNode = new FocusNode();
  }

  @override
  void dispose() {
    print('dispose called.');
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var spacer = new SizedBox(height: 32.0);
    FocusScope.of(context).requestFocus(focusNode);
    return new Scaffold(
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text('Your current IP address is:'),
            new Text('$_ipAddress.'),
            spacer,
            new RawKeyboardListener(
              focusNode: focusNode,
              onKey: (RawKeyEvent event) {
                if (event is RawKeyDownEvent &&
                    event.data is RawKeyEventDataAndroid) {
                  RawKeyDownEvent rawKeyDownEvent = event;
                  RawKeyEventDataAndroid rawKeyEventDataAndroid =
                      rawKeyDownEvent.data;
                  print("keyCode = ${rawKeyEventDataAndroid.keyCode}");
                  switch (rawKeyEventDataAndroid.keyCode) {
                    case KEY_CENTER:
                      _getIPAddress();
                      break;
                    default:
                      break;
                  }
                }
              },
              child: new RaisedButton(
                onPressed: _getIPAddress,
                color: _active ? Colors.lightGreen[700] : Colors.grey[600],
                child: new Text('Get IP address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}