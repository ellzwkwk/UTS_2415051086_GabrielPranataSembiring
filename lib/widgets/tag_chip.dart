import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, required this.tone});

  final String label;
  final TagTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tokens.tagBg[tone],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: tokens.tagFg[tone],
        ),
      ),
    );
  }
}