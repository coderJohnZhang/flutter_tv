import 'package:flutter/material.dart';

import '../../model/common/poster.dart';
import '../../util/app_theme.dart';

/// Shared look for a poster tile: artwork with a translucent title strip.
class PosterTile extends StatelessWidget {
  const PosterTile({
    super.key,
    required this.poster,
    this.width,
    this.height,
    this.fontSize = 20.0,
  });

  final Poster poster;

  /// Left unset the tile fills the constraints given by its parent.
  final double? width;
  final double? height;

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: Container(
        width: width,
        height: height,
        color: const Color(0xFF1A1A1A),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              poster.imageUrl,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: const Color(0xAE000000),
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  poster.title,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Resume position, as used on part-watched titles.
            if (poster.progress > 0.0)
              Align(
                alignment: Alignment.bottomLeft,
                child: FractionallySizedBox(
                  widthFactor: poster.progress.clamp(0.0, 1.0),
                  child: Container(height: 4.0, color: kProgressColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
