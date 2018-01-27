import 'package:flutter/material.dart';
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
    print('TvAppWidget screenSize = $screenSize devicePixelRatio = $devicePixelRatio');
    return new PosterDemo(
      screenSize: screenSize,
    );
  }
}