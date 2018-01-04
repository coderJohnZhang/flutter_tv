import 'package:flutter/material.dart';

class Page4Widget extends StatefulWidget {
  @override
  Page4WidgetState createState() => new Page4WidgetState();
}

class Page4WidgetState extends State<Page4Widget> {
  @override
  Widget build(BuildContext context) {
    var container = new Container(
        decoration: new BoxDecoration(
          image: const DecorationImage(
              fit: BoxFit.fill,
              image: const AssetImage('images/launcher/main_bg.jpg')),
        ),
        child: new Row(children: [
          new Expanded(
              child: buildPost('images/launcher/ic_post_1.jpg', 'Warcraft',
                  100.0, 360.0, 600.0, 600.0)),
          new Expanded(
              child: new Column(children: [
            new Expanded(
                child: buildPost('images/launcher/ic_post_8.jpg',
                    'The Revenant', 80.0, 160.0, 600.0, 300.0)),
            new Expanded(
                child: buildPost('images/launcher/ic_post_3.jpg',
                    'Alice\'s Adventures', 70.0, 160.0, 600.0, 300.0))
          ])),
          new Expanded(
              child: new Column(children: [
            new Expanded(
                child: buildPost('images/launcher/ic_post_2.jpg',
                    'Big Fish & Begonia', 70.0, 160.0, 600.0, 300.0)),
            new Expanded(
                child: buildPost('images/launcher/ic_post_4.jpg',
                    'Cold War', 100.0, 160.0, 600.0, 300.0))
          ]))
        ]));
    return container;
  }

  Container buildPost(String imgPath, String text, double left, double top,
      double width, double height) {
    return new Container(
        margin: const EdgeInsets.all(5.0),
        child: new Stack(children: <Widget>[
          new Container(
              width: width,
              height: height,
              child: new Image.asset(imgPath, fit: BoxFit.fill)),
          new Positioned(
              left: left,
              top: top,
              child: new Container(
                decoration: new BoxDecoration(color: Colors.black),
                child: new Text(
                  text,
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontFamily: 'serif',
                  ),
                ),
              )),
        ]));
  }
}
