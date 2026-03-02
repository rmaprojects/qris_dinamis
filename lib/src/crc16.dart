/// CRC-16/CCITT utility for QRIS checksum calculation.
///
/// Uses polynomial 0x1021 with initial value 0xFFFF.
library;

/// Pads a number with a leading zero if it is less than 10.
///
/// Returns the number as a two-character string.
/// Example: `pad(5)` returns `'05'`, `pad(12)` returns `'12'`.
String pad(int number) {
  return number < 10 ? '0$number' : number.toString();
}

/// Computes CRC-16/CCITT checksum for the given [input] string.
///
/// The CRC is computed using polynomial 0x1021 with initial value 0xFFFF,
/// which is the standard used in QRIS/EMVCo QR codes.
///
/// Returns a 4-character uppercase hexadecimal string.
String toCrc16(String input) {
  var crc = 0xFFFF;

  for (var i = 0; i < input.length; i++) {
    crc ^= input.codeUnitAt(i) << 8;
    for (var j = 0; j < 8; j++) {
      crc = (crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1;
    }
  }

  final hex = (crc & 0xFFFF).toRadixString(16).toUpperCase();
  return hex.padLeft(4, '0');
}
