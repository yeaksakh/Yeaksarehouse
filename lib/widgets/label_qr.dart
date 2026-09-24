import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// A QR code drawn so that every module lands on a whole printer dot.
///
/// WHY NOT AN OFF-THE-SHELF QR WIDGET. Those scale the code to fill whatever box
/// they are given, so a 29-module code in a 100-dot square gets modules 3.44
/// dots wide. On a screen the fractional part is anti-aliased and looks fine; a
/// thermal head has no grey, so it rounds each edge independently and the
/// modules come out 3 or 4 dots at random. A scanner reading a code whose grid
/// wobbles by a third of a module either takes several seconds or gives up.
///
/// So the module size is an INTEGER number of dots, computed from the space
/// available, and the code is centred in whatever is left over. A slightly
/// smaller code that scans beats a slightly larger one that does not.
class LabelQr extends StatelessWidget {
  const LabelQr({super.key, required this.data, required this.dots});

  /// What the code carries. Usually the shipment's public URL.
  final String data;

  /// The side of the square this has to fit inside, in printer dots.
  final double dots;

  /// The white margin a scanner needs to find the code at all, in modules.
  /// Four is what the QR specification asks for; below that, a code printed
  /// hard against a product name is measurably slower to read.
  static const quietModules = 4;

  /// Error correction. M survives a scuffed or partly peeled sticker, which is
  /// the normal state of a label by the time it reaches a customer, and costs
  /// only a few modules over L.
  static const errorCorrection = QrErrorCorrectLevel.M;

  @override
  Widget build(BuildContext context) {
    // An empty string still produces a valid (tiny) code, which would be a
    // scannable link to nothing. Better to leave the space blank.
    if (data.isEmpty) return SizedBox(width: dots, height: dots);

    final image = QrImage(
        QrCode.fromData(data: data, errorCorrectLevel: errorCorrection));
    final across = image.moduleCount + quietModules * 2;
    final module = (dots / across).floor();

    // Too small to be read at all -- better an empty corner than a code that
    // wastes a packer's time. 2 dots at 8 dots/mm is a 0.25 mm module, already
    // at the limit of what these heads resolve.
    if (module < 2) return SizedBox(width: dots, height: dots);

    return SizedBox(
      width: dots,
      height: dots,
      child: Center(
        child: CustomPaint(
          size: Size.square((module * across).toDouble()),
          painter: _QrPainter(image, module.toDouble()),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  const _QrPainter(this.image, this.module);

  final QrImage image;
  final double module;

  @override
  void paint(Canvas canvas, Size size) {
    // The quiet zone is part of the code, not a gap around it: the sticker
    // behind may well be dark, so the white is painted rather than assumed.
    final white = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, white);

    final black = Paint()
      ..color = Colors.black
      // Filled, not stroked, and never anti-aliased: a half-lit dot is a dot
      // this printer will decide about on its own.
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final offset = LabelQr.quietModules * module;
    for (var row = 0; row < image.moduleCount; row++) {
      for (var col = 0; col < image.moduleCount; col++) {
        if (!image.isDark(row, col)) continue;
        canvas.drawRect(
          Rect.fromLTWH(offset + col * module, offset + row * module,
              module, module),
          black,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) =>
      old.image != image || old.module != module;
}
