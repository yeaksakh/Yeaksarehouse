import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse/models/box_label.dart';

void main() {
  group('BoxLabel from the API', () {
    test('reads every field', () {
      final l = BoxLabel.fromApi(const {
        'product': ' Soap 1000ml ',
        'sku': ' SKU-1 ',
        'box_no': 2,
        'box_total': 3,
        'index': 5,
        'total': 6,
      });

      expect(l.product, 'Soap 1000ml');
      expect(l.sku, 'SKU-1');
      expect(l.boxOfBox, '2/3');
      expect(l.indexOfTotal, '5 of 6');
    });

    test('a missing count falls back to one, never zero', () {
      // A sticker saying "box 0/0" tells a picker nothing, and a parcel with no
      // sticker at all is worse than one with a dull sticker.
      final l = BoxLabel.fromApi(const {'product': 'X'});
      expect(l.boxOfBox, '1/1');
      expect(l.indexOfTotal, '1 of 1');
    });

    test('survives a null product and sku', () {
      final l = BoxLabel.fromApi(const {'product': null, 'sku': null});
      expect(l.product, '');
      expect(l.sku, '');
    });
  });

  group('LabelSheet', () {
    test('reads the whole parcel', () {
      final sheet = LabelSheet.fromApi(const {
        'invoice_no': 'POS-1',
        'customer': 'Dara Shop',
        'labels': [
          {'product': 'Soap', 'box_no': 1, 'box_total': 2, 'index': 1, 'total': 2},
          {'product': 'Soap', 'box_no': 2, 'box_total': 2, 'index': 2, 'total': 2},
        ],
      });

      expect(sheet.invoiceNo, 'POS-1');
      expect(sheet.customer, 'Dara Shop');
      expect(sheet.labels, hasLength(2));
      expect(sheet.isEmpty, isFalse);
    });

    test('a parcel with nothing to label reads as empty', () {
      final sheet = LabelSheet.fromApi(const {'invoice_no': 'POS-1', 'labels': []});
      expect(sheet.isEmpty, isTrue);
    });

    test('missing labels key is empty, not a crash', () {
      expect(LabelSheet.fromApi(const {'invoice_no': 'X'}).isEmpty, isTrue);
    });
  });
}
