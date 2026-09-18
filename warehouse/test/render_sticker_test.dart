import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse/models/box_label.dart';
import 'package:warehouse/widgets/box_label_sticker.dart';

BoxLabelSticker sticker(int n) => BoxLabelSticker(
      label: BoxLabel(
          product: 'Soap 1000ml',
          sku: 'SKU-$n',
          boxNo: n,
          boxTotal: 6,
          index: n,
          total: 6,
          quantity: 4),
      invoiceNo: 'POS-2026-1',
      customer: 'Dara Shop',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('renders one sticker to PNG bytes', () async {
    final png = await renderSticker(sticker(1));
    expect(png.length, greaterThan(100));
    // PNG magic number, so we know it is really an image.
    expect(png.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
  });

  test('renders SIX in a row -- a parcel is rarely one box', () async {
    // The real path loops over every label in the shipment. If the renderer can
    // only be used once, printing works for a single-box parcel and fails on
    // the second sticker of every other one.
    for (var i = 1; i <= 6; i++) {
      final png = await renderSticker(sticker(i));
      expect(png.length, greaterThan(100), reason: 'sticker $i');
    }
  });
}
