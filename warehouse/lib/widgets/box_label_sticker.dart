import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/box_label.dart';

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
  });

  final BoxLabel label;
  final String invoiceNo;
  final String customer;

  /// 45 x 30 mm at 8 dots/mm, the usual resolution of these machines: 360 x 240.
  /// Sent at exactly this size so the printer does not rescale and blur it.
  static const Size dots = Size(360, 240);

  @override
  Widget build(BuildContext context) {
    const black = TextStyle(color: Colors.black, height: 1.1);
    return Container(
      width: dots.width,
      height: dots.height,
      color: Colors.white,
      padding: const EdgeInsets.all(10),
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
                          fontSize: 22, fontWeight: FontWeight.w900)),
                ),
                // The box number is what a picker reads first when a parcel
                // arrives in several pieces, so it gets the biggest type here.
                Text('BOX ${label.boxOfBox}',
                    style: black.copyWith(
                        fontSize: 26, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 4),
            Container(height: 2, color: Colors.black),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                label.product,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: black.copyWith(fontSize: 19, fontWeight: FontWeight.w700),
              ),
            ),
            if (label.sku.isNotEmpty)
              Text(label.sku,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: black.copyWith(fontSize: 17)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(customer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: black.copyWith(fontSize: 16)),
                ),
                Text(label.indexOfTotal,
                    style: black.copyWith(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws [sticker] off-screen and returns it as PNG bytes.
///
/// Off-screen rather than screenshotting a visible widget: a packer must be
/// able to print six stickers without six of them flashing past on the phone,
/// and a widget that is never laid out cannot be scrolled out of frame
/// half-rendered.
Future<Uint8List> renderSticker(Widget sticker, {double pixelRatio = 1.0}) async {
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

  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}
