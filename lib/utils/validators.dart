import 'formatters.dart';

/// Batas wajar nominal di aplikasi (di bawah Rp 1 miliar).
const int kMaxAmount = 999999999;

String? validateTitle(String? value) {
  final text = (value ?? '').trim();
  if (text.isEmpty) return 'Judul wajib diisi';
  if (text.length > 60) return 'Judul maksimal 60 karakter';
  return null;
}

/// "25.000" -> 25000. Null jika tidak ada angka sama sekali.
int? parseAmount(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  return int.tryParse(digits);
}

String? validateAmount(String? value) {
  final amount = parseAmount(value);
  if (amount == null) return 'Nominal wajib diisi';
  if (amount <= 0) return 'Nominal harus lebih dari 0';
  if (amount > kMaxAmount) {
    return 'Nominal maksimal Rp ${formatNumber(kMaxAmount)}';
  }
  return null;
}