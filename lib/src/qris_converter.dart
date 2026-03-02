/// Converts a static QRIS string to a dynamic QRIS string.
library;

import 'crc16.dart';

/// Converts a static QRIS string to a dynamic QRIS string with the specified
/// [nominal] amount.
///
/// ## Parameters
///
/// - [qris]: The original static QRIS string from a merchant's QR code.
/// - [nominal]: The transaction amount (required). Example: `'50000'`.
/// - [taxType]: Tax type — `'p'` for percentage, `'r'` for fixed rupiah.
///   Defaults to `'p'`.
/// - [fee]: The fee/tax amount. If [taxType] is `'p'`, this is a percentage
///   value. If `'r'`, this is a fixed rupiah amount. Defaults to `'0'`.
///
/// ## Returns
///
/// A new QRIS string with the dynamic indicator (`010212`), the nominal
/// amount injected, optional tax fields, and a recalculated CRC-16 checksum.
///
/// ## Example
///
/// ```dart
/// final dynamicQris = convertQris(
///   '00020101021126570011ID...',
///   nominal: '50000',
/// );
/// ```
///
/// ## Throws
///
/// - [ArgumentError] if [qris] is empty.
/// - [ArgumentError] if [nominal] is empty.
String convertStaticQrisToDynamic(
  String qris, {
  required String nominal,
  String taxType = 'p',
  String fee = '0',
}) {
  if (qris.isEmpty) {
    throw ArgumentError('The parameter "qris" is required.');
  }
  if (nominal.isEmpty) {
    throw ArgumentError('The parameter "nominal" is required.');
  }

  // Remove the last 4 characters (existing CRC) and change static to dynamic.
  var qrisModified =
      qris.substring(0, qris.length - 4).replaceAll('010211', '010212');

  // Split on the country code field "5802ID".
  final parts = qrisModified.split('5802ID');
  if (parts.length < 2) {
    throw FormatException(
      'Invalid QRIS format: could not find country code field "5802ID".',
    );
  }

  // Build the amount TLV field: Tag 54 + length + value.
  var amount = '54${pad(nominal.length)}$nominal';

  // Build optional tax/fee fields.
  if (taxType.isNotEmpty && fee != '0') {
    if (taxType == 'p') {
      // Percentage fee: Tag 55, Sub-tag 03 (percentage), Sub-tag 57
      amount += '55020357${pad(fee.length)}$fee';
    } else {
      // Fixed fee: Tag 55, Sub-tag 02 (fixed), Sub-tag 56
      amount += '55020256${pad(fee.length)}$fee';
    }
  }

  // Reassemble: first part + amount + country code + second part.
  amount += '5802ID';
  var output = '${parts[0].trim()}$amount${parts[1].trim()}';

  // Recalculate and append CRC-16.
  output += toCrc16(output);

  return output;
}
