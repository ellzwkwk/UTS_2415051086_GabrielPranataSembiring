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