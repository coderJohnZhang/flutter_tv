import 'package:flutter/material.dart';

import '../../util/app_theme.dart';
import '../../util/screen_util.dart';

/// A tab title in the header.
///
/// Two highlighted looks are needed: enlarged while the focus sits on the title
/// row, and enlarged while the focus is down in the content, which is what marks
/// the tab as the active one.
class TitleWidget extends StatefulWidget {
  const TitleWidget({super.key, required this.title});

  final String title;

  @override
  State<TitleWidget> createState() => TitleWidgetState();
}

class TitleWidgetState extends State<TitleWidget> {
  bool _focused = false;
  bool _compact = true;

  /// [focused] highlights this tab, [compact] keeps the smaller font size.
  void setFocus(bool focused, {bool compact = true}) {
    if (!mounted || (_focused == focused && _compact == compact)) {
      return;
    }
    setState(() {
      _focused = focused;
      _compact = compact;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screen = ScreenUtil.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screen.w(12.0),
        vertical: screen.h(8.0),
      ),
      child: Text(
        widget.title,
        style: TextStyle(
          color: _focused ? kFocusColor : Colors.grey,
          fontSize: screen.sp(_focused && !_compact ? 72.0 : 40.0),
          fontWeight: _focused ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
