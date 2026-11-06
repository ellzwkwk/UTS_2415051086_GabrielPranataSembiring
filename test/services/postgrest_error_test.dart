import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:dompetku/services/postgrest_error.dart';

void main() {
  ApiExceptionResult map(String? code, String message) {
    final result = apiExceptionFromPostgrest(
      PostgrestException(message: message, code: code),
      'menyimpan transaksi',
    );
    return ApiExceptionResult(result.message, result.code);
  }

  test('pelanggaran constraint menjadi pesan aturan tabel', () {
    for (final code in ['23514', '23502', '22003', '22P02']) {
      final r = map(code, 'apa saja');
      expect(r.message, contains('tidak memenuhi aturan tabel'));
      expect(r.code, code);
    }
  });

  test('RLS menolak (42501)', () {
    final r = map('42501', 'new row violates row-level security policy');
    expect(r.message, contains('aturan akses database'));
    expect(r.code, '42501');
  });

  test('tabel tidak ditemukan', () {
    expect(map('PGRST205', 'x').message, contains('Tabel database tidak ditemukan'));
    expect(map('42P01', 'x').message, contains('Tabel database tidak ditemukan'));
  });

  test('kolom tidak ditemukan', () {
    expect(map('PGRST204', 'x').message, contains('Kolom database tidak ditemukan'));
    expect(map('42703', 'x').message, contains('Kolom database tidak ditemukan'));
  });

  test('API key tidak valid dikenali dari pesannya', () {
    expect(map(null, 'Invalid API key').message, contains('Kunci akses'));
    expect(map(null, 'JWT expired').message, contains('Kunci akses'));
  });

  test('kesalahan lain memakai nama aksi dan pesan asli', () {
    final r = map('99999', 'sesuatu rusak');
    expect(r.message, 'Gagal menyimpan transaksi: sesuatu rusak');
  });
}

class ApiExceptionResult {
  ApiExceptionResult(this.message, this.code);

  final String message;
  final String? code;
}