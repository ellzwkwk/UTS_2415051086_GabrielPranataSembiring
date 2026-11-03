import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:dompetku/providers/exchange_rate_provider.dart';
import 'package:dompetku/repositories/exchange_rate_repository.dart';
import 'package:dompetku/services/exchange_rate_service.dart';

const _body =
    '{"amount":1.0,"base":"USD","date":"2026-10-30","rates":{"EUR":0.89509,'
    '"GBP":0.74633,"IDR":18148,"JPY":157.25,"SGD":1.2784}}';

ExchangeRateProvider makeProvider(MockClient client) {
  return ExchangeRateProvider(
    ExchangeRateRepository(ExchangeRateService(client: client)),
  );
}

void main() {
  test('awalnya kosong dan tidak loading', () {
    final p = makeProvider(MockClient((_) async => http.Response(_body, 200)));

    expect(p.rates, isNull);
    expect(p.isLoading, isFalse);
    expect(p.error, isNull);
    expect(p.isEmpty, isFalse);
  });

  test('load berhasil: isLoading true lalu false dan data terisi', () async {
    final p = makeProvider(MockClient((_) async => http.Response(_body, 200)));
    final states = <bool>[];
    p.addListener(() => states.add(p.isLoading));

    await p.load();

    expect(states, [true, false]);
    expect(p.rates?.base, 'USD');
    expect(p.error, isNull);
    expect(p.currencyCodes, ['USD', 'EUR', 'GBP', 'JPY', 'SGD']);
  });

  test('server error mengisi pesan error', () async {
    final p = makeProvider(MockClient((_) async => http.Response('x', 500)));

    await p.load();

    expect(p.error, contains('HTTP 500'));
    expect(p.rates, isNull);
    expect(p.isLoading, isFalse);
  });

  test('jaringan putus menghasilkan pesan yang ramah', () async {
    final p = makeProvider(
      MockClient((_) async => throw http.ClientException('Failed host lookup')),
    );

    await p.load();

    expect(p.error, startsWith('Tidak ada koneksi internet'));
  });

  test('data tanpa satu pun kurs dianggap kosong', () async {
    final p = makeProvider(
      MockClient(
        (_) async => http.Response(
          '{"amount":1.0,"base":"USD","date":"2026-10-30","rates":{}}',
          200,
        ),
      ),
    );

    await p.load();

    expect(p.isEmpty, isTrue);
    expect(p.error, isNull);
  });

  test('coba lagi setelah gagal menghapus error', () async {
    var calls = 0;
    final p = makeProvider(
      MockClient((_) async {
        calls++;
        return calls == 1 ? http.Response('x', 500) : http.Response(_body, 200);
      }),
    );

    await p.load();
    expect(p.error, isNotNull);

    await p.load();
    expect(p.error, isNull);
    expect(p.rates, isNotNull);
  });
}