import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_tokens.dart';
import '../theme/text_styles.dart';
import '../utils/formatters.dart';
import '../widgets/double_rule.dart';
import '../widgets/error_view.dart';
import '../widgets/ledger_row.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_detail_screen.dart';
import '../models/transaction.dart';
import 'transaction_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSeeAll});

  /// Dipanggil saat "Lihat semua" ditekan (pindah ke tab Riwayat).
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final p = context.watch<TransactionProvider>();

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
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
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: tokens.muted),
                      ),
                    ],
                  ),
                ),
                if (p.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (p.error != null)
                  ErrorView(message: p.error!, onRetry: p.load)
                else
                  ..._content(context, p),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, TransactionProvider p) {
    final tokens = context.tokens;
    final latest = p.latest(2);

    return [
      LedgerRow(
        label: 'Saldo awal bulan',
        value: formatNumber(p.openingBalance),
      ),
      LedgerRow(
        label: 'Masuk bulan ini',
        value: '+${formatNumber(p.incomeThisMonth)}',
        valueColor: tokens.income,
      ),
      LedgerRow(
        label: 'Keluar bulan ini',
        value: '−${formatNumber(p.expenseThisMonth)}',
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
              formatRupiah(p.totalBalance),
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
            Expanded(
              child: OutlinedButton(
                onPressed: () => TransactionFormScreen.open(
                  context,
                  type: TransactionType.income,
                ),
                child: const Text('+ Pemasukan'),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                onPressed: () => TransactionFormScreen.open(
                  context,
                  type: TransactionType.expense,
                ),
                child: const Text('− Pengeluaran'),
              ),
            ),
      const _SectionTitle('Akun'),
      for (final entry in p.balanceByAccount.entries)
        LedgerRow(label: entry.key, value: formatNumber(entry.value)),
      _SectionTitle(
        'Terbaru',
        actionLabel: 'Lihat semua',
        onAction: onSeeAll,
      ),
      if (latest.isEmpty)
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text('Belum ada transaksi.'),
        ),
      for (final t in latest)
        TransactionTile(
          transaction: t,
          onTap: () => TransactionDetailScreen.open(context, t),
        ),
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}