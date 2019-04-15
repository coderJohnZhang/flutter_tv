import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'key_code.dart';

class PlatformChannel extends StatefulWidget {
  @override
  _PlatformChannelState createState() => new _PlatformChannelState();
}

class _PlatformChannelState extends State<PlatformChannel> {
  static const MethodChannel methodChannel =
      const MethodChannel('samples.flutter.io/battery');
  static const EventChannel eventChannel =
      const EventChannel('samples.flutter.io/charging');

  String _batteryLevel = 'Battery level: unknown.';
  String _chargingStatus = 'Battery status: unknown.';
  FocusNode focusNode;
  bool _active = false;

  _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await methodChannel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level: $result%.';
    } on PlatformException {
      batteryLevel = 'Failed to get battery level.';
    }
    setState(() {
      _batteryLevel = batteryLevel;
      _active = !_active;
    });
  }

  @override
  void initState() {
    super.initState();
    focusNode = new FocusNode();
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void _onEvent(Object event) {
    setState(() {
      _chargingStatus =
          "Battery status: ${event == 'charging' ? '' : 'dis'}charging.";
    });
  }

  void _onError(Object error) {
    setState(() {
      _chargingStatus = 'Battery status: unknown.';
    });
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode);
    return new Scaffold(
        appBar: new AppBar(title: new Text('Platform Demo')),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(_batteryLevel,
                      key: const Key('Battery level label')),
                  new Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: new RawKeyboardListener(
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
                              _getBatteryLevel();
                              break;
                            default:
                              break;
                          }
                        }
                      },
                      child: new RaisedButton(
                        child: const Text('Refresh'),
                        color:
                            _active ? Colors.lightGreen[700] : Colors.grey[600],
                        onPressed: _getBatteryLevel,
                      ),
                    ),
                  ),
                ],
              ),
              new Text(_chargingStatus),
            ],
          ),
        ));
  }
}
