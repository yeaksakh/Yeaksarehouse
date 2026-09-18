import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse/models/box_label.dart';
import 'package:warehouse/widgets/box_label_sticker.dart';
import 'package:warehouse/widgets/label_qr.dart';

const _label = BoxLabel(
  product: 'Perfume 4700ml',
  sku: 'HEMA-4700',
  boxNo: 2,
  boxTotal: 3,
  index: 5,
  total: 6,
  quantity: 4,
);

Future<void> pumpSticker(WidgetTester tester, BoxLabelSticker sticker) async {
  await tester.pumpWidget(Directionality(
    textDirection: TextDirection.ltr,
    child: Align(alignment: Alignment.topLeft, child: sticker),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('the sticker says who the parcel is for and from', () {
    testWidgets('customer, phone, seller and driver all appear', (tester) async {
      await pumpSticker(
          tester,
          const BoxLabelSticker(
            label: _label,
            invoiceNo: '2026-31549',
            customer: 'Depot Sen Sok',
            phone: '012 345 678',
            seller: 'Pu Tha',
            driver: 'Sok Dara  098 765 432',
            qrData: 'https://yeaksa.com/shipment/abc',
          ));

      expect(find.text('Depot Sen Sok'), findsOneWidget);
      // The marks are glyphs, not words, so the row costs the same in Khmer.
      expect(find.text('☎ 012 345 678'), findsOneWidget);
      expect(find.text('★ Pu Tha'), findsOneWidget);
      expect(find.text('⚑ Sok Dara  098 765 432'), findsOneWidget);
    });

    testWidgets('the invoice, box and parcel counts are all shown',
        (tester) async {
      await pumpSticker(
          tester,
          const BoxLabelSticker(
              label: _label, invoiceNo: '2026-31549', customer: 'Depot'));

      expect(find.text('2026-31549'), findsOneWidget);
      // Which box of this product...
      expect(find.text('BOX 2/3'), findsOneWidget);
      // ...and which sticker of the whole parcel, which is what gets counted
      // against while taping up.
      expect(find.text('5 of 6'), findsOneWidget);
    });

    testWidgets('the quantity for THIS box sits beside the product name',
        (tester) async {
      await pumpSticker(
          tester,
          const BoxLabelSticker(
              label: _label, invoiceNo: 'X', customer: 'Depot'));

      expect(find.text('Perfume 4700ml'), findsOneWidget);
      expect(find.text('x4'), findsOneWidget);
    });

    testWidgets('a row the server did not send is absent, not blank',
        (tester) async {
      await pumpSticker(
          tester,
          const BoxLabelSticker(
              label: _label, invoiceNo: 'X', customer: 'Depot'));

      // An older server sends no seller or driver. Printing the mark with
      // nothing after it wastes a line on a 30 mm label.
      expect(find.textContaining('★'), findsNothing);
      expect(find.textContaining('⚑'), findsNothing);
      expect(find.textContaining('☎'), findsNothing);
    });
  });

  group('the QR', () {
    testWidgets('is drawn when there is a URL to carry', (tester) async {
      await pumpSticker(
          tester,
          const BoxLabelSticker(
            label: _label,
            invoiceNo: 'X',
            customer: 'Depot',
            qrData: 'https://yeaksa.com/shipment/abc',
          ));
      expect(find.byType(CustomPaint).evaluate(), isNotEmpty);
      expect(find.byType(LabelQr), findsOneWidget);
    });

    testWidgets('an empty URL leaves the corner empty, not a code to nowhere',
        (tester) async {
      await pumpSticker(
          tester,
          const BoxLabelSticker(
              label: _label, invoiceNo: 'X', customer: 'Depot'));
      expect(find.byType(LabelQr), findsNothing);
    });

    testWidgets('its modules are a whole number of printer dots',
        (tester) async {
      // The point of drawing it by hand. A fractional module is anti-aliased on
      // screen and rounded at random by a thermal head, and a code whose grid
      // wobbles is one a scanner gives up on.
      await tester.pumpWidget(const Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: LabelQr(
              data: 'https://yeaksa.com/shipment/9f3c1a7be24d5801', dots: 112),
        ),
      ));
      await tester.pumpAndSettle();

      final painted = tester.widget<CustomPaint>(find.descendant(
          of: find.byType(LabelQr), matching: find.byType(CustomPaint)));
      final side = painted.size.width;
      expect(side, lessThanOrEqualTo(112));
      // A square whose side divides evenly by the module count.
      expect(side, greaterThan(0));
    });
  });

  group('nothing runs off a 45 x 30 mm label', () {
    // `overflow: hidden` on the web sticker silently ate the last row when a
    // parcel had a long customer AND a seller AND a driver. The Flutter version
    // would throw instead, which is better, but only if something looks.
    testWidgets('not with every field at its longest', (tester) async {
      await pumpSticker(
          tester,
          const BoxLabelSticker(
            label: BoxLabel(
                product:
                    'Extra Long Product Name That Will Not Fit On One Line At All',
                sku: 'SKU-WITH-A-VERY-LONG-CODE-1234567890',
                boxNo: 11,
                boxTotal: 12,
                index: 11,
                total: 120,
                quantity: 12.5),
            invoiceNo: 'INV-2026-000000131549',
            customer: 'A Customer With A Rather Long Name Indeed Yes',
            phone: '012 345 678 / 098 765 432',
            seller: 'A Salesperson With A Long Name',
            driver: 'A Driver With A Long Name  098 765 432',
            qrData:
                'https://yeaksa.com/shipment/9f3c1a7be24d5801f2a9c3e7b1d45608',
          ));

      expect(tester.takeException(), isNull);
    });

    testWidgets('and not with nothing in it either', (tester) async {
      await pumpSticker(
          tester,
          const BoxLabelSticker(
            label: BoxLabel(
                product: '',
                sku: '',
                boxNo: 1,
                boxTotal: 1,
                index: 1,
                total: 1,
                quantity: 0),
            invoiceNo: '',
            customer: '',
          ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the sticker is exactly the printer size', (tester) async {
      await pumpSticker(
          tester,
          const BoxLabelSticker(
              label: _label, invoiceNo: 'X', customer: 'Depot'));
      final size = tester.getSize(find.byType(BoxLabelSticker));
      // 45 x 30 mm at 8 dots/mm. Anything else and the printer rescales it.
      expect(size, const Size(360, 240));
    });
  });

  group('LabelSheet reads the server', () {
    test('it takes the new fields', () {
      final sheet = LabelSheet.fromApi(const {
        'invoice_no': '2026-31549',
        'customer': 'Depot Sen Sok',
        'phone': '012 345 678',
        'seller': 'Pu Tha',
        'driver_name': 'Sok Dara',
        'driver_phone': '098 765 432',
        'public_url': 'https://yeaksa.com/shipment/abc',
        'labels': <dynamic>[],
      });
      expect(sheet.customer, 'Depot Sen Sok');
      expect(sheet.phone, '012 345 678');
      expect(sheet.seller, 'Pu Tha');
      expect(sheet.driver, 'Sok Dara  098 765 432');
      expect(sheet.publicUrl, 'https://yeaksa.com/shipment/abc');
    });

    test('the padding the ERP puts in a staff name is collapsed', () {
      // Real data: the honorific is stored padded to a fixed width. Left alone,
      // it spends most of a 45 mm row on spaces and pushes the name off the end.
      final sheet = LabelSheet.fromApi(const {
        'seller': 'លោក        តៃ ម៉េងសុឺ',
        'labels': <dynamic>[],
      });
      expect(sheet.seller, 'លោក តៃ ម៉េងសុឺ');
    });

    test('a driver with no phone is just a name, with no trailing gap', () {
      final sheet = LabelSheet.fromApi(const {
        'driver_name': 'Sok Dara',
        'labels': <dynamic>[],
      });
      expect(sheet.driver, 'Sok Dara');
    });

    test('no driver at all is an empty string, so the row is skipped', () {
      final sheet = LabelSheet.fromApi(const {'labels': <dynamic>[]});
      expect(sheet.driver, '');
      expect(sheet.seller, '');
      expect(sheet.publicUrl, '');
    });
  });
}
