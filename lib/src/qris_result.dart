/// Result model from QRIS conversion.
library;

import 'dart:typed_data';

/// Contains the result of a QRIS static-to-dynamic conversion.
///
/// Always contains the dynamic [qrisString]. If the conversion was
/// performed with `withImage: true`, [imageBytes] will contain
/// the PNG-encoded image data.
class QrisResult {
  /// The dynamic QRIS string.
  final String qrisString;

  /// PNG image bytes of the dynamic QRIS QR code.
  ///
  /// This is `null` if the conversion was performed with `withImage: false`.
  final Uint8List? imageBytes;

  /// Creates a [QrisResult] with the given [qrisString] and optional [imageBytes].
  const QrisResult({
    required this.qrisString,
    this.imageBytes,
  });

  @override
  String toString() {
    return 'QrisResult('
        'qrisString: ${qrisString.substring(0, qrisString.length > 20 ? 20 : qrisString.length)}..., '
        'hasImage: ${imageBytes != null})';
  }
}
