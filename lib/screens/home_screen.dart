import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_tokens.dart';
import '../theme/text_styles.dart';
import '../utils/breakpoints.dart';
import '../utils/formatters.dart';
import '../utils/refresh_transactions.dart';
import '../widgets/double_rule.dart';
import '../widgets/error_view.dart';
import '../widgets/ledger_row.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_detail_screen.dart';
import 'transaction_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onSeeAll});

  /// Dipanggil saat "Lihat semua" ditekan (pindah ke tab Riwayat).
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransactionProvider>();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide =
                screenSizeOf(constraints.maxWidth) == ScreenSize.expanded;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: wide ? 1100 : 640),
                child: RefreshIndicator(
                  onRefresh: () => refreshTransactions(context),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      const _Header(),
                      if (p.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (p.error != null)
                        ErrorView(message: p.error!, onRetry: p.load)
                      else if (wide)
                        _WideBody(provider: p, onSeeAll: onSeeAll)
                      else ...[
                        ..._summarySection(context, p),
                        ..._accountsSection(context, p),
                        ..._latestSection(context, p, 2, onSeeAll),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
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
            style: theme.textTheme.bodySmall?.copyWith(color: context.tokens.muted),
          ),
        ],
      ),
    );
  }
}

/// Layar lebar: ringkasan di kiri, akun dan transaksi terbaru di kanan.
class _WideBody extends StatelessWidget {
  const _WideBody({required this.provider, required this.onSeeAll});

  final TransactionProvider provider;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _summarySection(context, provider),
          ),
        ),
        Expanded(
          flex: 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: tokens.rule)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._accountsSection(context, provider),
                ..._latestSection(context, provider, 5, onSeeAll),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

List<Widget> _summarySection(BuildContext context, TransactionProvider p) {
  final tokens = context.tokens;

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
              onPressed: () => TransactionFormScreen.open(
                context,
                type: TransactionType.income,
              ),
              child: const Text('+ Pemasukan'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => TransactionFormScreen.open(
                context,
                type: TransactionType.expense,
              ),
              child: const Text('− Pengeluaran'),
            ),
          ),
        ],
      ),
    ),
  ];
}

List<Widget> _accountsSection(BuildContext context, TransactionProvider p) {
  return [
    const _SectionTitle('Akun'),
    for (final entry in p.balanceByAccount.entries)
      LedgerRow(label: entry.key, value: formatNumber(entry.value)),
  ];
}

List<Widget> _latestSection(
  BuildContext context,
  TransactionProvider p,
  int count,
  VoidCallback? onSeeAll,
) {
  final latest = p.latest(count);

  return [
    _SectionTitle('Terbaru', actionLabel: 'Lihat semua', onAction: onSeeAll),
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