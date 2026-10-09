import 'package:flutter/material.dart';

import '../../util/app_theme.dart';

/// A status bar entry: focus inverts it and reveals its label, and selecting
/// it asks the host to open the surface it stands for.
class TopBarWidget extends StatefulWidget {
  const TopBarWidget({
    super.key,
    required this.icon,
    required this.label,
    this.onSelect,
  });

  final IconData icon;
  final String label;

  /// Null leaves the entry inert, for a platform with no surface behind it.
  final VoidCallback? onSelect;

  @override
  State<TopBarWidget> createState() => TopBarWidgetState();
}

class TopBarWidgetState extends State<TopBarWidget> {
  bool _focused = false;

  /// Reports that the viewer activated this entry.
  void select() => widget.onSelect?.call();

  void setFocused(bool focused) {
    if (!mounted || _focused == focused) {
      return;
    }
    setState(() => _focused = focused);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _focused ? kFocusColor : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            widget.icon,
            size: 28.0,
            color: _focused ? Colors.white : Colors.grey,
          ),
          // The label only appears while focused, keeping the bar uncluttered.
          if (_focused) ...<Widget>[
            const SizedBox(width: 6.0),
            Text(widget.label, style: const TextStyle(color: Colors.white)),
          ],
        ],
      ),
    );
  }
}
