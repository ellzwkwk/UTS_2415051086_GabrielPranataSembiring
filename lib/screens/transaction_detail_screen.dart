import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/text_styles.dart';
import '../utils/formatters.dart';
import '../utils/sample_data.dart';
import '../widgets/ledger_row.dart';
import '../widgets/tag_chip.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.tx});

  final SampleTx tx;

  static Future<void> open(BuildContext context, SampleTx tx) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => TransactionDetailScreen(tx: tx)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = tx.isIncome ? tokens.income : tokens.expense;
    final sign = tx.isIncome ? '+' : '−';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail transaksi')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$sign${formatRupiah(tx.amount)}',
                      style: moneyStyle(
                        size: 30,
                        weight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              LedgerRow(
                label: 'Jenis',
                value: tx.isIncome ? 'Pemasukan' : 'Pengeluaran',
              ),
              LedgerRow(
                label: 'Kategori',
                valueWidget: TagChip(label: tx.category, tone: tx.tone),
              ),
              LedgerRow(label: 'Akun', value: tx.account),
              LedgerRow(label: 'Tanggal', value: tx.date),
              LedgerRow(
                label: 'Catatan',
                value: tx.note.isEmpty ? '-' : tx.note,
              ),
            ],
          ),
        ),
      ),
    );
  }
}