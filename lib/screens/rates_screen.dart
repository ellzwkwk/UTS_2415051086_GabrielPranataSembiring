import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exchange_rates.dart';
import '../providers/exchange_rate_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/breakpoints.dart';
import '../utils/currency_info.dart';
import '../utils/formatters.dart';
import '../widgets/balance_converter.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/rate_tile.dart';

class RatesScreen extends StatelessWidget {
  const RatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExchangeRateProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurs'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: p.isLoading ? null : p.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: p.isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: _body(context, p),
    );
  }

  Widget _body(BuildContext context, ExchangeRateProvider p) {
    if (p.isLoading && p.rates == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.error != null) {
      return ErrorView(message: p.error!, onRetry: p.load);
    }

    final rates = p.rates;
    if (rates == null || p.isEmpty) {
      return const EmptyView(message: 'Data kurs belum tersedia.');
    }

    final transactions = context.watch<TransactionProvider>();
    final codes = p.currencyCodes;

    return RefreshIndicator(
      onRefresh: p.load,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide =
              screenSizeOf(constraints.maxWidth) == ScreenSize.expanded;
          final list = _RatesList(rates: rates, codes: codes);
          final converter = _ConverterSection(
            transactions: transactions,
            rates: rates,
            codes: codes,
          );

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: wide ? 1000 : 640),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: list),
                          SizedBox(width: 360, child: converter),
                        ],
                      )
                    : Column(children: [list, converter]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RatesList extends StatelessWidget {
  const _RatesList({required this.rates, required this.codes});

  final ExchangeRates rates;
  final List<String> codes;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kurs terhadap Rupiah',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Per ${formatLongDate(rates.date)}',
                style: TextStyle(color: tokens.muted),
              ),
            ],
          ),
        ),
        for (final code in codes)
          RateTile(
            code: code,
            name: currencyName(code),
            idrPerUnit: rates.idrPerUnit(code),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text(
            'Sumber: Frankfurter (kurs referensi Bank Sentral Eropa), '
            'diperbarui setiap hari kerja.',
            style: TextStyle(fontSize: 13, color: tokens.muted),
          ),
        ),
      ],
    );
  }
}

class _ConverterSection extends StatelessWidget {
  const _ConverterSection({
    required this.transactions,
    required this.rates,
    required this.codes,
  });

  final TransactionProvider transactions;
  final ExchangeRates rates;
  final List<String> codes;

  @override
  Widget build(BuildContext context) {
    if (transactions.isLoading) {
      return const _Note('Memuat saldo...');
    }
    if (transactions.error != null || !transactions.hasData) {
      return const _Note(
        'Saldo belum tersedia, jadi konversi belum dapat ditampilkan.',
      );
    }

    return BalanceConverter(
      balance: transactions.totalBalance,
      rates: rates,
      codes: codes,
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: context.tokens.muted),
      ),
    );
  }
}