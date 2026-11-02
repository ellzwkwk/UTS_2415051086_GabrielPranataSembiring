import 'package:flutter/material.dart';
import '../utils/breakpoints.dart';
import '../utils/sample_data.dart';
import '../widgets/accounts_panel.dart';
import '../widgets/ledger_table.dart';
import '../widgets/transaction_tile.dart';

const double _panelMinWidth = 1100;

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return switch (screenSizeOf(constraints.maxWidth)) {
            ScreenSize.compact => const _CompactList(),
            ScreenSize.medium => const _MediumGrid(),
            ScreenSize.expanded => const _ExpandedLedger(),
          };
        },
      ),
    );
  }
}

TransactionTile _tile(SampleTx t) => TransactionTile(
      title: t.title,
      category: t.category,
      tone: t.tone,
      meta: t.meta,
      amount: t.amount,
      isIncome: t.isIncome,
    );

class _CompactList extends StatelessWidget {
  const _CompactList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sampleTransactions.length,
      itemBuilder: (context, i) => _tile(sampleTransactions[i]),
    );
  }
}

class _MediumGrid extends StatelessWidget {
  const _MediumGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 80,
      ),
      itemCount: sampleTransactions.length,
      itemBuilder: (context, i) => _tile(sampleTransactions[i]),
    );
  }
}

class _ExpandedLedger extends StatelessWidget {
  const _ExpandedLedger();

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
                const Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: LedgerTable(items: sampleTransactions),
                  ),
                ),
                if (showPanel)
                  const SizedBox(
                    width: 280,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(0, 16, 20, 24),
                      child: AccountsPanel(),
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