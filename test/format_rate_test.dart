import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/utils/formatters.dart';

void main() {
  group('formatIdrRate', () {
    test('kurs besar dibulatkan dengan pemisah ribuan', () {
      expect(formatIdrRate(18148), '18.148');
      expect(formatIdrRate(20275.056), '20.275');
    });

    test('kurs kecil memakai dua desimal dengan koma', () {
      expect(formatIdrRate(115.4086), '115,41');
    });
  });
}