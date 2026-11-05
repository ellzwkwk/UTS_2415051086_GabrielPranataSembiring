import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/models/transaction.dart';
import 'package:dompetku/providers/transaction_provider.dart';
import 'package:dompetku/repositories/transaction_repository.dart';
import 'package:dompetku/services/sample_transaction_data_source.dart';

class _FailsAfterFirst extends SampleTransactionDataSource {
  _FailsAfterFirst() : super(delay: Duration.zero);

  int calls = 0;

  @override
  Future<List<Transaction>> fetchAll() async {
    calls++;
    if (calls > 1) throw Exception('Jaringan putus');
    return super.fetchAll();
  }
}

class _FailsFirst extends SampleTransactionDataSource {
  _FailsFirst() : super(delay: Duration.zero);

  int calls = 0;

  @override
  Future<List<Transaction>> fetchAll() async {
    calls++;
    if (calls == 1) throw Exception('Jaringan putus');
    return super.fetchAll();
  }
}

class _Counting extends SampleTransactionDataSource {
  _Counting() : super(delay: Duration.zero);

  int calls = 0;

  @override
  Future<List<Transaction>> fetchAll() {
    calls++;
    return super.fetchAll();
  }
}

TransactionProvider makeProvider(SampleTransactionDataSource dataSource) {
  return TransactionProvider(
    TransactionRepository(dataSource),
    clock: () => DateTime(2026, 11, 3),
  );
}

void main() {
  group('TransactionProvider.refresh', () {
    test('berhasil: memuat ulang tanpa menjadikan isLoading true', () async {
      final ds = SampleTransactionDataSource(delay: Duration.zero);
      final p = makeProvider(ds);
      await p.load();

      // Data berubah di server tanpa sepengetahuan provider.
      await ds.create(
        Transaction(
          studentId: '2415051086',
          title: 'Baru',
          amount: 1000,
          type: TransactionType.expense,
          category: 'Lainnya',
          account: 'Tunai',
          date: DateTime(2026, 11, 3),
        ),
      );

      final loadingStates = <bool>[];
      final refreshingStates = <bool>[];
      p.addListener(() {
        loadingStates.add(p.isLoading);
        refreshingStates.add(p.isRefreshing);
      });

      final result = await p.refresh();

      expect(result, isNull);
      expect(p.items.length, 9);
      expect(refreshingStates, [true, false]);
      expect(loadingStates, [false, false]);
    });

    test('gagal: data lama tetap ada dan pesan dikembalikan', () async {
      final p = makeProvider(_FailsAfterFirst());
      await p.load();

      final result = await p.refresh();

      expect(result, 'Jaringan putus');
      expect(p.items.length, 8);
      expect(p.error, isNull);
      expect(p.isRefreshing, isFalse);
    });

    test('berhasil setelah muat awal gagal: error dihapus', () async {
      final p = makeProvider(_FailsFirst());
      await p.load();
      expect(p.error, 'Jaringan putus');

      final result = await p.refresh();

      expect(result, isNull);
      expect(p.error, isNull);
      expect(p.items.length, 8);
    });

    test('refresh yang sedang berjalan tidak diulang', () async {
      final ds = _Counting();
      final p = makeProvider(ds);
      await p.load();
      expect(ds.calls, 1);

      final first = p.refresh();
      final second = await p.refresh();
      await first;

      expect(second, isNull);
      expect(ds.calls, 2);
    });
  });
}