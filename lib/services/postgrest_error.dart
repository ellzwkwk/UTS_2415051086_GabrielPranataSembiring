import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'api_exception.dart';

/// Menerjemahkan kesalahan database Supabase menjadi pesan yang ramah.
/// [action] dipakai untuk kesalahan yang tidak dikenali, misalnya
/// "menyimpan transaksi".
ApiException apiExceptionFromPostgrest(PostgrestException e, String action) {
  final code = e.code;
  final message = e.message.toLowerCase();

  final String text;
  if (code == '23514' || code == '23502' || code == '22003' || code == '22P02') {
    text = 'Data ditolak database karena tidak memenuhi aturan tabel.';
  } else if (code == '42501') {
    text = 'Aksi ditolak oleh aturan akses database (RLS).';
  } else if (code == '42P01' || code == 'PGRST205') {
    text = 'Tabel database tidak ditemukan. Periksa nama tabel di aplikasi.';
  } else if (code == '42703' || code == 'PGRST204') {
    text = 'Kolom database tidak ditemukan. Periksa nama kolom di aplikasi.';
  } else if (message.contains('api key') || message.contains('jwt')) {
    text = 'Kunci akses database tidak valid. Periksa konfigurasi Supabase.';
  } else {
    text = 'Gagal $action: ${e.message}';
  }

  return ApiException(text, code: code);
}