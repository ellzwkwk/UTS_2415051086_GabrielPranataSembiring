import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/models/transaction.dart';
import 'package:dompetku/models/transaction_filter.dart';
import 'package:dompetku/providers/transaction_provider.dart';
import 'package:dompetku/repositories/transaction_repository.dart';
import 'package:dompetku/services/sample_transaction_data_source.dart';
import 'package:dompetku/services/transaction_data_source.dart';

class _FlakyDataSource implements TransactionDataSource {
  int _calls = 0;

  @override
  Future<List<Transaction>> fetchAll() async {
    _calls++;
    if (_calls == 1) throw Exception('Jaringan putus');
    return SampleTransactionDataSource.seed;
  }
  @override
  Future<Transaction> create(Transaction transaction) async => transaction;
}

TransactionProvider makeProvider({bool fail = false}) {
  final repository = TransactionRepository(
    SampleTransactionDataSource(delay: Duration.zero, shouldFail: fail),
  );
  // Tanggal dikunci supaya "bulan ini" selalu November 2026.
  return TransactionProvider(repository, clock: () => DateTime(2026, 11, 2));
}

void main() {
  group('memuat data', () {
    test('awalnya kosong dan tidak loading', () {
      final p = makeProvider();
      expect(p.items, isEmpty);
      expect(p.isLoading, isFalse);
      expect(p.error, isNull);
      expect(p.hasData, isFalse);
    });

    test('isLoading berubah true lalu false dan data terisi', () async {
      final p = makeProvider();
      final states = <bool>[];
      p.addListener(() => states.add(p.isLoading));

      await p.load();

      expect(states, [true, false]);
      expect(p.items.length, 8);
      expect(p.hasData, isTrue);
    });

    test('gagal memuat mengisi error', () async {
      final p = makeProvider(fail: true);
      await p.load();

      expect(p.error, 'Gagal memuat data (simulasi)');
      expect(p.items, isEmpty);
      expect(p.isLoading, isFalse);
    });

    test('muat ulang setelah gagal menghapus error', () async {
      final p = TransactionProvider(
        TransactionRepository(_FlakyDataSource()),
        clock: () => DateTime(2026, 11, 2),
      );

      await p.load();
      expect(p.error, 'Jaringan putus');

      await p.load();
      expect(p.error, isNull);
      expect(p.items.length, 8);
    });
  });

  group('ringkasan', () {
    late TransactionProvider p;

    setUp(() async {
      p = makeProvider();
      await p.load();
    });

    test('total saldo', () {
      expect(p.totalBalance, 2619500);
    });

    test('saldo awal bulan, masuk, dan keluar bulan ini', () {
      expect(p.openingBalance, 1000000);
      expect(p.incomeThisMonth, 2450000);
      expect(p.expenseThisMonth, 830500);
      expect(
        p.openingBalance + p.incomeThisMonth - p.expenseThisMonth,
        p.totalBalance,
      );
    });

    test('saldo per akun', () {
      expect(p.balanceByAccount, {
        'Tunai': 319500,
        'Bank': 1700000,
        'E-wallet': 600000,
      });
    });

    test('daftar terurut dari yang terbaru', () {
      final sorted = p.sortedItems;
      expect(sorted.first.title, 'Honor asisten lab');
      expect(sorted.last.id, 1);
    });

    test('latest mengambil beberapa transaksi teratas', () {
      expect(p.latest(2).map((t) => t.id), [8, 7]);
    });
  });

  group('filter', () {
    late TransactionProvider p;

    setUp(() async {
      p = makeProvider();
      await p.load();
    });

    test('tanpa filter menampilkan semua', () {
      expect(p.visibleItems.length, 8);
      expect(p.filter.isActive, isFalse);
    });

    test('filter jenis', () {
      p.setType(TransactionType.income);
      expect(p.visibleItems.length, 5);
      expect(p.visibleItems.every((t) => t.isIncome), isTrue);

      p.setType(TransactionType.expense);
      expect(p.visibleItems.length, 3);

      p.setType(null);
      expect(p.visibleItems.length, 8);
    });

    test('pencarian tidak membedakan huruf besar kecil', () {
      p.setQuery('WARTEG');
      expect(p.visibleItems.map((t) => t.title), ['Makan siang warteg']);
    });

    test('pencarian juga mencocokkan akun dan catatan', () {
      p.setQuery('bank');
      expect(p.visibleItems.length, 3);

      p.setQuery('november');
      expect(p.visibleItems.map((t) => t.title), ['Bayar kos']);
    });

    test('filter periode', () {
      p.setPeriod(TransactionPeriod.thisMonth);
      expect(p.visibleItems.length, 5);

      p.setPeriod(TransactionPeriod.lastMonth);
      expect(p.visibleItems.length, 3);

      p.setPeriod(TransactionPeriod.all);
      expect(p.visibleItems.length, 8);
    });

    test('filter digabung', () {
      p.setPeriod(TransactionPeriod.thisMonth);
      p.setType(TransactionType.expense);
      expect(p.visibleItems.length, 3);
      expect(p.filter.isActive, isTrue);
    });

    test('clearFilters mengembalikan semuanya', () {
      p.setType(TransactionType.income);
      p.setQuery('abc');
      p.clearFilters();

      expect(p.filter.isActive, isFalse);
      expect(p.visibleItems.length, 8);
    });

    test('setiap perubahan filter memberi tahu listener', () {
      var calls = 0;
      p.addListener(() => calls++);

      p.setType(TransactionType.income);
      p.setQuery('a');
      p.setPeriod(TransactionPeriod.thisMonth);
      p.clearFilters();

      expect(calls, 4);
    });
  });
}