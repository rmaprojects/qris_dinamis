# Qris Dinamis

[![pub package](https://img.shields.io/pub/v/qris_dinamis.svg)](https://pub.dev/packages/qris_dinamis)

Convert static QRIS (Quick Response Code Indonesian Standard) to dynamic QRIS. Pure Dart — works on Flutter, server-side Dart, and CLI.

## Features

- **Convert static QRIS to dynamic** — with or without image output
- **Parse QRIS data** — extract merchant name, NMID, NNS, etc.
- **CRC-16 validation** — verify QRIS checksum integrity

## Installation

```yaml
dependencies:
  qris_dinamis: ^1.0.0
```

```bash
dart pub get
```

## Usage

All functionality is accessed through a single `QrisDinamis` class:

```dart
import 'package:qris_dinamis/qris_dinamis.dart';

final qris = QrisDinamis('00020101021126570011ID........');
```

### Convert to Dynamic QRIS (String Only)

```dart
final result = qris.convertFromStatic(nominal: '50000');
print(result.qrisString); // Dynamic QRIS string
print(result.imageBytes);  // null
```

### Convert to Dynamic QRIS (With Image)

```dart
final result = qris.convertFromStatic(
  nominal: '50000',
  withImage: true,
);
print(result.qrisString);  // Dynamic QRIS string
File('output.png').writeAsBytesSync(result.imageBytes!); // PNG image
```

### Convert with Template Overlay

```dart
final template = File('template.png').readAsBytesSync();
final result = qris.convertFromStatic(
  nominal: '50000',
  withImage: true,
  templateImage: template,
);
```

### Convert with Tax/Fee

```dart
// Percentage fee
final result = qris.convertFromStatic(
  nominal: '50000',
  taxType: 'p',
  fee: '10',
);

// Fixed rupiah fee
final result = qris.convertFromStatic(
  nominal: '50000',
  taxType: 'r',
  fee: '1000',
);
```

### Parse QRIS Data

```dart
final data = qris.parse();
print(data.merchantName); // Merchant name
print(data.nmid);         // National Merchant ID
print(data.nns);          // National Number System
print(data.crcIsValid);   // CRC validation result
```

### Validate CRC

```dart
print(qris.isCrcValid); // true or false
```

## `convertFromStatic()` Parameters

| Parameter       | Required | Description                                             |
| --------------- | -------- | ------------------------------------------------------- |
| `nominal`       | ✅       | Transaction amount                                      |
| `taxType`       | ❌       | `'p'` for percentage, `'r'` for rupiah (default: `'p'`) |
| `fee`           | ❌       | Fee amount (default: `'0'`)                             |
| `withImage`     | ❌       | Generate PNG image (default: `false`)                   |
| `templateImage` | ❌       | Template image bytes for overlay (Get template [here](https://github.com/rmaprojects/qris_dinamis/blob/e95291f540e6d9a0639e11106bf7d4be908033ec/assets/template.png))                        |
| `qrSize`        | ❌       | QR code size in pixels (default: `400`)                 |
| `qrMargin`      | ❌       | QR code margin in modules (default: `2`)                |

## Credits

Based on [Qris-Dinamis](https://github.com/razisek/Qris-Dinamis) by [Rachma Azis](https://razisek.com).

## License

MIT

# Support

<a href="https://www.buymeacoffee.com/rmaprojects" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
