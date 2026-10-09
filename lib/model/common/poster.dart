/// A focusable tile: launcher artwork with a title, and optionally a subtitle
/// and a playback progress fraction.
///
/// Positions are not stored here. Tiles are laid out by the row widget and the
/// focus engine reads their real bounds from the render tree, so a tile never
/// needs to know where it ended up.
class Poster {
  const Poster({
    this.blockId = 0,
    this.title = '',
    this.subtitle = '',
    this.imageUrl = '',
    this.progress = 0.0,
  });

  final int blockId;
  final String title;

  /// Shown under the title on the featured banner.
  final String subtitle;

  final String imageUrl;

  /// Resume position in the range 0..1. Zero hides the progress bar.
  final double progress;
}
