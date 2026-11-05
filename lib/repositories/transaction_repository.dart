import '../models/transaction.dart';
import '../services/transaction_data_source.dart';

class TransactionRepository {
  TransactionRepository(this._dataSource);

  final TransactionDataSource _dataSource;

  Future<List<Transaction>> getTransactions() => _dataSource.fetchAll();

  Future<Transaction> createTransaction(Transaction transaction) =>
      _dataSource.create(transaction);
}