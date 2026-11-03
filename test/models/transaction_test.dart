import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/models/transaction.dart';

void main() {
  // Bentuknya sama seperti satu baris dari Supabase.
  const row = {
    'id': 7,
    'student_id': '2415051086',
    'title': 'Makan siang warteg',
    'amount': 18000,
    'type': 'expense',
    'category': 'Makanan',
    'account': 'Tunai',
    'note': 'Warteg dekat kampus',
    'trx_date': '2026-11-02',
    'created_at': '2026-11-02T03:15:00+00:00',
  };

  group('Transaction.fromJson', () {
    test('mengubah satu baris JSON menjadi objek', () {
      final tx = Transaction.fromJson(row);

      expect(tx.id, 7);
      expect(tx.studentId, '2415051086');
      expect(tx.title, 'Makan siang warteg');
      expect(tx.amount, 18000);
      expect(tx.type, TransactionType.expense);
      expect(tx.isIncome, isFalse);
      expect(tx.category, 'Makanan');
      expect(tx.account, 'Tunai');
      expect(tx.note, 'Warteg dekat kampus');
      expect(tx.date, DateTime(2026, 11, 2));
    });

    test('amount bertipe desimal tetap menjadi int', () {
      final json = Map<String, dynamic>.from(row)..['amount'] = 18000.0;
      expect(Transaction.fromJson(json).amount, 18000);
    });

    test('note kosong atau null menjadi string kosong', () {
      final json = Map<String, dynamic>.from(row)..['note'] = null;
      expect(Transaction.fromJson(json).note, '');
    });

    test('jenis transaksi tidak dikenal melempar FormatException', () {
      final json = Map<String, dynamic>.from(row)..['type'] = 'selesai';
      expect(() => Transaction.fromJson(json), throwsFormatException);
    });

    test('field wajib yang hilang melempar TypeError', () {
      final json = Map<String, dynamic>.from(row)..remove('title');
      expect(() => Transaction.fromJson(json), throwsA(isA<TypeError>()));
    });
  });

  group('Transaction.toJson', () {
    test('tidak mengirim id dan memformat tanggal', () {
      final tx = Transaction.fromJson(row);

      expect(tx.toJson(), {
        'student_id': '2415051086',
        'title': 'Makan siang warteg',
        'amount': 18000,
        'type': 'expense',
        'category': 'Makanan',
        'account': 'Tunai',
        'note': 'Warteg dekat kampus',
        'trx_date': '2026-11-02',
      });
    });

    test('fromJson lalu toJson menghasilkan data yang sama', () {
      final first = Transaction.fromJson(row).toJson();
      final second = Transaction.fromJson(first).toJson();
      expect(second, first);
    });
  });

  group('Transaction.copyWith', () {
    test('hanya mengubah field yang diberikan', () {
      final tx = Transaction.fromJson(row);
      final edited = tx.copyWith(title: 'Makan malam', amount: 25000);

      expect(edited.title, 'Makan malam');
      expect(edited.amount, 25000);
      expect(edited.id, tx.id);
      expect(edited.category, tx.category);
      expect(tx.title, 'Makan siang warteg');
    });
  });
}