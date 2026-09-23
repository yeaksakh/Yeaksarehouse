import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';

import 'label_bitmap.dart';
import 'label_printer.dart';
import 'tspl.dart';

/// The server's label PDF, one page per sticker, turned into printer dots.
///
/// WHY THE PDF AND NOT THE PHONE'S OWN DRAWING. "Save as PDF" and the
/// Bluetooth printer used to draw the sticker twice -- the server's template
/// for the PDF, `BoxLabelSticker` for the printer -- and the two drifted apart.
/// Rasterising the very PDF the packer can save means the printed sticker is
/// that PDF, dot for dot, and there is one layout to keep correct.
///
/// Each page is rendered at the head's own resolution (8 dots/mm, 203.2 dpi),
/// so a 45 x 30 mm page comes out as 360 x 240 dots and [Tspl.label] tells the
/// printer the label is the page's own size.
Future<List<RenderedSticker>> stickersFromPdf(Uint8List pdf) async {
  const dpi = Tspl.dotsPerMm * 25.4;
  final out = <RenderedSticker>[];
  await for (final page in Printing.raster(pdf, dpi: dpi)) {
    debugPrint('Label PDF page ${out.length + 1}: '
        '${page.width}x${page.height} dots '
        '(${(page.width / Tspl.dotsPerMm).toStringAsFixed(1)} x '
        '${(page.height / Tspl.dotsPerMm).toStringAsFixed(1)} mm)');
    out.add(RenderedSticker(
      mono: MonoBitmap.fromRgba(page.pixels,
          width: page.width, height: page.height),
      png: await page.toPng(),
    ));
  }
  return out;
}
