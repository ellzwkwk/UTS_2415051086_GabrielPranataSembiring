import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/text_styles.dart';
import '../utils/formatters.dart';
import 'tag_chip.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.title,
    required this.category,
    required this.tone,
    required this.meta,
    required this.amount,
    required this.isIncome,
    this.onTap,
  });

  final String title;
  final String category;
  final TagTone tone;
  final String meta;
  final int amount;
  final bool isIncome;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = isIncome ? tokens.income : tokens.expense;
    final sign = isIncome ? '+' : '−';

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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TagChip(label: category, tone: tone),
                      Text(
                        meta,
                        style: TextStyle(fontSize: 13, color: tokens.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('$sign${formatNumber(amount)}', style: moneyStyle(color: color)),
          ],
        ),
      ),
    );
  }
}