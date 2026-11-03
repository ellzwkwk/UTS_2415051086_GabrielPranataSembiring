import 'package:flutter/foundation.dart';
import '../models/exchange_rates.dart';
import '../repositories/exchange_rate_repository.dart';
import '../utils/error_message.dart';

class ExchangeRateProvider extends ChangeNotifier {
  ExchangeRateProvider(this._repository);

  final ExchangeRateRepository _repository;

  ExchangeRates? _rates;
  bool _isLoading = false;
  String? _error;

  ExchangeRates? get rates => _rates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Data sudah ada tetapi tidak berisi satu pun kurs.
  bool get isEmpty => _rates != null && _rates!.rates.isEmpty;

  /// Mata uang asing yang ditampilkan: mata uang dasar, lalu sisanya.
  List<String> get currencyCodes {
    final r = _rates;
    if (r == null) return const [];
    return [
      r.base,
      ...r.rates.keys.where((c) => c != 'IDR' && c != r.base),
    ];
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rates = await _repository.getLatest();
    } catch (e) {
      _rates = null;
      _error = friendlyError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}