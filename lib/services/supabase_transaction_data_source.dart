import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, Supabase, SupabaseClient;
import '../config/app_constants.dart';
import '../models/transaction.dart';
import 'api_exception.dart';
import 'transaction_data_source.dart';

class SupabaseTransactionDataSource implements TransactionDataSource {
  SupabaseTransactionDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _table = 'transactions';

  /// 23514 = check constraint dilanggar (nominal, jenis, atau akun tidak valid).
  ApiException _toApi(PostgrestException e, String action) {
    if (e.code == '23514') {
      return ApiException(
        'Data ditolak database karena tidak memenuhi aturan tabel.',
      );
    }
    return ApiException('Gagal $action: ${e.message}');
  }

  @override
  Future<List<Transaction>> fetchAll() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('student_id', AppConstants.studentId)
          .order('trx_date', ascending: false)
          .order('id', ascending: false);

      return rows.map(Transaction.fromJson).toList();
    } on PostgrestException catch (e) {
      throw ApiException('Gagal memuat transaksi dari database: ${e.message}');
    }
  }

  @override
  Future<Transaction> create(Transaction transaction) async {
    try {
      final row = await _client
          .from(_table)
          .insert(transaction.toJson())
          .select()
          .single();

      return Transaction.fromJson(row);
    } on PostgrestException catch (e) {
      throw _toApi(e, 'menyimpan transaksi');
    }
  }

  @override
  Future<Transaction> update(Transaction transaction) async {
    final id = transaction.id;
    if (id == null) {
      throw ApiException('Transaksi belum tersimpan sehingga tidak dapat diubah.');
    }

    try {
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
    } on PostgrestException catch (e) {
      throw _toApi(e, 'memperbarui transaksi');
    }
  }
}