import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse/models/box_label.dart';
import 'package:warehouse/widgets/box_label_sticker.dart';

/// Renders each sticker to `build/sticker_preview/` so a human can look at it.
///
/// DELIBERATELY NOT A GOLDEN TEST. A layout is judged by eye, and a golden would
/// fail on every font or Flutter upgrade without saying whether the result got
/// better or worse -- a test that cries wolf gets skipped, and then it is
/// protecting nothing. What is actually asserted lives in
/// `box_label_sticker_test.dart`: the rows are present, and nothing overflows.
///
///     flutter test test/sticker_preview_test.dart
///     # then open build/sticker_preview/*.png
///
/// The text comes out as boxes: the test environment has no real font. The
/// layout, the wrapping and the QR are still exactly what the printer gets, and
/// the placeholder glyphs are WIDER than real ones, so a sticker that fits here
/// fits on the label.
void main() {
  testWidgets('render every sticker shape for inspection', (tester) async {
    final dir = Directory('build/sticker_preview')..createSync(recursive: true);

    final cases = <String, BoxLabelSticker>{
      // What a real parcel looks like: Khmer throughout, every row filled.
      'full': const BoxLabelSticker(
        label: BoxLabel(
            product: 'ទឹកអប់ ហេម៉ាផ្លឹស 4700ml',
            sku: 'HEMA-4700',
            boxNo: 2,
            boxTotal: 3,
            index: 5,
            total: 6,
            quantity: 4),
        invoiceNo: '2026-31549',
        customer: 'ភឿ លី',
        phone: '010 266 564',
        company: 'ដេប៉ូ បន្ទាយមានជ័យ (ភឿ លី)',
        seller: 'តៃ ម៉េងសុឺ  077827492',
        driver: 'ពូ ថា  012-345-678',
        qrData: 'https://yeaksa.com/shipment/9f3c1a7be24d5801',
        stamps: [
          LabelStamp('ទទួល', 'លោក តៃ ម៉េងសុឺ'),
          LabelStamp('ខ្ចប់', 'លោកស្រី សាត់ ស្រីពេជ្រ'),
          LabelStamp('ពិនិត្យ', 'លោក យ៉ន សុវណ្ណារ៉ា'),
        ],
      ),
      // Everything too long at once, which is how a sticker loses its last row.
      'overlong': const BoxLabelSticker(
        label: BoxLabel(
            product: 'Extra Long Product Name That Will Not Fit On One Line',
            sku: 'SKU-WITH-A-LONG-CODE-12345',
            boxNo: 1,
            boxTotal: 1,
            index: 1,
            total: 12,
            quantity: 12),
        invoiceNo: 'INV-2026-000131549',
        customer: 'A Customer With A Rather Long Name Indeed',
        phone: '012 345 678 / 098 765 432',
        company: 'A Company Name That Goes On And On Depot Branch',
        seller: 'Salesperson With A Long Name  077 827 492',
        driver: 'Driver Name  098 765 432',
        qrData: 'https://yeaksa.com/shipment/9f3c1a7be24d5801',
        stamps: [
          LabelStamp('Taken', 'A Warehouse Person With A Long Name'),
          LabelStamp('Packed', 'Another Packer With A Long Name Here'),
          LabelStamp('Checked', 'A Supervisor With A Very Long Name'),
        ],
      ),
      // An older server sends none of the new fields. No QR, no blank gap.
      'bare': const BoxLabelSticker(
        label: BoxLabel(
            product: 'Soap',
            sku: '',
            boxNo: 1,
            boxTotal: 1,
            index: 1,
            total: 1,
            quantity: 1),
        invoiceNo: '2026-1',
        customer: 'Walk-in',
      ),
    };

    for (final entry in cases.entries) {
      final key = GlobalKey();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(key: key, child: entry.value),
        ),
      ));
      await tester.pumpAndSettle();

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;

      // `runAsync`: rasterising and PNG-encoding are real async work on the
      // engine, and a widget test's fake clock never advances far enough to
      // complete them -- the test hangs rather than fails, which is worse.
      late final ui.Image image;
      late final ByteData png;
      await tester.runAsync(() async {
        image = await boundary.toImage();
        png = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      });

      final file = File('${dir.path}/${entry.key}.png')
        ..writeAsBytesSync(png.buffer.asUint8List());

      expect(file.lengthSync(), greaterThan(0));
      expect(image.width, BoxLabelSticker.dots.width.toInt());
      expect(image.height, BoxLabelSticker.dots.height.toInt());
    }
  });
}
