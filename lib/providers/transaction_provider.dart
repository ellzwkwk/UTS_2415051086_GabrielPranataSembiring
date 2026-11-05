import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../repositories/transaction_repository.dart';
import '../utils/category_style.dart';
import '../utils/error_message.dart';
import '../services/api_exception.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final TransactionRepository _repository;

  /// Diganti di tes agar "bulan ini" tidak bergantung pada tanggal sungguhan.
  final DateTime Function() _clock;

  List<Transaction> _items = const [];
  bool _isLoading = false;
  String? _error;
  TransactionFilter _filter = const TransactionFilter();

  // ---- state ----

  List<Transaction> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _items.isNotEmpty;
  TransactionFilter get filter => _filter;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.getTransactions();
    } catch (e) {
      _error = friendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
    /// Menyimpan transaksi baru. Jika gagal, melempar [ApiException] dengan
  /// pesan yang sudah ramah, supaya form dapat menampilkannya di SnackBar.
  Future<Transaction> add(Transaction transaction) async {
    try {
      final created = await _repository.createTransaction(transaction);
      _items = [..._items, created];
      notifyListeners();
      return created;
    } catch (e) {
      throw ApiException(friendlyError(e));
    }
  }

    /// Mengubah transaksi yang sudah ada. Jika gagal, melempar [ApiException]
  /// dan daftar tidak berubah.
  Future<Transaction> update(Transaction transaction) async {
    try {
      final saved = await _repository.updateTransaction(transaction);
      _items = [for (final t in _items) t.id == saved.id ? saved : t];
      notifyListeners();
      return saved;
    } catch (e) {
      throw ApiException(friendlyError(e));
    }
  }

  /// Versi terbaru sebuah transaksi, atau null jika tidak ditemukan.
  Transaction? findById(int? id) {
    if (id == null) return null;
    for (final t in _items) {
      if (t.id == id) return t;
    }
    return null;
  }

  // ---- filter ----

  void setType(TransactionType? type) {
    _filter = _filter.copyWith(type: type, clearType: type == null);
    notifyListeners();
  }

  void setQuery(String query) {
    _filter = _filter.copyWith(query: query);
    notifyListeners();
  }

  void setPeriod(TransactionPeriod period) {
    _filter = _filter.copyWith(period: period);
    notifyListeners();
  }

  void clearFilters() {
    _filter = const TransactionFilter();
    notifyListeners();
  }

  // ---- daftar ----

  /// Terbaru di atas. Tanggal sama diurutkan dari id terbesar.
  List<Transaction> get sortedItems {
    final list = [..._items];
    list.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) return byDate;
      return (b.id ?? 0).compareTo(a.id ?? 0);
    });
    return list;
  }

  List<Transaction> get visibleItems {
    final now = _clock();
    final q = _filter.query.trim().toLowerCase();

    return sortedItems.where((t) {
      if (_filter.type != null && t.type != _filter.type) return false;
      if (!_inPeriod(t.date, now)) return false;
      if (q.isNotEmpty) {
        final haystack =
            '${t.title} ${t.category} ${t.account} ${t.note}'.toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  List<Transaction> latest(int count) => sortedItems.take(count).toList();

  bool _inPeriod(DateTime date, DateTime now) {
    switch (_filter.period) {
      case TransactionPeriod.all:
        return true;
      case TransactionPeriod.thisMonth:
        return date.year == now.year && date.month == now.month;
      case TransactionPeriod.lastMonth:
        final last = DateTime(now.year, now.month - 1, 1);
        return date.year == last.year && date.month == last.month;
    }
  }

  // ---- ringkasan (dihitung dari transaksi, tidak disimpan terpisah) ----

  int _signed(Transaction t) => t.isIncome ? t.amount : -t.amount;

  DateTime get _monthStart {
    final now = _clock();
    return DateTime(now.year, now.month, 1);
  }

  int get totalBalance => _items.fold(0, (sum, t) => sum + _signed(t));

  /// Saldo sebelum tanggal 1 bulan ini.
  int get openingBalance => _items
      .where((t) => t.date.isBefore(_monthStart))
      .fold(0, (sum, t) => sum + _signed(t));

  int get incomeThisMonth => _sumThisMonth(income: true);
  int get expenseThisMonth => _sumThisMonth(income: false);

  int _sumThisMonth({required bool income}) {
    final start = _monthStart;
    final end = DateTime(start.year, start.month + 1, 1);
    return _items
        .where((t) =>
            t.isIncome == income &&
            !t.date.isBefore(start) &&
            t.date.isBefore(end))
        .fold(0, (sum, t) => sum + t.amount);
  }

  Map<String, int> get balanceByAccount {
    final balances = <String, int>{for (final a in kAccounts) a: 0};
    for (final t in _items) {
      balances[t.account] = (balances[t.account] ?? 0) + _signed(t);
    }
    return balances;
  }
}