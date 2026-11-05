import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/models/transaction.dart';
import 'package:dompetku/providers/transaction_provider.dart';
import 'package:dompetku/repositories/transaction_repository.dart';
import 'package:dompetku/services/api_exception.dart';
import 'package:dompetku/services/sample_transaction_data_source.dart';

class _FailingUpdate extends SampleTransactionDataSource {
  _FailingUpdate() : super(delay: Duration.zero);

  @override
  Future<Transaction> update(Transaction transaction) async =>
      throw Exception('Koneksi terputus');
}

TransactionProvider makeProvider(SampleTransactionDataSource dataSource) {
  return TransactionProvider(
    TransactionRepository(dataSource),
    clock: () => DateTime(2026, 11, 3),
  );
}

void main() {
  group('TransactionProvider.update', () {
    late TransactionProvider p;

    setUp(() async {
      p = makeProvider(SampleTransactionDataSource(delay: Duration.zero));
      await p.load();
    });

    test('mengganti transaksi, jumlah tetap, dan memberi tahu listener',
        () async {
      var notified = 0;
      p.addListener(() => notified++);

      final original = p.findById(6)!;
      await p.update(original.copyWith(amount: 20000));

      expect(p.findById(6)!.amount, 20000);
      expect(p.items.length, 8);
      expect(notified, 1);
    });

    test('saldo dan ringkasan dihitung ulang', () async {
      await p.update(p.findById(6)!.copyWith(amount: 20000));

      expect(p.totalBalance, 2619500 - 2000);
      expect(p.expenseThisMonth, 830500 + 2000);
    });

    test('pindah akun memindahkan saldo antar akun', () async {
      await p.update(p.findById(6)!.copyWith(account: 'Bank'));

      expect(p.balanceByAccount['Tunai'], 319500 + 18000);
      expect(p.balanceByAccount['Bank'], 1700000 - 18000);
      expect(p.totalBalance, 2619500);
    });

    test('mengubah jenis keluar menjadi masuk menggeser total', () async {
      await p.update(
        p.findById(7)!.copyWith(type: TransactionType.income),
      );

      expect(p.totalBalance, 2619500 + 25000);
      expect(p.incomeThisMonth, 2450000 + 12500);
      expect(p.expenseThisMonth, 830500 - 12500);
    });

    test('findById mengembalikan null untuk id kosong atau tidak ada', () {
      expect(p.findById(null), isNull);
      expect(p.findById(999), isNull);
      expect(p.findById(6)?.title, 'Makan siang warteg');
    });
  });

  group('gagal memperbarui', () {
    test('melempar ApiException dan data tidak berubah', () async {
      final p = makeProvider(_FailingUpdate());
      await p.load();

      await expectLater(
        p.update(p.findById(6)!.copyWith(amount: 99999)),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Koneksi terputus'),
        ),
      );

      expect(p.findById(6)!.amount, 18000);
      expect(p.totalBalance, 2619500);
    });
  });

  group('SampleTransactionDataSource.update', () {
    test('perubahan tersimpan untuk pemuatan berikutnya', () async {
      final ds = SampleTransactionDataSource(delay: Duration.zero);
      final original = (await ds.fetchAll()).firstWhere((t) => t.id == 6);

      await ds.update(original.copyWith(title: 'Makan malam'));

      final after = (await ds.fetchAll()).firstWhere((t) => t.id == 6);
      expect(after.title, 'Makan malam');
    });

    test('id yang tidak ada ditolak', () async {
      final ds = SampleTransactionDataSource(delay: Duration.zero);
      final ghost = (await ds.fetchAll()).first.copyWith(id: 999);

      expect(ds.update(ghost), throwsException);
    });
  });
}