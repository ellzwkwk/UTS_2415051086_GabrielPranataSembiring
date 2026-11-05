import '../config/app_constants.dart';
import '../models/transaction.dart';
import 'transaction_data_source.dart';

const _income = TransactionType.income;
const _expense = TransactionType.expense;

Transaction _tx(
  int id,
  String title,
  int amount,
  TransactionType type,
  String category,
  String account,
  DateTime date, [
  String note = '',
]) {
  return Transaction(
    id: id,
    studentId: AppConstants.studentId,
    title: title,
    amount: amount,
    type: type,
    category: category,
    account: account,
    note: note,
    date: date,
  );
}

class SampleTransactionDataSource implements TransactionDataSource {
  SampleTransactionDataSource({
    this.delay = const Duration(milliseconds: 400),
    this.shouldFail = false,
  });

  /// Jeda buatan agar state loading terlihat.
  final Duration delay;

  /// Ubah ke true untuk menguji tampilan error.
  final bool shouldFail;

  static final List<Transaction> seed = [
    _tx(1, 'Saldo awal', 350000, _income, 'Saldo awal', 'Tunai', DateTime(2026, 10, 31)),
    _tx(2, 'Saldo awal', 500000, _income, 'Saldo awal', 'Bank', DateTime(2026, 10, 31)),
    _tx(3, 'Saldo awal', 150000, _income, 'Saldo awal', 'E-wallet', DateTime(2026, 10, 31)),
    _tx(4, 'Uang saku', 2000000, _income, 'Uang saku', 'Bank', DateTime(2026, 11, 1)),
    _tx(5, 'Bayar kos', 800000, _expense, 'Tempat tinggal', 'Bank', DateTime(2026, 11, 1), 'Kos bulan November'),
    _tx(6, 'Makan siang warteg', 18000, _expense, 'Makanan', 'Tunai', DateTime(2026, 11, 2), 'Warteg dekat kampus'),
    _tx(7, 'Fotokopi modul', 12500, _expense, 'Kuliah', 'Tunai', DateTime(2026, 11, 2)),
    _tx(8, 'Honor asisten lab', 450000, _income, 'Honor', 'E-wallet', DateTime(2026, 11, 2)),
  ];

  final List<Transaction> _rows = List.of(seed);

  @override
  Future<List<Transaction>> fetchAll() async {
    await Future.delayed(delay);
    if (shouldFail) throw Exception('Gagal memuat data (simulasi)');
    return List.of(_rows);
  }

  @override
  Future<Transaction> create(Transaction transaction) async {
    await Future.delayed(delay);
    if (shouldFail) throw Exception('Gagal menyimpan data (simulasi)');

    var maxId = 0;
    for (final t in _rows) {
      if ((t.id ?? 0) > maxId) maxId = t.id ?? 0;
    }
    final created = transaction.copyWith(id: maxId + 1);
    _rows.add(created);
    return created;
  }

  @override
  Future<Transaction> update(Transaction transaction) async {
    await Future.delayed(delay);
    if (shouldFail) throw Exception('Gagal memperbarui data (simulasi)');

    final index = _rows.indexWhere((t) => t.id == transaction.id);
    if (index < 0) throw Exception('Transaksi tidak ditemukan');

    _rows[index] = transaction;
    return transaction;
  }
}