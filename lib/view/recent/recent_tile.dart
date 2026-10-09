import 'package:flutter/material.dart';

import '../../model/common/poster.dart';
import '../../util/focus_style.dart';
import '../../util/screen_util.dart';
import '../widget/focus_block_widget.dart';
import '../widget/poster_tile.dart';

/// One entry of the history, with the mark that removing it needs.
///
/// The history is the only tab a viewer edits, and editing has to be reachable
/// with a remote. While the tab is in delete mode a mark is drawn on the tile,
/// so the viewer can see what they are about to lose before they confirm.
class RecentTile extends StatelessWidget {
  const RecentTile({
    super.key,
    required this.poster,
    required this.highlightStyle,
    required this.marked,
    required this.deleteMode,
    required this.onSelect,
  });

  final Poster poster;
  final FocusHighlightStyle highlightStyle;

  /// True when the entry is marked for removal.
  final bool marked;

  /// True while the tab is asking the viewer to mark entries.
  final bool deleteMode;

  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final double unit = ScreenUtil.of(context).w(1.0);

    return FocusBlockWidget(
      highlightStyle: highlightStyle,
      onSelect: onSelect,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(5.0 * unit),
            child: PosterTile(
              poster: poster,
              fontSize: ScreenUtil.of(context).sp(18.0),
            ),
          ),
          if (marked)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent, width: 3.0 * unit),
              ),
            ),
          if (deleteMode)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(10.0 * unit),
                child: Icon(
                  marked ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 28.0 * unit,
                  color: marked ? Colors.redAccent : Colors.white70,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
