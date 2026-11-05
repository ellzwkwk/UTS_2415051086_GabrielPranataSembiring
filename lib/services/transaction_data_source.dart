import '../models/transaction.dart';

/// Kontrak sumber data transaksi. Provider dan repository tidak peduli
/// apakah isinya data contoh, REST API, atau Supabase.
abstract class TransactionDataSource {
  Future<List<Transaction>> fetchAll();

  /// Menyimpan transaksi baru dan mengembalikan baris yang tersimpan
  /// (lengkap dengan id yang dibuat server).
  Future<Transaction> create(Transaction transaction);

  /// Mengubah transaksi yang sudah ada (dicari berdasarkan id) dan
  /// mengembalikan baris hasil perubahan.
  Future<Transaction> update(Transaction transaction);

  /// Menghapus transaksi berdasarkan id. Melempar exception jika tidak ada
  /// baris yang terhapus.
  Future<void> delete(int id);
}