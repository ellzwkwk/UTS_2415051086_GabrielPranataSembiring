import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:dompetku/services/api_exception.dart';
import 'package:dompetku/utils/error_message.dart';

void main() {
  test('ApiException memakai pesannya sendiri', () {
    expect(friendlyError(ApiException('Pesan khusus')), 'Pesan khusus');
  });

  test('timeout', () {
    expect(
      friendlyError(TimeoutException('lama')),
      'Server terlalu lama merespons. Coba lagi.',
    );
  });

  test('format data tidak sesuai', () {
    expect(friendlyError(const FormatException('x')), contains('Format data'));
  });

  test('masalah jaringan', () {
    expect(
      friendlyError(http.ClientException('Failed to fetch')),
      startsWith('Tidak ada koneksi internet'),
    );
  });

  test('exception biasa dibersihkan dari awalan', () {
    expect(friendlyError(Exception('pesan')), 'pesan');
  });
}