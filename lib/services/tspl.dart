import 'dart:typed_data';

import 'label_bitmap.dart';

/// TSPL, the language label printers speak.
///
/// WHY THIS EXISTS AT ALL. The app used to send every sticker with
/// `printImageBytes`, which is ESC/POS raster -- the language of till printers
/// like the one in Yeaksaundry. A label printer is a different machine: it
/// knows where the gaps between labels are, and it wants to be told the label's
/// size before it is given anything to draw. Sent ESC/POS, the usual outcome is
/// that nothing comes out at all, because the bytes are not a command it knows
/// and it never gets told to feed a label.
///
/// The command stream is plain ASCII lines, CRLF-terminated, except for the
/// bitmap payload which is raw binary sitting in the middle of the `BITMAP`
/// line. That is why this builds a byte list rather than a string.
class Tspl {
  const Tspl._();

  /// These heads are 203 dpi, which is 8 dots to the millimetre. The sticker is
  /// rendered at 360 x 240 dots for exactly this reason.
  static const dotsPerMm = 8;

  /// One label: set the stock up, clear the buffer, place the image, print it.
  ///
  /// [gapMm] is the gap between labels on the roll, which is what the printer
  /// uses to find the top of the next one. 2 mm is the usual die-cut gap; a
  /// printer told the wrong gap either feeds a blank label between each or
  /// creeps up the roll until the text runs off the edge.
  static Uint8List label(
    MonoBitmap bitmap, {
    double? widthMm,
    double? heightMm,
    double gapMm = 2,
    int copies = 1,
  }) {
    final w = widthMm ?? bitmap.width / dotsPerMm;
    final h = heightMm ?? bitmap.height / dotsPerMm;

    final out = BytesBuilder();
    void line(String text) => out.add(ascii(text));

    line('SIZE ${_mm(w)} mm,${_mm(h)} mm');
    line('GAP ${_mm(gapMm)} mm,0 mm');
    // 1 puts the origin at the top-left of the label as it comes out, so the
    // sticker reads the right way up when it is torn off.
    line('DIRECTION 1');
    line('REFERENCE 0,0');
    // Without CLS the previous label's image is still in the buffer and the two
    // print on top of each other.
    line('CLS');

    // The header is text, the payload is binary, and there is no length field:
    // the printer reads exactly rowBytes * height bytes starting at the byte
    // after the comma. So NO line ending here -- a CRLF would be swallowed as
    // the first two bytes of the image, shifting every row and dropping the
    // last two. The terminator goes after the payload instead.
    out.add(_raw('BITMAP 0,0,${bitmap.rowBytes},${bitmap.height},0,'));
    out.add(bitmap.bytes);
    out.add(_crlf);

    line('PRINT 1,$copies');
    return out.toBytes();
  }

  /// A label with nothing on it but a frame and a word, for proving the printer
  /// speaks TSPL at all. Drawn with TSPL's own commands rather than a bitmap so
  /// that it still works when the bitmap packing is what is broken.
  static Uint8List testLabel({
    double widthMm = 45,
    double heightMm = 30,
    double gapMm = 2,
    String text = 'TSPL OK',
  }) {
    final out = BytesBuilder();
    void line(String t) => out.add(ascii(t));

    final wDots = (widthMm * dotsPerMm).round();
    final hDots = (heightMm * dotsPerMm).round();

    line('SIZE ${_mm(widthMm)} mm,${_mm(heightMm)} mm');
    line('GAP ${_mm(gapMm)} mm,0 mm');
    line('DIRECTION 1');
    line('REFERENCE 0,0');
    line('CLS');
    // A frame proves the whole label area is reachable, not just the middle.
    line('BOX 8,8,${wDots - 8},${hDots - 8},3');
    line('TEXT 30,${(hDots / 2).round() - 24},"3",0,1,1,"$text"');
    line('PRINT 1,1');
    return out.toBytes();
  }

  /// TSPL takes at most one decimal place and chokes on a trailing `.0`.
  static String _mm(double value) {
    final rounded = (value * 10).round() / 10;
    return rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toString();
  }

  /// ASCII bytes plus CRLF. The printer's parser wants both; LF alone leaves it
  /// waiting for the rest of the line and nothing prints.
  static Uint8List ascii(String text) =>
      Uint8List.fromList([...text.codeUnits, 0x0D, 0x0A]);

  /// ASCII with NO line ending, for the one place that must not have one.
  static Uint8List _raw(String text) => Uint8List.fromList(text.codeUnits);

  static final _crlf = Uint8List.fromList([0x0D, 0x0A]);
}
