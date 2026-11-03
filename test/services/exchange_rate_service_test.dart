import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:dompetku/services/api_exception.dart';
import 'package:dompetku/services/exchange_rate_service.dart';

const _body =
    '{"amount":1.0,"base":"USD","date":"2026-10-30","rates":{"EUR":0.89509,'
    '"GBP":0.74633,"IDR":18148,"JPY":157.25,"SGD":1.2784}}';

ExchangeRateService serviceWith(Future<http.Response> Function() respond) {
  return ExchangeRateService(client: MockClient((_) => respond()));
}

void main() {
  test('mengirim permintaan ke endpoint yang benar', () async {
    late Uri captured;
    final service = ExchangeRateService(
      client: MockClient((request) async {
        captured = request.url;
        return http.Response(_body, 200);
      }),
    );

    await service.fetchLatest();

    expect(captured.path, '/v1/latest');
    expect(captured.queryParameters, {
      'base': 'USD',
      'symbols': 'IDR,EUR,SGD,JPY,GBP',
    });
  });

  test('respons 200 diubah menjadi model', () async {
    final rates = await serviceWith(() async => http.Response(_body, 200))
        .fetchLatest();

    expect(rates.base, 'USD');
    expect(rates.date, DateTime(2026, 10, 30));
    expect(rates.rates['IDR'], 18148.0);
    expect(rates.rates.length, 5);
  });

  test('status bukan 200 melempar ApiException', () async {
    final service = serviceWith(() async => http.Response('tidak ada', 404));

    expect(
      service.fetchLatest(),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', contains('HTTP 404')),
      ),
    );
  });

  test('body bukan JSON melempar FormatException', () async {
    final service = serviceWith(() async => http.Response('bukan json', 200));
    expect(service.fetchLatest(), throwsFormatException);
  });

  test('JSON tanpa rates melempar TypeError', () async {
    final service = serviceWith(
      () async => http.Response('{"base":"USD","date":"2026-10-30"}', 200),
    );
    expect(service.fetchLatest(), throwsA(isA<TypeError>()));
  });
}