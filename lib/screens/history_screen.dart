import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/breakpoints.dart';
import '../utils/refresh_transactions.dart';
import '../widgets/accounts_panel.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/ledger_table.dart';
import '../widgets/option_chip.dart';
import '../widgets/search_field.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_detail_screen.dart';
import 'transaction_form_screen.dart';

const double _panelMinWidth = 1100;
const double _fabSpace = 88;

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: (p.isLoading || p.isRefreshing)
                ? null
                : () => refreshTransactions(context),
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: p.isRefreshing
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: _body(context, p),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => TransactionFormScreen.open(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _body(BuildContext context, TransactionProvider p) {
    if (p.isLoading) return const Center(child: CircularProgressIndicator());
    if (p.error != null) {
      return ErrorView(message: p.error!, onRetry: p.load);
    }
    if (!p.hasData) return const EmptyView(message: 'Belum ada transaksi.');

    final items = p.visibleItems;
    Future<void> onRefresh() => refreshTransactions(context);

    return Column(
      children: [
        _FilterBar(provider: p, shown: items.length),
        Expanded(
          child: items.isEmpty
              ? EmptyView(
                  message: 'Tidak ada transaksi yang cocok dengan filter.',
                  actionLabel: 'Hapus filter',
                  onAction: p.clearFilters,
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return switch (screenSizeOf(constraints.maxWidth)) {
                      ScreenSize.compact =>
                        _CompactList(items: items, onRefresh: onRefresh),
                      ScreenSize.medium =>
                        _MediumGrid(items: items, onRefresh: onRefresh),
                      ScreenSize.expanded => _ExpandedLedger(
                          items: items,
                          balances: p.balanceByAccount,
                          total: p.totalBalance,
                          onRefresh: onRefresh,
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
  const _FilterBar({required this.provider, required this.shown});

  final TransactionProvider provider;
  final int shown;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final f = provider.filter;
    final total = provider.items.length;

    Widget chip(String label, bool selected, VoidCallback onTap) {
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: OptionChip(label: label, selected: selected, onTap: onTap),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: SearchField(
            query: f.query,
            onChanged: provider.setQuery,
            hint: 'Cari judul, kategori, akun, atau catatan',
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 8, 10, 8),
          child: Row(
            children: [
              chip(
                'Semua jenis',
                f.type == null,
                () => provider.setType(null),
              ),
              chip(
                'Masuk',
                f.type == TransactionType.income,
                () => provider.setType(TransactionType.income),
              ),
              chip(
                'Keluar',
                f.type == TransactionType.expense,
                () => provider.setType(TransactionType.expense),
              ),
              Container(
                width: 1,
                height: 24,
                margin: const EdgeInsets.only(right: 10),
                color: tokens.rule,
              ),
              chip(
                'Semua waktu',
                f.period == TransactionPeriod.all,
                () => provider.setPeriod(TransactionPeriod.all),
              ),
              chip(
                'Bulan ini',
                f.period == TransactionPeriod.thisMonth,
                () => provider.setPeriod(TransactionPeriod.thisMonth),
              ),
              chip(
                'Bulan lalu',
                f.period == TransactionPeriod.lastMonth,
                () => provider.setPeriod(TransactionPeriod.lastMonth),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      'Menampilkan $shown dari $total transaksi',
                      style: TextStyle(fontSize: 13, color: tokens.muted),
                    ),
                  ),
                ),
                if (f.isActive)
                  TextButton(
                    onPressed: provider.clearFilters,
                    child: const Text('Reset filter'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

TransactionTile _tile(BuildContext context, Transaction t) => TransactionTile(
      transaction: t,
      onTap: () => TransactionDetailScreen.open(context, t),
    );

class _CompactList extends StatelessWidget {
  const _CompactList({required this.items, required this.onRefresh});

  final List<Transaction> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: _fabSpace),
        itemCount: items.length,
        itemBuilder: (context, i) => _tile(context, items[i]),
      ),
    );
  }
}

class _MediumGrid extends StatelessWidget {
  const _MediumGrid({required this.items, required this.onRefresh});

  final List<Transaction> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(top: 8, bottom: _fabSpace),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 80,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) => _tile(context, items[i]),
      ),
    );
  }
}

class _ExpandedLedger extends StatelessWidget {
  const _ExpandedLedger({
    required this.items,
    required this.balances,
    required this.total,
    required this.onRefresh,
  });

  final List<Transaction> items;
  final Map<String, int> balances;
  final int total;
  final Future<void> Function() onRefresh;

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
                  child: RefreshIndicator(
                    onRefresh: onRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, _fabSpace),
                      child: LedgerTable(
                        items: items,
                        onRowTap: (t) =>
                            TransactionDetailScreen.open(context, t),
                      ),
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