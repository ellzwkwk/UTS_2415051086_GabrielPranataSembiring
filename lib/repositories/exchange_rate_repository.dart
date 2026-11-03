import '../models/exchange_rates.dart';
import '../services/exchange_rate_service.dart';

class ExchangeRateRepository {
  ExchangeRateRepository(this._service);

  final ExchangeRateService _service;

  Future<ExchangeRates> getLatest() => _service.fetchLatest();
}