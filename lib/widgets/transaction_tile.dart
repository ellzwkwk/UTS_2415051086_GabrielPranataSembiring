import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_tokens.dart';
import '../theme/text_styles.dart';
import '../utils/category_style.dart';
import '../utils/formatters.dart';
import 'tag_chip.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction, this.onTap});

  final Transaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final t = transaction;
    final color = t.isIncome ? tokens.income : tokens.expense;
    final sign = t.isIncome ? '+' : '−';
    final tone = toneForCategory(t.category, isIncome: t.isIncome);

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: tokens.rule)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TagChip(label: t.category, tone: tone),
                      Text(
                        '${formatShortDate(t.date)}, ${t.account}',
                        style: TextStyle(fontSize: 13, color: tokens.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('$sign${formatNumber(t.amount)}', style: moneyStyle(color: color)),
          ],
        ),
      ),
    );
  }
}