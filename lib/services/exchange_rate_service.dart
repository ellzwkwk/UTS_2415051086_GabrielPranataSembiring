import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/exchange_rates.dart';
import 'api_exception.dart';

class ExchangeRateService {
  ExchangeRateService({
    http.Client? client,
    String? baseUrl,
    this.timeout = const Duration(seconds: 10),
  })  : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? defaultBaseUrl;

  static const defaultBaseUrl = 'https://api.frankfurter.dev/v1';
  static const defaultSymbols = ['IDR', 'EUR', 'SGD', 'JPY', 'GBP'];

  final http.Client _client;
  final String baseUrl;
  final Duration timeout;

  Future<ExchangeRates> fetchLatest({
    String base = 'USD',
    List<String> symbols = defaultSymbols,
  }) async {
    final uri = Uri.parse('$baseUrl/latest').replace(
      queryParameters: {'base': base, 'symbols': symbols.join(',')},
    );

    final response = await _client.get(uri).timeout(timeout);

    if (response.statusCode != 200) {
      throw ApiException(
        'Layanan kurs mengembalikan kesalahan (HTTP ${response.statusCode}).',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ExchangeRates.fromJson(json);
  }
}