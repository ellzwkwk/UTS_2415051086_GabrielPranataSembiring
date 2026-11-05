import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/models/transaction.dart';
import 'package:dompetku/providers/transaction_provider.dart';
import 'package:dompetku/repositories/transaction_repository.dart';
import 'package:dompetku/services/api_exception.dart';
import 'package:dompetku/services/sample_transaction_data_source.dart';

class _FailingCreate extends SampleTransactionDataSource {
  _FailingCreate() : super(delay: Duration.zero);

  @override
  Future<Transaction> create(Transaction transaction) async =>
      throw Exception('Koneksi terputus');
}

Transaction newTx({int amount = 25000}) => Transaction(
      studentId: '2415051086',
      title: 'Bensin motor',
      amount: amount,
      type: TransactionType.expense,
      category: 'Transport',
      account: 'Tunai',
      date: DateTime(2026, 11, 3),
    );

TransactionProvider makeProvider(SampleTransactionDataSource dataSource) {
  return TransactionProvider(
    TransactionRepository(dataSource),
    clock: () => DateTime(2026, 11, 3),
  );
}

void main() {
  group('TransactionProvider.add', () {
    test('menambah transaksi dengan id dari server dan memberi tahu listener',
        () async {
      final p = makeProvider(SampleTransactionDataSource(delay: Duration.zero));
      await p.load();

      var notified = 0;
      p.addListener(() => notified++);

      final created = await p.add(newTx());

      expect(created.id, 9);
      expect(p.items.length, 9);
      expect(p.sortedItems.first.title, 'Bensin motor');
      expect(notified, 1);
    });

    test('saldo dan ringkasan ikut berubah', () async {
      final p = makeProvider(SampleTransactionDataSource(delay: Duration.zero));
      await p.load();

      await p.add(newTx(amount: 25000));

      expect(p.totalBalance, 2619500 - 25000);
      expect(p.expenseThisMonth, 830500 + 25000);
      expect(p.balanceByAccount['Tunai'], 319500 - 25000);
    });

    test('gagal menyimpan melempar ApiException dan data tidak berubah',
        () async {
      final p = makeProvider(_FailingCreate());
      await p.load();

      await expectLater(
        p.add(newTx()),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Koneksi terputus'),
        ),
      );

      expect(p.items.length, 8);
      expect(p.totalBalance, 2619500);
    });
  });

  group('SampleTransactionDataSource.create', () {
    test('id bertambah berurutan', () async {
      final ds = SampleTransactionDataSource(delay: Duration.zero);

      final a = await ds.create(newTx());
      final b = await ds.create(newTx());

      expect(a.id, 9);
      expect(b.id, 10);
      expect((await ds.fetchAll()).length, 10);
    });
  });
}