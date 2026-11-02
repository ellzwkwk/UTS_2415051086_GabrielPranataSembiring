import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/utils/formatters.dart';

void main() {
  group('formatRupiah', () {
    test('memberi pemisah ribuan', () {
      expect(formatRupiah(2619500), 'Rp 2.619.500');
    });

    test('angka kecil tanpa pemisah', () {
      expect(formatRupiah(500), 'Rp 500');
      expect(formatRupiah(0), 'Rp 0');
    });

    test('angka negatif', () {
      expect(formatRupiah(-12500), '-Rp 12.500');
    });
  });
}