import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/models/exchange_rates.dart';

void main() {
  const frankfurter = {
    'amount': 1.0,
    'base': 'USD',
    'date': '2026-10-30',
    'rates': {
      'EUR': 0.89509,
      'GBP': 0.74633,
      'IDR': 18148,
      'JPY': 157.25,
      'SGD': 1.2784,
    },
  };

  group('ExchangeRates.fromJson', () {
    test('mengubah respons API menjadi objek', () {
      final rates = ExchangeRates.fromJson(frankfurter);

      expect(rates.base, 'USD');
      expect(rates.date, DateTime(2026, 10, 30));
      expect(rates.rates.length, 5);
      expect(rates.rates['EUR'], 0.89509);
    });

    test('IDR bilangan bulat tetap menjadi double', () {
      final rates = ExchangeRates.fromJson(frankfurter);

      expect(rates.rates['IDR'], isA<double>());
      expect(rates.rates['IDR'], 18148.0);
    });

    test('rates yang hilang melempar TypeError', () {
      expect(
        () => ExchangeRates.fromJson({'base': 'USD', 'date': '2026-10-30'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('ExchangeRates.toJson', () {
    test('fromJson lalu toJson menghasilkan data yang sama', () {
      final first = ExchangeRates.fromJson(frankfurter).toJson();
      final second = ExchangeRates.fromJson(first).toJson();
      expect(second, first);
    });
  });

  group('konversi rupiah', () {
    final rates = ExchangeRates.fromJson(frankfurter);

    test('idrPerUnit: 1 USD sama dengan kurs IDR', () {
      expect(rates.idrPerUnit('USD'), 18148.0);
    });

    test('idrPerUnit: mata uang lain lewat USD', () {
      expect(rates.idrPerUnit('EUR'), closeTo(20275.06, 0.1));
      expect(rates.idrPerUnit('JPY'), closeTo(115.41, 0.01));
    });

    test('saldo 2.619.500 rupiah sekitar 144,34 USD', () {
      expect(rates.convertFromIdr(2619500, 'USD'), closeTo(144.34, 0.01));
    });

    test('saldo yang sama dalam EUR', () {
      expect(rates.convertFromIdr(2619500, 'EUR'), closeTo(129.20, 0.05));
    });

    test('mata uang tidak dikenal menghasilkan null', () {
      expect(rates.convertFromIdr(1000, 'XYZ'), isNull);
    });

    test('tanpa kurs IDR menghasilkan null', () {
      final noIdr = ExchangeRates(
        base: 'USD',
        date: DateTime(2026, 10, 30),
        rates: {'EUR': 0.9},
      );
      expect(noIdr.convertFromIdr(1000, 'EUR'), isNull);
    });

    test('basis IDR juga didukung', () {
      final idrBase = ExchangeRates(
        base: 'IDR',
        date: DateTime(2026, 10, 30),
        rates: {'USD': 0.000055},
      );
      expect(idrBase.convertFromIdr(1000000, 'USD'), closeTo(55, 0.001));
    });
  });
}