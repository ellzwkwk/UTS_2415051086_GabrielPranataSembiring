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

const _monthsShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

const _monthsLong = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

/// DateTime(2026, 11, 2) -> "2 Nov"
String formatShortDate(DateTime date) =>
    '${date.day} ${_monthsShort[date.month - 1]}';

/// DateTime(2026, 11, 2) -> "2 November 2026"
String formatLongDate(DateTime date) =>
    '${date.day} ${_monthsLong[date.month - 1]} ${date.year}';

/// 18148.0 -> "18.148", 115.4086 -> "115,41"
String formatIdrRate(double value) {
  if (value >= 1000) return formatNumber(value.round());
  return value.toStringAsFixed(2).replaceAll('.', ',');
}

/// Nominal mata uang asing dengan format Indonesia.
/// 144.34 USD -> "144,34", 22697.62 JPY -> "22.698" (yen tanpa desimal).
String formatForeignAmount(double value, String code) {
  final decimals = code == 'JPY' ? 0 : 2;
  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final whole = formatNumber(int.parse(parts[0]));
  final isZero = double.parse(fixed) == 0;
  final sign = (value < 0 && !isZero) ? '-' : '';
  return decimals == 0 ? '$sign$whole' : '$sign$whole,${parts[1]}';
}