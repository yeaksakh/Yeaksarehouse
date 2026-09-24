import 'dart:typed_data';

/// A sticker reduced to one bit per dot, which is all a thermal head can take.
///
/// WHY A BIT IS 0 FOR BLACK. This is packed the way TSPL's `BITMAP` command
/// wants it, and TSPL is the opposite of everyone else: a `0` bit burns a dot
/// and a `1` bit leaves the label blank. Getting it backwards does not produce
/// a subtly wrong label, it produces a solid black one that eats a whole roll
/// before anybody can stop it, so the convention lives here in one place with
/// a test on it rather than inline at the call site.
///
/// ESC/POS wants the opposite, so [inverted] exists for that path.
class MonoBitmap {
  const MonoBitmap({
    required this.width,
    required this.height,
    required this.bytes,
  });

  /// Dots across and down. Not bytes -- [rowBytes] is the byte count.
  final int width;
  final int height;

  /// `rowBytes * height`, row by row from the top, MSB is the leftmost dot.
  final Uint8List bytes;

  /// Rows are padded out to a whole byte; a 360-dot row is 45 bytes exactly,
  /// but nothing guarantees a multiple of eight and a half-packed row would
  /// shear the image diagonally.
  int get rowBytes => (width + 7) >> 3;

  /// Pack raw RGBA (four bytes a pixel, as `toByteData` hands it over).
  ///
  /// [threshold] is compared against luminance. The sticker is drawn pure black
  /// on white so almost every pixel is at one end or the other; the threshold
  /// only decides what happens to the grey fringe of anti-aliased text, and
  /// halfway is the honest place to put it.
  factory MonoBitmap.fromRgba(
    Uint8List rgba, {
    required int width,
    required int height,
    int threshold = 128,
  }) {
    final expected = width * height * 4;
    if (rgba.length < expected) {
      throw ArgumentError(
          'Expected $expected bytes of RGBA for ${width}x$height, got ${rgba.length}');
    }

    final rowBytes = (width + 7) >> 3;
    // 0xFF: every dot starts blank, so the padding at the end of a short row is
    // already right and only the dots we actually burn get cleared.
    final out = Uint8List(rowBytes * height)..fillRange(0, rowBytes * height, 0xFF);

    for (var y = 0; y < height; y++) {
      final rowStart = y * rowBytes;
      for (var x = 0; x < width; x++) {
        final p = (y * width + x) * 4;
        final a = rgba[p + 3];
        // Transparent means nothing was drawn there, which is white, not black.
        if (a < 128) continue;
        // Rec. 601 luma, integer: the eye is far more sensitive to green, and a
        // flat average turns mid-green text into speckle.
        final luma = (rgba[p] * 299 + rgba[p + 1] * 587 + rgba[p + 2] * 114) ~/ 1000;
        if (luma >= threshold) continue;
        out[rowStart + (x >> 3)] &= ~(0x80 >> (x & 7)) & 0xFF;
      }
    }
    return MonoBitmap(width: width, height: height, bytes: out);
  }

  /// The same image with 1 meaning "burn", which is what ESC/POS raster wants.
  MonoBitmap get inverted => MonoBitmap(
        width: width,
        height: height,
        bytes: Uint8List.fromList([for (final b in bytes) ~b & 0xFF]),
      );

  /// True if the dot at [x],[y] is burnt. For tests and for nothing else.
  bool isBlack(int x, int y) =>
      (bytes[y * rowBytes + (x >> 3)] & (0x80 >> (x & 7))) == 0;
}
