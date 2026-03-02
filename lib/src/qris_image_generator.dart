/// Generates a dynamic QRIS as a PNG image with template overlay.
library;

import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';

import 'qris_converter.dart';
import 'qris_parser.dart';

/// Generates a dynamic QRIS QR code as a PNG image.
///
/// This function converts a static QRIS to dynamic and renders it as a
/// QR code image. If a [templateImage] is provided, the QR code is composited
/// onto the template along with merchant information text.
///
/// ## Parameters
///
/// - [qris]: The original static QRIS string.
/// - [nominal]: The transaction amount (required). Example: `'50000'`.
/// - [taxType]: Tax type — `'p'` for percentage, `'r'` for fixed rupiah.
///   Defaults to `'p'`.
/// - [fee]: Fee/tax amount. Defaults to `'0'`.
/// - [templateImage]: Optional template image bytes (PNG/JPG) to use as
///   background. If null, only the QR code is generated.
/// - [qrSize]: Size of the QR code in pixels. Defaults to `400`.
/// - [qrMargin]: Margin around the QR code in modules. Defaults to `2`.
///
/// ## Returns
///
/// A [Uint8List] containing the PNG-encoded image.
///
/// ## Example
///
/// ```dart
/// // Simple QR code only
/// final pngBytes = convertQrisToImage(
///   '00020101021126570011ID...',
///   nominal: '50000',
/// );
///
/// // With template overlay
/// final templateBytes = File('template.png').readAsBytesSync();
/// final pngBytes = convertQrisToImage(
///   '00020101021126570011ID...',
///   nominal: '50000',
///   templateImage: templateBytes,
/// );
/// ```
Uint8List convertStaticQrisToDynamicWithImage(
  String qris, {
  required String nominal,
  String taxType = 'p',
  String fee = '0',
  Uint8List? templateImage,
  int qrSize = 400,
  int qrMargin = 2,
}) {
  // Convert static QRIS to dynamic.
  final dynamicQris = convertStaticQrisToDynamic(
    qris,
    nominal: nominal,
    taxType: taxType,
    fee: fee,
  );

  // Generate QR code matrix.
  final qrCode = QrCode.fromData(
    data: dynamicQris,
    errorCorrectLevel: QrErrorCorrectLevel.M,
  );
  final qrImage = QrImage(qrCode);

  final moduleCount = qrCode.moduleCount;
  final totalModules = moduleCount + qrMargin * 2;
  final moduleSize = qrSize ~/ totalModules;
  final actualSize = moduleSize * totalModules;

  // Render QR code to image.
  final qrImg = img.Image(width: actualSize, height: actualSize);
  // Fill white background.
  img.fill(qrImg, color: img.ColorRgba8(255, 255, 255, 255));

  // Draw QR modules.
  for (var x = 0; x < moduleCount; x++) {
    for (var y = 0; y < moduleCount; y++) {
      if (qrImage.isDark(y, x)) {
        final px = (x + qrMargin) * moduleSize;
        final py = (y + qrMargin) * moduleSize;
        img.fillRect(
          qrImg,
          x1: px,
          y1: py,
          x2: px + moduleSize,
          y2: py + moduleSize,
          color: img.ColorRgba8(0, 0, 0, 255),
        );
      }
    }
  }

  // If no template, return QR code only.
  if (templateImage == null) {
    return Uint8List.fromList(img.encodePng(qrImg));
  }

  // Composite onto template.
  final template = img.decodeImage(templateImage);
  if (template == null) {
    throw const FormatException('Could not decode template image.');
  }

  final w = template.width;
  final h = template.height;

  // Resize QR to fit template (similar proportions as JS version).
  final qrDisplaySize = (w * 0.55).toInt();
  final qrResized = img.copyResize(
    qrImg,
    width: qrDisplaySize,
    height: qrDisplaySize,
  );

  // Position QR code on template (centered horizontally, offset vertically).
  final qrX = (w - qrDisplaySize) ~/ 2;
  final qrY = (h * 0.30).toInt();
  img.compositeImage(template, qrResized, dstX: qrX, dstY: qrY);

  // Parse QRIS data for text overlay.
  final data = parseQris(qris);

  // Draw merchant name text.
  final font = img.arial24;
  final merchantText = data.merchantName;
  _drawCenteredText(template, font, merchantText, w, (h * 0.18).toInt());

  // Draw NMID.
  final nmidText = 'NMID : ${data.nmid}';
  _drawCenteredText(template, font, nmidText, w, qrY + qrDisplaySize + 10);

  // Draw ID.
  _drawCenteredText(template, font, data.id, w, qrY + qrDisplaySize + 40);

  // Draw NNS at bottom.
  final smallFont = img.arial14;
  final nnsText = 'Dicetak oleh: ${data.nns}';
  img.drawString(
    template,
    nnsText,
    font: smallFont,
    x: 20,
    y: h - 40,
    color: img.ColorRgba8(0, 0, 0, 255),
  );

  return Uint8List.fromList(img.encodePng(template));
}

/// Draws [text] centered horizontally at the given [y] position on [image].
void _drawCenteredText(
  img.Image image,
  img.BitmapFont font,
  String text,
  int imageWidth,
  int y,
) {
  // Estimate text width (approximate using character count * average glyph width).
  final textWidth = _estimateTextWidth(font, text);
  final x = (imageWidth - textWidth) ~/ 2;
  img.drawString(
    image,
    text,
    font: font,
    x: x > 0 ? x : 0,
    y: y,
    color: img.ColorRgba8(0, 0, 0, 255),
  );
}

/// Estimates the pixel width of [text] using the [font]'s character data.
int _estimateTextWidth(img.BitmapFont font, String text) {
  var width = 0;
  for (final char in text.codeUnits) {
    final ch = font.characters[char];
    if (ch != null) {
      width += ch.xAdvance;
    } else {
      // Fallback: use space width or a default.
      width += font.characters[32]?.xAdvance ?? 8;
    }
  }
  return width;
}
