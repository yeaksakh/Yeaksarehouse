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
      );
}

/// Every sticker for one shipment, plus what goes on all of them.
class LabelSheet {
  const LabelSheet({
    required this.invoiceNo,
    required this.customer,
    required this.labels,
  });

  final String invoiceNo;
  final String customer;
  final List<BoxLabel> labels;

  bool get isEmpty => labels.isEmpty;

  factory LabelSheet.fromApi(Map<String, dynamic> json) => LabelSheet(
        invoiceNo: (json['invoice_no'] as String?)?.trim() ?? '',
        customer: (json['customer'] as String?)?.trim() ?? '',
        labels: ((json['labels'] as List<dynamic>?) ?? const [])
            .map((raw) => BoxLabel.fromApi(raw as Map<String, dynamic>))
            .toList(),
      );
}
