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
}