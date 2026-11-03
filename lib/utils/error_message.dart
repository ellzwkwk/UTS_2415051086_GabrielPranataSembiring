import 'dart:async';
import '../services/api_exception.dart';

String friendlyError(Object e) {
  if (e is ApiException) return e.message;
  if (e is TimeoutException) return 'Server terlalu lama merespons. Coba lagi.';
  if (e is FormatException || e is TypeError) {
    return 'Format data dari server tidak sesuai.';
  }

  final text = e.toString();
  const networkMarkers = [
    'SocketException',
    'ClientException',
    'Failed host lookup',
    'Failed to fetch',
    'XMLHttpRequest',
    'Connection refused',
    'Network is unreachable',
  ];
  if (networkMarkers.any(text.contains)) {
    return 'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.';
  }

  return text.replaceFirst('Exception: ', '');
}