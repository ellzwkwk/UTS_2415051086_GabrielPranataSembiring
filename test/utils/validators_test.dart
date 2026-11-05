import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/utils/validators.dart';

void main() {
  group('validateTitle', () {
    test('judul kosong atau hanya spasi ditolak', () {
      expect(validateTitle(null), 'Judul wajib diisi');
      expect(validateTitle(''), 'Judul wajib diisi');
      expect(validateTitle('   '), 'Judul wajib diisi');
    });

    test('judul terlalu panjang ditolak', () {
      expect(validateTitle('a' * 61), 'Judul maksimal 60 karakter');
    });

    test('judul wajar diterima', () {
      expect(validateTitle('Makan siang'), isNull);
      expect(validateTitle('a' * 60), isNull);
    });
  });

  group('parseAmount', () {
    test('mengambil angkanya saja', () {
      expect(parseAmount('25000'), 25000);
      expect(parseAmount('1.250.000'), 1250000);
      expect(parseAmount('Rp 500'), 500);
    });

    test('tanpa angka menghasilkan null', () {
      expect(parseAmount(null), isNull);
      expect(parseAmount(''), isNull);
      expect(parseAmount('abc'), isNull);
    });
  });

  group('validateAmount', () {
    test('kosong ditolak', () {
      expect(validateAmount(''), 'Nominal wajib diisi');
      expect(validateAmount('abc'), 'Nominal wajib diisi');
    });

    test('nol ditolak', () {
      expect(validateAmount('0'), 'Nominal harus lebih dari 0');
      expect(validateAmount('000'), 'Nominal harus lebih dari 0');
    });

    test('di atas batas ditolak', () {
      expect(
        validateAmount('1000000000'),
        'Nominal maksimal Rp 999.999.999',
      );
    });

    test('nominal wajar diterima', () {
      expect(validateAmount('1'), isNull);
      expect(validateAmount('25.000'), isNull);
      expect(validateAmount('999999999'), isNull);
    });
  });
}