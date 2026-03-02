import 'dart:io';
import 'package:qris_dinamis/qris_dinamis.dart';

void main() {
  // Example QRIS string (replace with your actual static QRIS)
  const qrisString =
      '00020101021126590013ID.CO.BNI.WWW011893600009150305256502096102070790303UBE51440014ID.CO.QRIS.WWW0215ID20222337822690303UBE5204472253033605802ID5912VFS GLOBAL 66015JAKARTA SELATAN61051294062070703A016304D7C5';

  final qris = QrisDinamis(qrisString);

  // --- Function 1: Convert to dynamic QRIS string (no image) ---
  print('=== Convert QRIS String ===');
  try {
    final result = qris.convertFromStatic(nominal: '50000');
    print('Dynamic QRIS: ${result.qrisString}');
    print('Has image: ${result.imageBytes != null}'); // false
  } catch (e) {
    print('Error: $e');
  }

  // --- Function 2: Convert with image ---
  print('\n=== Generate QRIS Image ===');
  try {
    final result = qris.convertFromStatic(
      nominal: '50000',
      withImage: true,
    );
    print('Dynamic QRIS: ${result.qrisString}');
    final file = File('output_qris.png');
    file.writeAsBytesSync(result.imageBytes!);
    print(
        'QR image saved to: ${file.path} (${result.imageBytes!.length} bytes)');
  } catch (e) {
    print('Error: $e');
  }

  // --- Parse QRIS data ---
  print('\n=== Parse QRIS Data ===');
  try {
    final data = qris.parse();
    print('Merchant Name : ${data.merchantName}');
    print('NMID          : ${data.nmid}');
    print('ID            : ${data.id}');
    print('NNS           : ${data.nns}');
    print('CRC Valid     : ${data.crcIsValid}');
    print('Printer       : ${data.printer}');
  } catch (e) {
    print('Error: $e');
  }

  // --- Quick CRC check ---
  print('\n=== CRC Validation ===');
  print('CRC Valid: ${qris.isCrcValid}');
}
