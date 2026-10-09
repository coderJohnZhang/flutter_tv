import 'package:flutter/material.dart';

/// Accent used for every focus affordance: block borders, the focus box, tab
/// titles and status bar items.
const Color kFocusColor = Color(0xFFE53935);

/// The outline a focused block is drawn with, and the box that glides over it.
///
/// Both read these, so the block and the box describe the same rectangle in
/// the same colour: a viewer sees one frame, moving.
const double kFocusBorderWidth = 3.0;
const double kFocusBorderRadius = 6.0;

/// Backdrop of the featured banner.
///
/// Painted rather than photographic: the bundled backdrops are block-sized
/// tiles, and spreading one across a full-width banner magnifies it several
/// times over.
const LinearGradient kFeaturedGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: <Color>[Color(0xFF262832), Color(0xFF101116)],
);

/// Accent of the resume progress bar shown on part-watched titles.
const Color kProgressColor = Color(0xFF8AB4F8);

/// Dark TV theme. Material 3 is on, so the scheme is derived from the accent
/// rather than from a legacy swatch.
ThemeData buildLauncherTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: kFocusColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.black,
  );
}
