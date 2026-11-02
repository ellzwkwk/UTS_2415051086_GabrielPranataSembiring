import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/text_styles.dart';

class LedgerRow extends StatelessWidget {
  const LedgerRow({
    super.key,
    required this.label,
    this.value,
    this.valueColor,
    this.valueWidget,
  }) : assert(value != null || valueWidget != null);

  final String label;
  final String? value;
  final Color? valueColor;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.tokens.rule)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
            child: valueWidget ??
                Text(
                  value!,
                  textAlign: TextAlign.right,
                  style: moneyStyle(color: valueColor),
                ),
          ),
        ],
      ),
    );
  }
}