import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/text_styles.dart';
import '../utils/formatters.dart';
import '../utils/sample_data.dart';
import 'tag_chip.dart';

const double _dateW = 84;
const double _amountW = 140;
const double _accountW = 110;
const double _categoryW = 150;

/// Tabel buku kas untuk layar lebar.
class LedgerTable extends StatelessWidget {
  const LedgerTable({super.key, required this.items, this.onRowTap});

  final List<SampleTx> items;
  final void Function(SampleTx tx)? onRowTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final ink = Theme.of(context).colorScheme.onSurface;
    final head = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: tokens.muted,
    );
    final small = TextStyle(fontSize: 13, color: tokens.muted);

    return Column(
      children: [
        _shell(
          border: Border(bottom: BorderSide(color: ink)),
          name: Text('Nama', style: head),
          date: Text('Tanggal', style: head),
          amount: Text('Nominal', style: head),
          account: Text('Akun', style: head),
          category: Text('Kategori', style: head),
        ),
        for (final t in items)
          InkWell(
            onTap: onRowTap == null ? null : () => onRowTap!(t),
            child: _shell(
              border: Border(bottom: BorderSide(color: tokens.rule)),
              name: Text(
                t.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              date: Text(t.date, style: small),
              amount: Text(
                '${t.isIncome ? '+' : '−'}${formatNumber(t.amount)}',
                style: moneyStyle(
                  color: t.isIncome ? tokens.income : tokens.expense,
                ),
              ),
              account: Text(t.account, style: small),
              category: TagChip(label: t.category, tone: t.tone),
            ),
          ),
      ],
    );
  }

  Widget _shell({
    required Border border,
    required Widget name,
    required Widget date,
    required Widget amount,
    required Widget account,
    required Widget category,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: border),
      child: Row(
        children: [
          Expanded(child: name),
          SizedBox(width: _dateW, child: date),
          SizedBox(
            width: _amountW,
            child: Align(alignment: Alignment.centerRight, child: amount),
          ),
          SizedBox(
            width: _accountW,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: account,
            ),
          ),
          SizedBox(
            width: _categoryW,
            child: Align(alignment: Alignment.centerLeft, child: category),
          ),
        ],
      ),
    );
  }
}