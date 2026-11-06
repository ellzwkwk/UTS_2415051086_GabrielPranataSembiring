import 'package:flutter/material.dart';
import '../models/exchange_rates.dart';
import '../theme/app_tokens.dart';
import '../theme/text_styles.dart';
import '../utils/currency_info.dart';
import '../utils/formatters.dart';

/// Menampilkan saldo rupiah dalam beberapa mata uang asing.
class BalanceConverter extends StatelessWidget {
  const BalanceConverter({
    super.key,
    required this.balance,
    required this.rates,
    required this.codes,
  });

  /// Total saldo dalam rupiah.
  final int balance;
  final ExchangeRates rates;
  final List<String> codes;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          child: Text(
            'Saldo dalam mata uang asing',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            'Total saldo ${formatRupiah(balance)}, dihitung dengan kurs '
            '${formatLongDate(rates.date)}.',
            style: TextStyle(fontSize: 13, color: tokens.muted),
          ),
        ),
        for (final code in codes)
          _ConvertedRow(code: code, value: rates.convertFromIdr(balance, code)),
      ],
    );
  }
}

class _ConvertedRow extends StatelessWidget {
  const _ConvertedRow({required this.code, required this.value});

  final String code;

  /// Null jika kurs mata uang ini tidak tersedia.
  final double? value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.rule)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  currencyName(code),
                  style: TextStyle(fontSize: 13, color: tokens.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value == null ? '-' : formatForeignAmount(value!, code),
            style: moneyStyle(),
          ),
        ],
      ),
    );
  }
}