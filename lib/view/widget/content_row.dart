import 'package:flutter/material.dart';

import '../../model/common/poster.dart';
import '../../model/home/home_layout.dart';
import '../../util/focus_style.dart';
import '../../util/screen_util.dart';
import 'focus_block_widget.dart';
import 'poster_tile.dart';

/// A titled row of tiles that scrolls sideways.
///
/// Every tile is built eagerly rather than through a lazy sliver. The focus
/// search works off the element tree, so tiles that were never built would be
/// invisible to it and the focus could not reach them. A row holds a handful of
/// tiles, so building them all costs nothing.
class ContentRow extends StatelessWidget {
  const ContentRow({
    super.key,
    required this.row,
    required this.rowIndex,
    required this.layout,
    required this.controller,
    required this.highlightStyle,
    required this.onSelect,
  });

  final HomeRow row;
  final int rowIndex;
  final HomeLayout layout;

  /// Owns the horizontal scroll position of this row.
  final ScrollController controller;

  final FocusHighlightStyle highlightStyle;
  final void Function(Poster) onSelect;

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screen = ScreenUtil.of(context);

    return SizedBox(
      height: screen.h(layout.headingHeight + layout.tileHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: screen.h(layout.headingHeight),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: screen.w(layout.leadingInset),
                  bottom: screen.h(10.0),
                ),
                child: Text(
                  row.title,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screen.sp(28.0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: screen.h(layout.tileHeight),
            child: SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: screen.w(layout.leadingInset),
              ),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < row.items.length; i++) ...<Widget>[
                    if (i > 0) SizedBox(width: screen.w(layout.gapX)),
                    SizedBox(
                      width: screen.w(layout.tileWidth),
                      child: FocusBlockWidget(
                        key: ValueKey<String>('row${rowIndex}_tile$i'),
                        highlightStyle: highlightStyle,
                        onSelect: () => onSelect(row.items[i]),
                        child: PosterTile(
                          poster: row.items[i],
                          fontSize: screen.sp(18.0),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
