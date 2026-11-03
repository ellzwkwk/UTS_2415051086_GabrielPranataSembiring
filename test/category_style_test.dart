import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/theme/app_tokens.dart';
import 'package:dompetku/utils/category_style.dart';

void main() {
  test('pemasukan selalu hijau', () {
    expect(toneForCategory('Honor', isIncome: true), TagTone.green);
    expect(toneForCategory('Apa saja', isIncome: true), TagTone.green);
  });

  test('pengeluaran memakai warna kategori', () {
    expect(toneForCategory('Makanan', isIncome: false), TagTone.amber);
    expect(toneForCategory('Kuliah', isIncome: false), TagTone.blue);
    expect(toneForCategory('Tempat tinggal', isIncome: false), TagTone.rose);
  });

  test('kategori tidak dikenal memakai biru', () {
    expect(toneForCategory('Baru', isIncome: false), TagTone.blue);
  });
}