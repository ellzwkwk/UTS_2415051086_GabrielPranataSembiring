import '../theme/app_tokens.dart';

const kAccounts = ['Tunai', 'Bank', 'E-wallet'];

const kExpenseCategories = [
  'Makanan',
  'Transport',
  'Kuliah',
  'Tempat tinggal',
  'Belanja',
  'Kesehatan',
  'Lainnya',
];

const kIncomeCategories = ['Uang saku', 'Honor', 'Gaji', 'Lainnya'];

const _expenseTones = <String, TagTone>{
  'Makanan': TagTone.amber,
  'Belanja': TagTone.amber,
  'Kuliah': TagTone.blue,
  'Transport': TagTone.blue,
  'Lainnya': TagTone.blue,
  'Tempat tinggal': TagTone.rose,
  'Kesehatan': TagTone.rose,
};

/// Warna tag kategori. Semua pemasukan hijau.
TagTone toneForCategory(String category, {required bool isIncome}) {
  if (isIncome) return TagTone.green;
  return _expenseTones[category] ?? TagTone.blue;
}