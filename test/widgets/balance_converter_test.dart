import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/models/exchange_rates.dart';
import 'package:dompetku/theme/app_tokens.dart';
import 'package:dompetku/widgets/balance_converter.dart';

const _frankfurter = {
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

Widget host(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: const [AppTokens.light]),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  final rates = ExchangeRates.fromJson(_frankfurter);

  testWidgets('menampilkan saldo dan hasil konversi', (tester) async {
    await tester.pumpWidget(
      host(BalanceConverter(
        balance: 2619500,
        rates: rates,
        codes: const ['USD', 'EUR'],
      )),
    );

    expect(find.textContaining('Rp 2.619.500'), findsOneWidget);
    expect(find.text('144,34'), findsOneWidget);
    expect(find.text('129,20'), findsOneWidget);
  });

  testWidgets('kurs yang tidak tersedia ditampilkan sebagai strip',
      (tester) async {
    await tester.pumpWidget(
      host(BalanceConverter(
        balance: 1000,
        rates: rates,
        codes: const ['XYZ'],
      )),
    );

    expect(find.text('-'), findsOneWidget);
  });

  testWidgets('saldo negatif menghasilkan nilai negatif', (tester) async {
    await tester.pumpWidget(
      host(BalanceConverter(
        balance: -100000,
        rates: rates,
        codes: const ['USD'],
      )),
    );

    expect(find.text('-5,51'), findsOneWidget);
  });
}