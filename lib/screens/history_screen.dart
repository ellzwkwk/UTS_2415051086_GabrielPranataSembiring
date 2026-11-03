import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../utils/breakpoints.dart';
import '../widgets/accounts_panel.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/ledger_table.dart';
import '../widgets/option_chip.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_detail_screen.dart';

const double _panelMinWidth = 1100;

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: _body(provider),
    );
  }

  Widget _body(TransactionProvider p) {
    if (p.isLoading) return const Center(child: CircularProgressIndicator());
    if (p.error != null) {
      return ErrorView(message: p.error!, onRetry: p.load);
    }
    if (!p.hasData) return const EmptyView(message: 'Belum ada transaksi.');

    final items = p.visibleItems;

    return Column(
      children: [
        _FilterBar(current: p.filter.type, onChanged: p.setType),
        Expanded(
          child: items.isEmpty
              ? const EmptyView(
                  message: 'Tidak ada transaksi yang cocok dengan filter.',
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return switch (screenSizeOf(constraints.maxWidth)) {
                      ScreenSize.compact => _CompactList(items: items),
                      ScreenSize.medium => _MediumGrid(items: items),
                      ScreenSize.expanded => _ExpandedLedger(
                          items: items,
                          balances: p.balanceByAccount,
                          total: p.totalBalance,
                        ),
                    };
                  },
                ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.current, required this.onChanged});

  final TransactionType? current;
  final ValueChanged<TransactionType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          OptionChip(
            label: 'Semua',
            selected: current == null,
            onTap: () => onChanged(null),
          ),
          OptionChip(
            label: 'Masuk',
            selected: current == TransactionType.income,
            onTap: () => onChanged(TransactionType.income),
          ),
          OptionChip(
            label: 'Keluar',
            selected: current == TransactionType.expense,
            onTap: () => onChanged(TransactionType.expense),
          ),
        ],
      ),
    );
  }
}

TransactionTile _tile(BuildContext context, Transaction t) => TransactionTile(
      transaction: t,
      onTap: () => TransactionDetailScreen.open(context, t),
    );

class _CompactList extends StatelessWidget {
  const _CompactList({required this.items});

  final List<Transaction> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) => _tile(context, items[i]),
    );
  }
}

class _MediumGrid extends StatelessWidget {
  const _MediumGrid({required this.items});

  final List<Transaction> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 80,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _tile(context, items[i]),
    );
  }
}

class _ExpandedLedger extends StatelessWidget {
  const _ExpandedLedger({
    required this.items,
    required this.balances,
    required this.total,
  });

  final List<Transaction> items;
  final Map<String, int> balances;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showPanel = constraints.maxWidth >= _panelMinWidth;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: LedgerTable(
                      items: items,
                      onRowTap: (t) => TransactionDetailScreen.open(context, t),
                    ),
                  ),
                ),
                if (showPanel)
                  SizedBox(
                    width: 280,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(0, 16, 20, 24),
                      child: AccountsPanel(balances: balances, total: total),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}