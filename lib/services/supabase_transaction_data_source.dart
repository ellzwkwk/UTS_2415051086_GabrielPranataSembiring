import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, Supabase, SupabaseClient;
import '../config/app_constants.dart';
import '../models/transaction.dart';
import 'api_exception.dart';
import 'postgrest_error.dart';
import 'transaction_data_source.dart';

class SupabaseTransactionDataSource implements TransactionDataSource {
  SupabaseTransactionDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _table = 'transactions';
  static const _timeout = Duration(seconds: 15);

  /// Menjalankan satu permintaan dengan batas waktu, dan menerjemahkan
  /// kesalahan database menjadi [ApiException] yang ramah.
  ///
  /// [mayHaveApplied] dipakai untuk permintaan tulis yang tidak aman diulang:
  /// jika kena batas waktu, server mungkin sudah memprosesnya.
  Future<T> _run<T>(
    String action,
    Future<T> Function() request, {
    bool mayHaveApplied = false,
  }) async {
    try {
      return await request().timeout(_timeout);
    } on PostgrestException catch (e) {
      throw apiExceptionFromPostgrest(e, action);
    } on TimeoutException {
      if (mayHaveApplied) {
        throw ApiException(
          'Server terlalu lama merespons. Transaksi mungkin sudah tersimpan, '
          'periksa Riwayat sebelum mencoba lagi.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<Transaction>> fetchAll() {
    return _run('memuat transaksi', () async {
      final rows = await _client
          .from(_table)
          .select()
          .eq('student_id', AppConstants.studentId)
          .order('trx_date', ascending: false)
          .order('id', ascending: false);

      return rows.map(Transaction.fromJson).toList();
    });
  }

  @override
  Future<Transaction> create(Transaction transaction) {
    return _run(
      'menyimpan transaksi',
      () async {
        final row = await _client
            .from(_table)
            .insert(transaction.toJson())
            .select()
            .single();

        return Transaction.fromJson(row);
      },
      mayHaveApplied: true,
    );
  }

  @override
  Future<Transaction> update(Transaction transaction) {
    final id = transaction.id;
    if (id == null) {
      throw ApiException(
        'Transaksi belum tersimpan sehingga tidak dapat diubah.',
      );
    }

    return _run('memperbarui transaksi', () async {
      final rows = await _client
          .from(_table)
          .update(transaction.toJson())
          .eq('id', id)
          .eq('student_id', AppConstants.studentId)
          .select();

      // Jika id tidak ada atau policy RLS menolak, Supabase tidak melempar
      // error. Hasilnya hanya daftar kosong, jadi kita periksa sendiri.
      if (rows.isEmpty) {
        throw ApiException(
          'Transaksi tidak ditemukan atau perubahan ditolak oleh aturan akses database.',
        );
      }
      return Transaction.fromJson(rows.first);
    });
  }

  @override
  Future<void> delete(int id) {
    return _run('menghapus transaksi', () async {
      final rows = await _client
          .from(_table)
          .delete()
          .eq('id', id)
          .eq('student_id', AppConstants.studentId)
          .select();

      // Sama seperti update: jika id tidak ada atau policy RLS menolak,
      // tidak ada error, hanya nol baris yang terhapus.
      if (rows.isEmpty) {
        throw ApiException(
          'Transaksi tidak ditemukan atau penghapusan ditolak oleh aturan akses database.',
        );
      }
    });
  }
}