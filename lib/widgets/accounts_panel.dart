import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/text_styles.dart';
import '../utils/formatters.dart';
import 'double_rule.dart';

/// Panel saldo per akun, ditampilkan di samping tabel pada layar sangat lebar.
class AccountsPanel extends StatelessWidget {
  const AccountsPanel({super.key, required this.balances, required this.total});

  final Map<String, int> balances;
  final int total;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Akun',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: tokens.muted,
          ),
        ),
        const SizedBox(height: 10),
        for (final entry in balances.entries)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: tokens.panel,
              border: Border.all(color: tokens.rule),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(entry.value),
                  style: moneyStyle(
                    size: 14,
                    weight: FontWeight.w500,
                    color: tokens.muted,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        const DoubleRule(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total saldo',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                formatRupiah(total),
                style: moneyStyle(size: 18, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}