import 'package:qris_dinamis/qris_dinamis.dart';
import 'package:test/test.dart';

void main() {
  const sampleQris =
      '00020101021126590013ID.CO.BNI.WWW011893600009150305256502096102070790303UBE51440014ID.CO.QRIS.WWW0215ID20222337822690303UBE5204472253033605802ID5912VFS GLOBAL 66015JAKARTA SELATAN61051294062070703A016304D7C5';

  group('QrisDinamis', () {
    test('throws on empty QRIS string', () {
      expect(() => QrisDinamis(''), throwsA(isA<ArgumentError>()));
    });

    test('isCrcValid returns a boolean', () {
      final qris = QrisDinamis(sampleQris);
      expect(qris.isCrcValid, isA<bool>());
    });
  });

  group('QrisDinamis.convertFromStatic', () {
    late QrisDinamis qris;

    setUp(() {
      qris = QrisDinamis(sampleQris);
    });

    test('converts static to dynamic QRIS', () {
      final result = qris.convertFromStatic(nominal: '50000');
      expect(result.qrisString, isNotEmpty);
      expect(result.qrisString, contains('010212'));
      expect(result.qrisString, isNot(contains('010211')));
    });

    test('returns null imageBytes when withImage is false', () {
      final result = qris.convertFromStatic(nominal: '50000');
      expect(result.imageBytes, isNull);
    });

    test('returns imageBytes when withImage is true', () {
      final result = qris.convertFromStatic(
        nominal: '50000',
        withImage: true,
      );
      expect(result.imageBytes, isNotNull);
      expect(result.imageBytes!.isNotEmpty, isTrue);
    });

    test('includes nominal amount in output', () {
      final result = qris.convertFromStatic(nominal: '50000');
      expect(result.qrisString, contains('540550000'));
    });

    test('includes percentage tax when specified', () {
      final result = qris.convertFromStatic(
        nominal: '50000',
        taxType: 'p',
        fee: '10',
      );
      expect(result.qrisString, contains('55020357'));
    });

    test('includes fixed tax when specified', () {
      final result = qris.convertFromStatic(
        nominal: '50000',
        taxType: 'r',
        fee: '1000',
      );
      expect(result.qrisString, contains('55020256'));
    });

    test('preserves 5802ID country code', () {
      final result = qris.convertFromStatic(nominal: '50000');
      expect(result.qrisString, contains('5802ID'));
    });

    test('ends with valid 4-char hex CRC', () {
      final result = qris.convertFromStatic(nominal: '50000');
      final crc = result.qrisString.substring(result.qrisString.length - 4);
      expect(RegExp(r'^[0-9A-F]{4}$').hasMatch(crc), isTrue);
    });

    test('throws on empty nominal', () {
      expect(
        () => qris.convertFromStatic(nominal: ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('QrisDinamis.parse', () {
    late QrisDinamis qris;

    setUp(() {
      qris = QrisDinamis(sampleQris);
    });

    test('extracts merchant name', () {
      final data = qris.parse();
      expect(data.merchantName, isNotEmpty);
      expect(data.merchantName, equals(data.merchantName.toUpperCase()));
    });

    test('extracts NMID starting with ID', () {
      final data = qris.parse();
      expect(data.nmid, startsWith('ID'));
    });

    test('extracts id type', () {
      final data = qris.parse();
      expect(data.id, anyOf(equals('A01'), equals('01')));
    });

    test('extracts 8-digit NNS', () {
      final data = qris.parse();
      expect(data.nns, isNotEmpty);
      expect(data.nns.length, equals(8));
    });
  });
}
