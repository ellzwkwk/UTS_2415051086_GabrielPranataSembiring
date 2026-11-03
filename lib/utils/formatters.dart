/// 2619500 -> "2.619.500"
String formatNumber(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// 2619500 -> "Rp 2.619.500"
String formatRupiah(int value) =>
    '${value < 0 ? '-' : ''}Rp ${formatNumber(value)}';

/// DateTime(2026, 11, 2) -> "2026-11-02" (format kolom date di database).
String formatIsoDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// "2026-11-02" atau "2026-11-02T10:30:00" -> hanya tanggalnya.
DateTime parseIsoDate(String raw) {
  final parsed = DateTime.parse(raw);
  return DateTime(parsed.year, parsed.month, parsed.day);
}