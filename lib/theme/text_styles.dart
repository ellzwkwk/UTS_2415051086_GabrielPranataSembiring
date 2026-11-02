import 'package:flutter/material.dart';

TextStyle moneyStyle({
  double size = 16,
  FontWeight weight = FontWeight.w600,
  Color? color,
}) {
  return TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}