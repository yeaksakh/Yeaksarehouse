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
            company: 'Depot Banteay Meanchey',
            seller: 'Pu Tha  077 827 492',
            driver: 'Sok Dara  098 765 432',
            qrData: 'https://yeaksa.com/shipment/abc',
          ));

      expect(find.text('Depot Sen Sok'), findsOneWidget);
      expect(find.text('Depot Banteay Meanchey'), findsOneWidget);
      // The marks are glyphs, not words, so the row costs the same in Khmer.
      expect(find.text('☎ 012 345 678'), findsOneWidget);
      expect(find.text('★ Pu Tha  077 827 492'), findsOneWidget);
      expect(find.text('⚑ Sok Dara  098 765 432'), findsOneWidget);
    });

    testWidgets('the customer and the phone are the biggest rows',
        (tester) async {
      // A driver reads these at the gate. They are deliberately larger than the
      // product and SKU above them, and a later tidy-up must not level them.
      await pumpSticker(
          tester,
          const BoxLabelSticker(
            label: _label,
            invoiceNo: 'X',
            customer: 'Depot Sen Sok',
            phone: '012 345 678',
            seller: 'Pu Tha  077 827 492',
          ));

      double sizeOf(Finder f) => tester.widget<Text>(f).style!.fontSize!;
      final customer = sizeOf(find.text('Depot Sen Sok'));
      final phone = sizeOf(find.text('☎ 012 345 678'));
      final seller = sizeOf(find.text('★ Pu Tha  077 827 492'));
      final sku = sizeOf(find.text('HEMA-4700'));

      expect(customer, greaterThan(sku));
      expect(phone, greaterThan(sku));
      expect(seller, greaterThan(sku));
      expect(customer, greaterThanOrEqualTo(phone));
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

    testWidgets('no company means no company row', (tester) async {
      await pumpSticker(
          tester,
          const BoxLabelSticker(
              label: _label,
              invoiceNo: 'X',
              customer: 'Depot Sen Sok',
              phone: '012 345 678'));
      // The customer's name, and nothing pretending to be a business under it.
      expect(find.text('Depot Sen Sok'), findsOneWidget);
      expect(find.text('Depot Banteay Meanchey'), findsNothing);
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
            acceptedBy: 'A Warehouse Person With A Very Long Name',
            packedBy: 'Another Packer With A Very Long Name',
            auditedBy: 'A Supervisor With A Very Long Name',
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

  group('the warehouse trail', () {
    testWidgets('each stage is printed with who did it', (tester) async {
      await pumpSticker(
          tester,
          const BoxLabelSticker(
            label: _label,
            invoiceNo: 'X',
            customer: 'Depot',
            acceptedBy: 'តៃ ម៉េងសុឺ',
            packedBy: 'សាត់ ស្រីពេជ្រ',
            auditedBy: 'យ៉ន សុវណ្ណារ៉ា',
          ));

      // A name and an icon, with no worded label to translate or to pay for.
      expect(find.text('តៃ ម៉េងសុឺ'), findsOneWidget);
      expect(find.text('សាត់ ស្រីពេជ្រ'), findsOneWidget);
      expect(find.text('យ៉ន សុវណ្ណារ៉ា'), findsOneWidget);
      expect(find.byIcon(Icons.how_to_reg), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('a shipment nobody has touched yet prints no trail',
        (tester) async {
      await pumpSticker(
          tester,
          const BoxLabelSticker(
              label: _label, invoiceNo: 'X', customer: 'Depot'));
      expect(find.byIcon(Icons.how_to_reg), findsNothing);
      expect(find.byIcon(Icons.inventory_2), findsNothing);
      expect(find.byIcon(Icons.verified), findsNothing);
    });

    testWidgets('the trail is the smallest thing on the sticker',
        (tester) async {
      // It is provenance, read later at a desk when something is queried --
      // not at the gate. It must never take size from the customer row.
      await pumpSticker(
          tester,
          const BoxLabelSticker(
            label: _label,
            invoiceNo: 'X',
            customer: 'Depot Sen Sok',
            acceptedBy: 'តៃ ម៉េងសុឺ',
          ));

      double sizeOf(Finder f) => tester.widget<Text>(f).style!.fontSize!;
      expect(sizeOf(find.text('តៃ ម៉េងសុឺ')),
          lessThan(sizeOf(find.text('Depot Sen Sok'))));
    });
  });

  group('LabelSheet reads the server', () {
    test('it takes the new fields', () {
      final sheet = LabelSheet.fromApi(const {
        'invoice_no': '2026-31549',
        'customer': 'Depot Sen Sok',
        'phone': '012 345 678',
        'seller': 'Pu Tha',
        'seller_phone': '077 827 492',
        'company': 'Depot Banteay Meanchey',
        'accepted_by': 'Tai Meng Seu',
        'packed_by': 'Sat Sreypich',
        'audited_by': 'Yon Sovannara',
        'driver_name': 'Sok Dara',
        'driver_phone': '098 765 432',
        'public_url': 'https://yeaksa.com/shipment/abc',
        'labels': <dynamic>[],
      });
      expect(sheet.customer, 'Depot Sen Sok');
      expect(sheet.phone, '012 345 678');
      expect(sheet.seller, 'Pu Tha');
      expect(sheet.sellerLine, 'Pu Tha  077 827 492');
      expect(sheet.company, 'Depot Banteay Meanchey');
      expect(sheet.driver, 'Sok Dara  098 765 432');
      expect(sheet.publicUrl, 'https://yeaksa.com/shipment/abc');
      expect(sheet.acceptedBy, 'Tai Meng Seu');
      expect(sheet.packedBy, 'Sat Sreypich');
      expect(sheet.auditedBy, 'Yon Sovannara');
    });

    test('the padding in a status-log name is collapsed too', () {
      // Real: the log stores 'លោកស្រី    សាត់ ស្រីពេជ្រ'.
      final sheet = LabelSheet.fromApi(const {
        'packed_by': 'លោកស្រី    សាត់ ស្រីពេជ្រ',
        'labels': <dynamic>[],
      });
      expect(sheet.packedBy, 'លោកស្រី សាត់ ស្រីពេជ្រ');
    });

    test('a stage nobody has done yet is empty, so its row is dropped', () {
      final sheet = LabelSheet.fromApi(const {'labels': <dynamic>[]});
      expect(sheet.acceptedBy, '');
      expect(sheet.packedBy, '');
      expect(sheet.auditedBy, '');
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

    test('a seller with no number on file is just a name', () {
      // Only 323 of 16,898 users have a phone recorded, so this is the common
      // case, not the edge one.
      final sheet = LabelSheet.fromApi(const {
        'seller': 'តៃ ម៉េងសុឺ',
        'labels': <dynamic>[],
      });
      expect(sheet.sellerLine, 'តៃ ម៉េងសុឺ');
    });

    test('the server decides whether there is a company, not the app', () {
      // `company_for` on the server already dropped the blank, duplicate and
      // phone-number cases; the app prints what it is given.
      final sheet = LabelSheet.fromApi(const {'labels': <dynamic>[]});
      expect(sheet.company, '');
    });
  });
}
