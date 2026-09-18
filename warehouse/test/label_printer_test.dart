import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse/services/label_bitmap.dart';
import 'package:warehouse/services/label_printer.dart';
import 'package:warehouse/services/tspl.dart';

/// Four RGBA pixels' worth of helper: build a tiny image from a picture.
///
/// `#` is black, `.` is white, so a test reads as the thing it is testing.
Uint8List rgbaFrom(List<String> rows) {
  final height = rows.length;
  final width = rows.first.length;
  final out = Uint8List(width * height * 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final black = rows[y][x] == '#';
      final p = (y * width + x) * 4;
      out[p] = out[p + 1] = out[p + 2] = black ? 0 : 255;
      out[p + 3] = 255;
    }
  }
  return out;
}

void main() {
  group('MonoBitmap packs the way TSPL reads', () {
    // THE ONE THAT MATTERS. TSPL burns a dot for a ZERO bit, the opposite of
    // every other raster format. Backwards does not give a slightly wrong
    // label, it gives a solid black one and eats the roll.
    test('a black dot is a 0 bit and a white dot is a 1', () {
      final bitmap = MonoBitmap.fromRgba(
        rgbaFrom(['#.......']),
        width: 8,
        height: 1,
      );
      expect(bitmap.bytes.single, 0x7F, reason: 'left dot burnt, rest blank');
      expect(bitmap.isBlack(0, 0), isTrue);
      expect(bitmap.isBlack(1, 0), isFalse);
    });

    test('a blank image is all ones', () {
      final bitmap =
          MonoBitmap.fromRgba(rgbaFrom(['........']), width: 8, height: 1);
      expect(bitmap.bytes.single, 0xFF);
    });

    test('a full image is all zeros', () {
      final bitmap =
          MonoBitmap.fromRgba(rgbaFrom(['########']), width: 8, height: 1);
      expect(bitmap.bytes.single, 0x00);
    });

    test('the leftmost dot is the high bit', () {
      final bitmap =
          MonoBitmap.fromRgba(rgbaFrom(['.......#']), width: 8, height: 1);
      expect(bitmap.bytes.single, 0xFE);
    });

    test('a row that is not a whole byte is padded blank, not black', () {
      // 12 dots is a byte and a half. The four spare bits must come out as 1
      // (blank); as 0 they would print a black stripe down the right edge of
      // every label.
      final bitmap = MonoBitmap.fromRgba(
        rgbaFrom(['############']),
        width: 12,
        height: 1,
      );
      expect(bitmap.rowBytes, 2);
      expect(bitmap.bytes, [0x00, 0x0F]);
    });

    test('rows are packed one after another, top first', () {
      final bitmap = MonoBitmap.fromRgba(
        rgbaFrom(['#.......', '.......#']),
        width: 8,
        height: 2,
      );
      expect(bitmap.bytes, [0x7F, 0xFE]);
    });

    test('a transparent pixel is white, not black', () {
      // Nothing was drawn there. Treating alpha 0 as black would fill every
      // margin the sticker leaves.
      final rgba = Uint8List.fromList([0, 0, 0, 0, 0, 0, 0, 255]);
      final bitmap = MonoBitmap.fromRgba(rgba, width: 2, height: 1);
      expect(bitmap.isBlack(0, 0), isFalse);
      expect(bitmap.isBlack(1, 0), isTrue);
    });

    test('mid grey goes one way and the sticker has none anyway', () {
      final dark = Uint8List.fromList([60, 60, 60, 255]);
      final light = Uint8List.fromList([200, 200, 200, 255]);
      expect(MonoBitmap.fromRgba(dark, width: 1, height: 1).isBlack(0, 0), isTrue);
      expect(
          MonoBitmap.fromRgba(light, width: 1, height: 1).isBlack(0, 0), isFalse);
    });

    test('inverting flips it for ESC/POS and back again', () {
      final bitmap =
          MonoBitmap.fromRgba(rgbaFrom(['#.#.#.#.']), width: 8, height: 1);
      expect(bitmap.inverted.bytes.single, 0xAA);
      expect(bitmap.inverted.inverted.bytes, bitmap.bytes);
    });

    test('it refuses an image smaller than it was told', () {
      expect(
        () => MonoBitmap.fromRgba(Uint8List(4), width: 8, height: 8),
        throwsArgumentError,
      );
    });
  });

  group('TSPL command stream', () {
    MonoBitmap sticker() => MonoBitmap.fromRgba(
          rgbaFrom(List.filled(240, '.' * 360)),
          width: 360,
          height: 240,
        );

    String headerOf(Uint8List bytes) =>
        String.fromCharCodes(bytes.takeWhile((b) => b != 0x00));

    test('it states the label size in millimetres, not dots', () {
      final text = headerOf(Tspl.label(sticker()));
      // 360 x 240 dots at 8 dots/mm. A printer told "360 mm" feeds the whole
      // roll looking for a gap that never comes.
      expect(text, contains('SIZE 45 mm,30 mm'));
      expect(text, contains('GAP 2 mm,0 mm'));
    });

    test('it clears the buffer, or two labels print on top of each other', () {
      expect(headerOf(Tspl.label(sticker())), contains('CLS'));
    });

    test('the bitmap width is in BYTES and the height in dots', () {
      // The single likeliest way to get this wrong: 360 is the dot count, 45 is
      // what the command wants. A printer given 360 reads eight times too much
      // data and prints nothing.
      expect(headerOf(Tspl.label(sticker())), contains('BITMAP 0,0,45,240,0,'));
    });

    test('the payload is exactly rowBytes x height, with no length field', () {
      final bitmap = sticker();
      final bytes = Tspl.label(bitmap);
      final marker = 'BITMAP 0,0,45,240,0,'.codeUnits;
      final start = _indexOf(bytes, marker) + marker.length;
      // header + payload + CRLF + "PRINT 1,1" + CRLF
      final tail = bytes.length - (start + bitmap.bytes.length);
      expect(tail, '\r\nPRINT 1,1\r\n'.length);
    });

    test('every line ends CRLF, because LF alone hangs the parser', () {
      final text = headerOf(Tspl.label(sticker()));
      for (final line in ['SIZE 45 mm,30 mm', 'CLS', 'DIRECTION 1']) {
        expect(text, contains('$line\r\n'));
      }
    });

    test('a whole-number size has no trailing .0', () {
      // "SIZE 45.0 mm" is rejected outright by some firmware.
      expect(headerOf(Tspl.label(sticker())), isNot(contains('45.0')));
    });

    test('a fractional size keeps its one decimal', () {
      final text = headerOf(Tspl.label(sticker(), widthMm: 57.5));
      expect(text, contains('SIZE 57.5 mm'));
    });

    test('copies are asked for in the PRINT line', () {
      expect(headerOf(Tspl.label(sticker(), copies: 3)),
          contains('PRINT 1,3'));
    });

    test('the language test draws with the printer own commands, not a bitmap',
        () {
      final text = String.fromCharCodes(Tspl.testLabel());
      expect(text, contains('BOX '));
      expect(text, contains('TSPL OK'));
      expect(text, isNot(contains('BITMAP')));
    });
  });

  group('PrinterLanguage', () {
    test('an unset printer defaults to TSPL, because this is a label app', () {
      expect(PrinterLanguage.fromStorage(null), PrinterLanguage.tspl);
    });

    test('an unrecognised stored value does not crash the settings screen', () {
      expect(PrinterLanguage.fromStorage('zpl'), PrinterLanguage.tspl);
    });

    test('a saved choice comes back', () {
      expect(PrinterLanguage.fromStorage('escPos'), PrinterLanguage.escPos);
      expect(PrinterLanguage.fromStorage('tspl'), PrinterLanguage.tspl);
    });
  });
}

int _indexOf(Uint8List haystack, List<int> needle) {
  for (var i = 0; i + needle.length <= haystack.length; i++) {
    var match = true;
    for (var j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        match = false;
        break;
      }
    }
    if (match) return i;
  }
  return -1;
}
