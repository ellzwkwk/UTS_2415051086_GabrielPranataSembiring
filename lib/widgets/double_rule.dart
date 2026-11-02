import 'package:flutter/material.dart';

class DoubleRule extends StatelessWidget {
  const DoubleRule({super.key, this.gap = 3, this.thickness = 1.5});

  final double gap;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: thickness, color: color),
          SizedBox(height: gap),
          Container(height: thickness, color: color),
        ],
      ),
    );
  }
}