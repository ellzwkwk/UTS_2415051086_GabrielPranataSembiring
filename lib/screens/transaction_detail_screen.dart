import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_tokens.dart';
import '../theme/text_styles.dart';
import '../utils/category_style.dart';
import '../utils/formatters.dart';
import '../widgets/ledger_row.dart';
import '../widgets/tag_chip.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.transaction});

  final Transaction transaction;

  static Future<void> open(BuildContext context, Transaction transaction) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transaction: transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final t = transaction;
    final color = t.isIncome ? tokens.income : tokens.expense;
    final sign = t.isIncome ? '+' : '−';

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
                      t.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$sign${formatRupiah(t.amount)}',
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
                value: t.isIncome ? 'Pemasukan' : 'Pengeluaran',
              ),
              LedgerRow(
                label: 'Kategori',
                valueWidget: TagChip(
                  label: t.category,
                  tone: toneForCategory(t.category, isIncome: t.isIncome),
                ),
              ),
              LedgerRow(label: 'Akun', value: t.account),
              LedgerRow(label: 'Tanggal', value: formatLongDate(t.date)),
              LedgerRow(
                label: 'Catatan',
                value: t.note.isEmpty ? '-' : t.note,
              ),
            ],
          ),
        ),
      ),
    );
  }
}