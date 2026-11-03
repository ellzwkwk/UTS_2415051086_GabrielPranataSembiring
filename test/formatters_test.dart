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

  group('tanggal ISO', () {
    test('formatIsoDate memakai nol di depan', () {
      expect(formatIsoDate(DateTime(2026, 11, 2)), '2026-11-02');
    });

    test('parseIsoDate hanya mengambil tanggalnya', () {
      expect(parseIsoDate('2026-11-02'), DateTime(2026, 11, 2));
      expect(parseIsoDate('2026-11-02T10:30:00'), DateTime(2026, 11, 2));
    });
  });

  group('tanggal tampilan', () {
    test('formatShortDate', () {
      expect(formatShortDate(DateTime(2026, 11, 2)), '2 Nov');
      expect(formatShortDate(DateTime(2026, 8, 17)), '17 Agu');
    });

    test('formatLongDate', () {
      expect(formatLongDate(DateTime(2026, 11, 2)), '2 November 2026');
    });
  });
}