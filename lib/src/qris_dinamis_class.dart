/// Main class that consolidates all QRIS dynamic conversion functionality.
library;

import 'dart:typed_data';

import 'crc16.dart';
import 'qris_converter.dart';
import 'qris_data.dart';
import 'qris_image_generator.dart';
import 'qris_parser.dart';
import 'qris_result.dart';

/// A unified class for converting static QRIS to dynamic QRIS.
///
/// All functionality is accessed through a single instance. Create a
/// [QrisDinamis] with the static QRIS string, then call methods to
/// convert or parse.
///
/// ## Example
///
/// ```dart
/// final qris = QrisDinamis('00020101021126570011ID...');
///
/// // Convert to dynamic QRIS string only
/// final result = qris.convertFromStatic(nominal: '50000');
/// print(result.qrisString);
///
/// // Convert to dynamic QRIS with image
/// final resultWithImage = qris.convertFromStatic(
///   nominal: '50000',
///   withImage: true,
/// );
/// File('output.png').writeAsBytesSync(resultWithImage.imageBytes!);
///
/// // Parse QRIS data
/// final data = qris.parse();
/// print(data.merchantName);
///
/// // Validate CRC
/// print(qris.isCrcValid);
/// ```
class QrisDinamis {
  /// The original static QRIS string.
  final String qris;

  /// Creates a [QrisDinamis] instance with the given static [qris] string.
  ///
  /// Throws [ArgumentError] if [qris] is empty.
  QrisDinamis(this.qris) {
    if (qris.isEmpty) {
      throw ArgumentError('QRIS string cannot be empty.');
    }
  }

  /// Converts the static QRIS to a dynamic QRIS.
  ///
  /// ## Parameters
  ///
  /// - [nominal]: The transaction amount (required). Example: `'50000'`.
  /// - [taxType]: Tax type — `'p'` for percentage, `'r'` for fixed rupiah.
  ///   Defaults to `'p'`.
  /// - [fee]: Fee/tax amount. Defaults to `'0'`.
  /// - [withImage]: If `true`, generates a PNG image of the QR code.
  ///   Defaults to `false`.
  /// - [templateImage]: Optional template image bytes (PNG/JPG) to overlay
  ///   the QR code onto. Only used when `withImage` is `true`.
  /// - [qrSize]: Size of the QR code in pixels. Only used when `withImage`
  ///   is `true`. Defaults to `400`.
  /// - [qrMargin]: Margin around the QR code in modules. Only used when
  ///   `withImage` is `true`. Defaults to `2`.
  ///
  /// ## Returns
  ///
  /// A [QrisResult] containing:
  /// - [QrisResult.qrisString]: The dynamic QRIS string (always present).
  /// - [QrisResult.imageBytes]: PNG bytes (only if `withImage: true`).
  ///
  /// ## Example
  ///
  /// ```dart
  /// final qris = QrisDinamis('00020101021126570011ID...');
  ///
  /// // String only
  /// final result = qris.convertFromStatic(nominal: '50000');
  ///
  /// // With image
  /// final result = qris.convertFromStatic(
  ///   nominal: '50000',
  ///   withImage: true,
  /// );
  /// ```
  QrisResult convertFromStatic({
    required String nominal,
    String taxType = 'p',
    String fee = '0',
    bool withImage = false,
    Uint8List? templateImage,
    int qrSize = 400,
    int qrMargin = 2,
  }) {
    // Generate dynamic QRIS string.
    final dynamicQris = convertStaticQrisToDynamic(
      qris,
      nominal: nominal,
      taxType: taxType,
      fee: fee,
    );

    // Generate image if requested.
    Uint8List? imageBytes;
    if (withImage) {
      imageBytes = convertStaticQrisToDynamicWithImage(
        qris,
        nominal: nominal,
        taxType: taxType,
        fee: fee,
        templateImage: templateImage,
        qrSize: qrSize,
        qrMargin: qrMargin,
      );
    }

    return QrisResult(
      qrisString: dynamicQris,
      imageBytes: imageBytes,
    );
  }

  /// Parses the QRIS string and extracts merchant/transaction data.
  ///
  /// Returns a [QrisData] object with extracted fields such as
  /// [QrisData.merchantName], [QrisData.nmid], [QrisData.nns], etc.
  QrisData parse() {
    return parseQris(qris);
  }

  /// Whether the CRC-16 checksum of this QRIS string is valid.
  bool get isCrcValid {
    final body = qris.substring(0, qris.length - 4);
    final crc = qris.substring(qris.length - 4);
    return toCrc16(body) == crc;
  }

  @override
  String toString() {
    return 'QrisDinamis(qris: ${qris.substring(0, qris.length > 20 ? 20 : qris.length)}...)';
  }
}
