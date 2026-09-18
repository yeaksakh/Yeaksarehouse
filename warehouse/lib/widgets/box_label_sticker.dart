import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/box_label.dart';
import '../services/label_bitmap.dart';
import '../services/label_printer.dart';
import 'label_qr.dart';

/// One 45 x 30 mm sticker, drawn for a thermal printer.
///
/// A second drawing of a layout the website already renders, and that is
/// deliberate: a Bluetooth thermal printer takes raster rows, not a PDF, so
/// SOMETHING has to draw it on the phone. What is NOT duplicated is the part
/// that matters -- how many stickers a parcel needs and what goes on each --
/// which the server decides and sends as data (`core/api/shipment_labels.py`).
///
/// PURE BLACK ON WHITE, NO GREYS. These printers burn a dot or they do not;
/// anti-aliased grey comes out as speckle, and a speckled SKU is one a picker
/// cannot read across a warehouse.
class BoxLabelSticker extends StatelessWidget {
  const BoxLabelSticker({
    super.key,
    required this.label,
    required this.invoiceNo,
    required this.customer,
    this.phone = '',
    this.company = '',
    this.seller = '',
    this.driver = '',
    this.qrData = '',
    this.acceptedBy = '',
    this.packedBy = '',
    this.auditedBy = '',
  });

  final BoxLabel label;
  final String invoiceNo;
  final String customer;

  /// The customer's phone, under their name -- the number a driver rings from
  /// the gate. Blank rows take no space rather than leaving a gap.
  final String phone;

  /// The customer's business, when there is a real one. Blank for most walk-in
  /// sales, and a blank row takes no space.
  final String company;

  /// Who sold it, and who is taking it -- the same two lines the website's
  /// sticker carries. Blank when the server did not send them, and a blank one
  /// takes no space rather than leaving a gap.
  final String seller;
  final String driver;

  /// The shipment's public page. Blank leaves the corner empty rather than
  /// printing a code that leads nowhere.
  final String qrData;

  /// The warehouse trail: who took the order on, who packed it, who checked it.
  ///
  /// One line, an icon and a name each. The icon is what makes it fit -- a
  /// worded label cost three to seven glyphs per stage, and three stages across
  /// 344 dots left nothing for the names. It also means the row needs no
  /// translation, which matters here: this widget is rendered OFF-SCREEN with no
  /// `MaterialApp` above it, so `AppLocalizations.of` would have thrown.
  ///
  /// `accepted` is the WAREHOUSE taking the order on, not the rider taking the
  /// parcel -- the stages run accepted, packed, audited, shipped, delivered.
  final String acceptedBy;
  final String packedBy;
  final String auditedBy;

  /// Blank stages are dropped, and the rest share the width between them, so a
  /// parcel only one person has touched gives that name the whole line.
  List<({IconData icon, String name})> get _trail => [
        if (acceptedBy.isNotEmpty)
          (icon: Icons.how_to_reg, name: acceptedBy),
        if (packedBy.isNotEmpty) (icon: Icons.inventory_2, name: packedBy),
        if (auditedBy.isNotEmpty) (icon: Icons.verified, name: auditedBy),
      ];

  /// 45 x 30 mm at 8 dots/mm, the usual resolution of these machines: 360 x 240.
  /// Sent at exactly this size so the printer does not rescale and blur it.
  static const Size dots = Size(360, 240);

  /// 14 mm, matching the website's sticker. Big enough for a 3-dot module on a
  /// URL-length code, which is what makes it scan first time -- see [LabelQr].
  static const double qrDots = 112;

  @override
  Widget build(BuildContext context) {
    const black = TextStyle(color: Colors.black, height: 1.1);
    final hasQr = qrData.isNotEmpty;
    return Container(
      width: dots.width,
      height: dots.height,
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: DefaultTextStyle(
        style: black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(invoiceNo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: black.copyWith(
                          fontSize: 20, fontWeight: FontWeight.w900)),
                ),
                // The box number is what a picker reads first when a parcel
                // arrives in several pieces, so it gets the biggest type here.
                Text('BOX ${label.boxOfBox}',
                    style: black.copyWith(
                        fontSize: 22, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 3),
            Container(height: 2, color: Colors.black),
            const SizedBox(height: 4),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                label.product,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: black.copyWith(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // What goes in THIS box, beside the name it belongs
                            // to. The packer reads the two together while
                            // counting bottles in.
                            Text(
                              'x${label.quantityLabel}',
                              style: black.copyWith(
                                  fontSize: 19, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        if (label.sku.isNotEmpty)
                          Text(label.sku,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: black.copyWith(fontSize: 12)),
                        const Spacer(),
                        // Who the parcel is for, and who to ring: the rows a
                        // driver reads at the gate, so they get the type size
                        // and the product rows above give it up.
                        Text(customer,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: black.copyWith(
                                fontSize: 19, fontWeight: FontWeight.w900)),
                        if (company.isNotEmpty)
                          Text(company,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: black.copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                        // The marks are the website's own, so a packer holding
                        // one of each sticker reads the same rows.
                        if (phone.isNotEmpty)
                          _Staff(mark: '\u260E', text: phone, size: 18),
                        if (seller.isNotEmpty)
                          _Staff(mark: '\u2605', text: seller, size: 16),
                        if (driver.isNotEmpty)
                          _Staff(mark: '\u2691', text: driver, size: 13),
                      ],
                    ),
                  ),
                  if (hasQr) ...[
                    const SizedBox(width: 4),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        LabelQr(data: qrData, dots: qrDots),
                        Text(label.indexOfTotal,
                            style: black.copyWith(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ] else
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(label.indexOfTotal,
                          style: black.copyWith(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
            if (_trail.isNotEmpty) ...[
              const SizedBox(height: 3),
              // Full width, below the QR rather than beside it: the QR only
              // occupies the top 112 dots of the body, and this row needs every
              // one of the 344 across.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (final stage in _trail)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(stage.icon, size: 15, color: Colors.black),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(stage.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: black.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}


/// One "who" row: a mark, then a name.
///
/// The mark is a single glyph rather than a word so the row costs the same in
/// every language -- the app runs in Khmer, and "Seller:" and "អ្នកលក់៖" are
/// not the same width on a 45 mm sticker.
class _Staff extends StatelessWidget {
  const _Staff({required this.mark, required this.text, this.size = 13});

  final String mark;
  final String text;

  /// The rows are not equally urgent. The customer's number is rung from the
  /// gate, the seller's when something is wrong with the order, the driver's
  /// least often -- so they are not all the same size.
  final double size;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Text('$mark $text',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.black,
                height: 1.1,
                fontSize: size,
                fontWeight: FontWeight.w700)),
      );
}

/// Draws [sticker] off-screen and returns it as PNG bytes.
///
/// Off-screen rather than screenshotting a visible widget: a packer must be
/// able to print six stickers without six of them flashing past on the phone,
/// and a widget that is never laid out cannot be scrolled out of frame
/// half-rendered.
///
/// This one is for the preview on screen. The printer wants
/// [renderStickerMono]: a thermal head takes dots, not a PNG.
Future<Uint8List> renderSticker(Widget sticker, {double pixelRatio = 1.0}) async {
  final image = await _rasterise(sticker, pixelRatio);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

/// The same drawing in both the forms a printer might want, from one pass.
///
/// Always at pixelRatio 1: the sticker's dimensions ARE the printer's dots
/// (360 x 240 for 45 x 30 mm at 8 dots/mm), so scaling it would either blur the
/// text or run it off the edge of the label.
Future<RenderedSticker> renderStickerForPrinter(Widget sticker) async {
  final image = await _rasterise(sticker, 1.0);
  final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  return RenderedSticker(
    mono: MonoBitmap.fromRgba(
      rgba!.buffer.asUint8List(),
      width: image.width,
      height: image.height,
    ),
    png: png!.buffer.asUint8List(),
  );
}

Future<ui.Image> _rasterise(Widget sticker, double pixelRatio) async {
  final boundary = RenderRepaintBoundary();
  final view = ui.PlatformDispatcher.instance.views.first;

  final render = RenderView(
    view: view,
    child: RenderPositionedBox(alignment: Alignment.center, child: boundary),
    configuration: ViewConfiguration(
      logicalConstraints:
          BoxConstraints.tight(BoxLabelSticker.dots),
      devicePixelRatio: pixelRatio,
    ),
  );

  final pipeline = PipelineOwner()..rootNode = render;
  render.prepareInitialFrame();

  final buildOwner = BuildOwner(focusManager: FocusManager());
  final element = RenderObjectToWidgetAdapter<RenderBox>(
    container: boundary,
    child: Directionality(textDirection: TextDirection.ltr, child: sticker),
  ).attachToRenderTree(buildOwner);

  buildOwner
    ..buildScope(element)
    ..finalizeTree();
  pipeline
    ..flushLayout()
    ..flushCompositingBits()
    ..flushPaint();

  return boundary.toImage(pixelRatio: pixelRatio);
}
