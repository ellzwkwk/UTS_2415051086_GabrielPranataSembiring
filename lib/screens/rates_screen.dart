import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exchange_rate_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/currency_info.dart';
import '../utils/formatters.dart';
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

    final tokens = context.tokens;

    return RefreshIndicator(
      onRefresh: p.load,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
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
              for (final code in p.currencyCodes)
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
          ),
        ),
      ),
    );
  }
}