import 'package:flutter/material.dart';

import '../../model/common/poster.dart';
import '../../util/app_theme.dart';
import '../../util/focus_style.dart';
import '../../util/screen_util.dart';
import 'focus_block_widget.dart';

/// The large banner at the top of a tab.
///
/// Focusable like any tile, so the viewer can move down onto it from the rows
/// and select it directly.
///
/// The backdrop is painted and the artwork keeps its own shape in a panel
/// beside the title. Bundled artwork is tile-sized, so letting it fill a
/// banner magnifies it several times over and crops most of it away; a panel
/// shows all of it at close to the size it was drawn.
class FeaturedBanner extends StatelessWidget {
  const FeaturedBanner({
    super.key,
    required this.poster,
    required this.highlightStyle,
    required this.onSelect,
    required this.height,
    this.leadingInset = 60.0,
    this.artworkOnRight = false,
    this.artworkWidth = 420.0,
    this.artworkSize = const Size(312.0, 175.0),
    this.artworkIcon,
  });

  final Poster poster;
  final FocusHighlightStyle highlightStyle;
  final VoidCallback onSelect;
  final double height;
  final double leadingInset;
  final bool artworkOnRight;
  final double artworkWidth;
  final Size artworkSize;
  final IconData? artworkIcon;

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screen = ScreenUtil.of(context);
    final double inset = screen.w(32.0);
    final Widget artwork = SizedBox(
      width: screen.w(artworkWidth),
      child: Center(
        child: SizedBox(
          width: screen.w(artworkSize.width),
          height: screen.h(artworkSize.height),
          child: artworkIcon == null
              ? Image.asset(
                  poster.imageUrl,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                )
              : Icon(
                  artworkIcon,
                  color: Colors.white,
                  size: screen.w(112.0),
                ),
        ),
      ),
    );
    final Widget details = Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          left: artworkOnRight ? screen.w(8.0) : inset,
          right: inset,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              poster.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: screen.sp(52.0),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (poster.subtitle.isNotEmpty) ...<Widget>[
              SizedBox(height: screen.h(10.0)),
              Text(
                poster.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: screen.sp(24.0),
                ),
              ),
            ],
            if (poster.progress > 0.0) ...<Widget>[
              SizedBox(height: screen.h(16.0)),
              SizedBox(
                width: screen.w(360.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.0),
                  child: LinearProgressIndicator(
                    value: poster.progress.clamp(0.0, 1.0),
                    minHeight: 5.0,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      kProgressColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        screen.w(leadingInset),
        screen.h(16.0),
        screen.w(leadingInset),
        0.0,
      ),
      child: SizedBox(
        height: height,
        child: FocusBlockWidget(
          key: const ValueKey<String>('featured'),
          highlightStyle: highlightStyle,
          onSelect: onSelect,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: kFeaturedGradient),
              child: Row(
                children: <Widget>[
                  if ((poster.imageUrl.isNotEmpty || artworkIcon != null) &&
                      !artworkOnRight)
                    artwork,
                  details,
                  if ((poster.imageUrl.isNotEmpty || artworkIcon != null) &&
                      artworkOnRight)
                    artwork,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
