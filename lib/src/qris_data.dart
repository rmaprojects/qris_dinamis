/// Data model representing parsed information from a QRIS string.
library;

/// Contains extracted merchant and validation data from a QRIS QR code string.
///
/// Fields correspond to the TLV (Tag-Length-Value) structure of
/// the EMVCo QRIS specification.
class QrisData {
  /// National Merchant ID (NMID), prefixed with "ID".
  final String nmid;

  /// Merchant identifier type — either `"A01"` or `"01"`.
  final String id;

  /// Merchant display name, extracted and uppercased.
  final String merchantName;

  /// Acquirer/printer identifier extracted from the QRIS domain.
  final String printer;

  /// National Number System (NNS) — 8-digit acquirer code.
  final String nns;

  /// Whether the CRC checksum in the QRIS string is valid.
  final bool crcIsValid;

  /// Creates a [QrisData] instance with the given fields.
  const QrisData({
    required this.nmid,
    required this.id,
    required this.merchantName,
    required this.printer,
    required this.nns,
    required this.crcIsValid,
  });

  @override
  String toString() {
    return 'QrisData('
        'nmid: $nmid, '
        'id: $id, '
        'merchantName: $merchantName, '
        'printer: $printer, '
        'nns: $nns, '
        'crcIsValid: $crcIsValid)';
  }
}
