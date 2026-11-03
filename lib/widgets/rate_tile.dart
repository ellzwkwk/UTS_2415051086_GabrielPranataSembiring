import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/text_styles.dart';
import '../utils/formatters.dart';

class RateTile extends StatelessWidget {
  const RateTile({
    super.key,
    required this.code,
    required this.name,
    required this.idrPerUnit,
  });

  final String code;
  final String name;

  /// Berapa rupiah untuk 1 satuan mata uang ini. Null jika tidak tersedia.
  final double? idrPerUnit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final value = idrPerUnit == null ? '-' : 'Rp ${formatIdrRate(idrPerUnit!)}';

    return Container(
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
                  '1 $code',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: TextStyle(fontSize: 13, color: tokens.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(value, style: moneyStyle()),
        ],
      ),
    );
  }
}