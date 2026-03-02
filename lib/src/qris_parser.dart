/// Parser for extracting structured data from a QRIS string.
library;

import 'crc16.dart';
import 'qris_data.dart';

/// Extracts a substring between [start] and [end] markers in [str].
///
/// Returns an empty string if [start] is not found.
String getBetween(String str, String start, String end) {
  final startIdx = str.indexOf(start);
  if (startIdx == -1) return '';
  final contentStart = startIdx + start.length;
  final endIdx = str.indexOf(end, contentStart);
  if (endIdx == -1) return str.substring(contentStart);
  return str.substring(contentStart, endIdx);
}

/// Parses a QRIS string and extracts merchant/transaction metadata.
///
/// The [qris] parameter must be a valid QRIS QR code string following
/// the EMVCo MPM (Merchant Presented Mode) specification.
///
/// Returns a [QrisData] object containing:
/// - [QrisData.nmid]: National Merchant ID
/// - [QrisData.id]: Merchant identifier type
/// - [QrisData.merchantName]: Display name
/// - [QrisData.printer]: Acquirer/printer name
/// - [QrisData.nns]: National Number System code
/// - [QrisData.crcIsValid]: Whether the CRC checksum is valid
///
/// Throws [FormatException] if the QRIS string cannot be parsed.
QrisData parseQris(String qris) {
  if (qris.isEmpty) {
    throw const FormatException('QRIS string cannot be empty.');
  }

  final nmid = 'ID${getBetween(qris, '15ID', '0303')}';

  final id = qris.contains('A01') ? 'A01' : '01';

  // Extract merchant name: content after "ID59" until "60",
  // skip the first 2 chars (length prefix), then trim and uppercase.
  final merchantNameRaw = getBetween(qris, 'ID59', '60');
  final merchantName = merchantNameRaw.length > 2
      ? merchantNameRaw.substring(2).trim().toUpperCase()
      : merchantNameRaw.trim().toUpperCase();

  // Extract printer info from domain segments.
  final printPattern = RegExp(r'(?<=ID|COM).+?(?=0118)');
  final printMatches = printPattern.allMatches(qris).toList();
  var printer = '';
  if (printMatches.isNotEmpty) {
    final lastMatch = printMatches.last.group(0) ?? '';
    final parts = lastMatch.split('.');
    printer = parts.length == 3
        ? parts[1]
        : (parts.length > 3 ? parts[2] : lastMatch);
  }

  // Extract NNS (8-digit acquirer code).
  final nnsPattern = RegExp(r'(?<=0118).+?(?=ID)');
  final nnsMatches = nnsPattern.allMatches(qris).toList();
  var nns = '';
  if (nnsMatches.isNotEmpty) {
    final lastNns = nnsMatches.last.group(0) ?? '';
    nns = lastNns.length >= 8 ? lastNns.substring(0, 8) : lastNns;
  }

  // Validate CRC.
  final crcInput = qris.substring(0, qris.length - 4);
  final crcFromQris = qris.substring(qris.length - 4);
  final crcComputed = toCrc16(crcInput);

  return QrisData(
    nmid: nmid,
    id: id,
    merchantName: merchantName,
    printer: printer,
    nns: nns,
    crcIsValid: crcFromQris == crcComputed,
  );
}
