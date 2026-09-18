/// One sticker for one box.
///
/// The server decides how many of these a shipment needs and what is on each --
/// see `core/api/shipment_labels.py` -- so both printing paths (the PDF the
/// system print dialog takes, and the raster a Bluetooth thermal printer takes)
/// agree on the arithmetic. Only the drawing differs.
class BoxLabel {
  const BoxLabel({
    required this.product,
    required this.sku,
    required this.boxNo,
    required this.boxTotal,
    required this.index,
    required this.total,
    required this.quantity,
  });

  final String product;
  final String sku;

  /// Which box of this product, and how many that product needs.
  final int boxNo;
  final int boxTotal;

  /// Which sticker of the WHOLE parcel. This is what the packer counts against
  /// while taping up: four boxes of soap and two of bleach is six stickers, and
  /// they need to know they have all six.
  final int index;
  final int total;

  /// How many units go in THIS box -- a full box everywhere except the last,
  /// which takes the remainder. Ten bottles four to a box is 4, 4, 2, and a
  /// packer looking for a fourth bottle that does not exist is how a parcel
  /// ends up held open on the bench.
  final double quantity;

  /// "4" or "2.5" -- trailing zeros dropped, because the ERP sells by weight
  /// and length as well as by the piece.
  String get quantityLabel => quantity == quantity.roundToDouble()
      ? quantity.toStringAsFixed(0)
      : quantity.toString();

  /// "2/3" -- this box within its product.
  String get boxOfBox => '$boxNo/$boxTotal';

  /// "5 of 6" -- this sticker within the parcel.
  String get indexOfTotal => '$index of $total';

  factory BoxLabel.fromApi(Map<String, dynamic> json) => BoxLabel(
        product: (json['product'] as String?)?.trim() ?? '',
        sku: (json['sku'] as String?)?.trim() ?? '',
        boxNo: (json['box_no'] as num?)?.toInt() ?? 1,
        boxTotal: (json['box_total'] as num?)?.toInt() ?? 1,
        index: (json['index'] as num?)?.toInt() ?? 1,
        total: (json['total'] as num?)?.toInt() ?? 1,
        // Older servers do not send this; one unit is the safe reading, since
        // a sticker claiming zero tells the packer nothing.
        quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      );
}

/// Every sticker for one shipment, plus what goes on all of them.
class LabelSheet {
  const LabelSheet({
    required this.invoiceNo,
    required this.customer,
    required this.labels,
    this.phone = '',
    this.company = '',
    this.seller = '',
    this.sellerPhone = '',
    this.driverName = '',
    this.driverPhone = '',
    this.publicUrl = '',
  });

  final String invoiceNo;
  final String customer;
  final List<BoxLabel> labels;

  final String phone;

  /// The customer's business, when the ERP actually holds one. The server
  /// decides that -- `shipment_labels.company_for` -- because the column it
  /// comes from is blank, or a copy of the name, or a phone number on about
  /// four rows in ten, and none of those are worth a line on a 45 mm sticker.
  final String company;

  /// Who sold it and who is taking it. Both are on the website's sticker, so
  /// they are on this one: a parcel whose two labels disagree is a parcel
  /// somebody has to stop and ask about.
  final String seller;
  final String sellerPhone;
  final String driverName;
  final String driverPhone;

  /// What the QR carries -- the shipment's public page, the same URL the
  /// website's QR encodes, so a sticker printed from either scans to the same
  /// place.
  final String publicUrl;

  bool get isEmpty => labels.isEmpty;

  /// "Sok Dara 012 345 678", or just the name, or nothing at all. Built here
  /// rather than in the sticker so the two printing paths cannot drift.
  String get driver => _withPhone(driverName, driverPhone);

  /// "តៃ ម៉េងសុឺ 077827492", or just the name when there is no number.
  String get sellerLine => _withPhone(seller, sellerPhone);

  /// Two spaces, not one: on a printed label a single space between a name and
  /// a number reads as one long string.
  static String _withPhone(String name, String phone) =>
      [name, phone].where((part) => part.isNotEmpty).join('  ');

  /// Runs of whitespace collapse to one space.
  ///
  /// The ERP stores staff names with the honorific padded out to a fixed width
  /// -- 'លោក        តៃ ម៉េងសុឺ' is what the server really sends -- which on a
  /// 45 mm sticker spends most of the row on nothing and pushes the name off
  /// the end. Harmless on a desktop, which is why it survived this long.
  static final _runOfSpace = RegExp(r'\s+');

  factory LabelSheet.fromApi(Map<String, dynamic> json) {
    String text(String key) =>
        ((json[key] as String?) ?? '').replaceAll(_runOfSpace, ' ').trim();
    return LabelSheet(
      invoiceNo: text('invoice_no'),
      customer: text('customer'),
      phone: text('phone'),
      // All five are absent on an older server, and an empty line is the right
      // answer there: the sticker simply does not show the row.
      company: text('company'),
      seller: text('seller'),
      sellerPhone: text('seller_phone'),
      driverName: text('driver_name'),
      driverPhone: text('driver_phone'),
      publicUrl: text('public_url'),
      labels: ((json['labels'] as List<dynamic>?) ?? const [])
          .map((raw) => BoxLabel.fromApi(raw as Map<String, dynamic>))
          .toList(),
    );
  }
}
