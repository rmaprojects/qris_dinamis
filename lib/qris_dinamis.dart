/// QRIS Dinamis — Convert static QRIS to dynamic QRIS.
///
/// This library provides tools to convert static QRIS (Quick Response Code
/// Indonesian Standard) strings into dynamic QRIS with specified nominal
/// amounts, tax types, and fees.
///
/// ## Usage
///
/// ```dart
/// import 'package:qris_dinamis/qris_dinamis.dart';
///
/// final qris = QrisDinamis('YOUR_STATIC_QRIS_STRING');
///
/// // Convert to dynamic QRIS string only
/// final result = qris.convertFromStatic(nominal: '50000');
/// print(result.qrisString);
///
/// // Convert with image
/// final resultWithImage = qris.convertFromStatic(
///   nominal: '50000',
///   withImage: true,
/// );
/// File('output.png').writeAsBytesSync(resultWithImage.imageBytes!);
///
/// // Parse QRIS data
/// final data = qris.parse();
/// print(data.merchantName);
/// ```
library;

export 'src/qris_data.dart' show QrisData;
export 'src/qris_dinamis_class.dart' show QrisDinamis;
export 'src/qris_result.dart' show QrisResult;
