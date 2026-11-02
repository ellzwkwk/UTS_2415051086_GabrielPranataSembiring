import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../theme/app_tokens.dart';
import '../theme/text_styles.dart';
import '../utils/formatters.dart';
import '../widgets/double_rule.dart';
import '../widgets/ledger_row.dart';
import '../widgets/transaction_tile.dart';

class _Tx {
  const _Tx(this.title, this.category, this.tone, this.meta, this.amount, this.isIncome);

  final String title;
  final String category;
  final TagTone tone;
  final String meta;
  final int amount;
  final bool isIncome;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Data contoh sementara (milestone 3). Diganti data database di milestone 9.
  static const _recent = [
    _Tx('Honor asisten lab', 'Honor', TagTone.green, '2 Nov, E-wallet', 450000, true),
    _Tx('Fotokopi modul', 'Kuliah', TagTone.blue, '2 Nov, Tunai', 12500, false),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppConstants.studentId} - ${AppConstants.studentName}',
                    style: theme.textTheme.bodySmall?.copyWith(color: tokens.muted),
                  ),
                ],
              ),
            ),
            LedgerRow(label: 'Saldo awal bulan', value: formatNumber(1000000)),
            LedgerRow(
              label: 'Masuk bulan ini',
              value: '+${formatNumber(2450000)}',
              valueColor: tokens.income,
            ),
            LedgerRow(
              label: 'Keluar bulan ini',
              value: '−${formatNumber(830500)}',
              valueColor: tokens.expense,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: DoubleRule(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total saldo',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    formatRupiah(2619500),
                    style: moneyStyle(size: 26, weight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('+ Pemasukan'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('− Pengeluaran'),
                    ),
                  ),
                ],
              ),
            ),
            const _SectionTitle('Akun'),
            LedgerRow(label: 'Tunai', value: formatNumber(319500)),
            LedgerRow(label: 'Bank', value: formatNumber(1900000)),
            LedgerRow(label: 'E-wallet', value: formatNumber(400000)),
            const _SectionTitle('Terbaru'),
            for (final t in _recent)
              TransactionTile(
                title: t.title,
                category: t.category,
                tone: t.tone,
                meta: t.meta,
                amount: t.amount,
                isIncome: t.isIncome,
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}