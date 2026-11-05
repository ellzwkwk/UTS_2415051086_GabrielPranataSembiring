import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/models/transaction.dart';
import 'package:dompetku/providers/transaction_provider.dart';
import 'package:dompetku/repositories/transaction_repository.dart';
import 'package:dompetku/services/api_exception.dart';
import 'package:dompetku/services/sample_transaction_data_source.dart';

class _FailingDelete extends SampleTransactionDataSource {
  _FailingDelete() : super(delay: Duration.zero);

  @override
  Future<void> delete(int id) async => throw Exception('Koneksi terputus');
}

TransactionProvider makeProvider(SampleTransactionDataSource dataSource) {
  return TransactionProvider(
    TransactionRepository(dataSource),
    clock: () => DateTime(2026, 11, 3),
  );
}

void main() {
  group('TransactionProvider.remove', () {
    late TransactionProvider p;

    setUp(() async {
      p = makeProvider(SampleTransactionDataSource(delay: Duration.zero));
      await p.load();
    });

    test('menghapus transaksi dari daftar dan memberi tahu listener',
        () async {
      var notified = 0;
      p.addListener(() => notified++);

      await p.remove(p.findById(6)!);

      expect(p.items.length, 7);
      expect(p.findById(6), isNull);
      expect(notified, 1);
    });

    test('menghapus pengeluaran menambah saldo', () async {
      await p.remove(p.findById(6)!);

      expect(p.totalBalance, 2619500 + 18000);
      expect(p.expenseThisMonth, 830500 - 18000);
      expect(p.balanceByAccount['Tunai'], 319500 + 18000);
    });

    test('menghapus pemasukan mengurangi saldo', () async {
      await p.remove(p.findById(8)!);

      expect(p.totalBalance, 2619500 - 450000);
      expect(p.incomeThisMonth, 2450000 - 450000);
      expect(p.balanceByAccount['E-wallet'], 600000 - 450000);
    });

    test('transaksi lain tidak terpengaruh', () async {
      await p.remove(p.findById(6)!);

      expect(p.findById(5)?.title, 'Bayar kos');
      expect(p.findById(7)?.title, 'Fotokopi modul');
    });

    test('transaksi tanpa id ditolak dan data tidak berubah', () async {
      final unsaved = Transaction(
        studentId: '2415051086',
        title: 'Belum tersimpan',
        amount: 1000,
        type: TransactionType.expense,
        category: 'Lainnya',
        account: 'Tunai',
        date: DateTime(2026, 11, 3),
      );

      await expectLater(p.remove(unsaved), throwsA(isA<ApiException>()));
      expect(p.items.length, 8);
    });
  });

  group('gagal menghapus', () {
    test('melempar ApiException dan daftar tidak berubah', () async {
      final p = makeProvider(_FailingDelete());
      await p.load();

      await expectLater(
        p.remove(p.findById(6)!),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Koneksi terputus'),
        ),
      );

      expect(p.items.length, 8);
      expect(p.findById(6), isNotNull);
      expect(p.totalBalance, 2619500);
    });
  });

  group('SampleTransactionDataSource.delete', () {
    test('baris yang dihapus tidak muncul lagi saat dimuat ulang', () async {
      final ds = SampleTransactionDataSource(delay: Duration.zero);

      await ds.delete(6);

      final rows = await ds.fetchAll();
      expect(rows.length, 7);
      expect(rows.any((t) => t.id == 6), isFalse);
    });

    test('id yang tidak ada ditolak', () async {
      final ds = SampleTransactionDataSource(delay: Duration.zero);
      expect(ds.delete(999), throwsException);
    });

    test('menghapus dua kali pada id yang sama gagal pada kali kedua',
        () async {
      final ds = SampleTransactionDataSource(delay: Duration.zero);

      await ds.delete(6);
      expect(ds.delete(6), throwsException);
    });
  });
}