import 'package:flutter/material.dart';

enum TagTone { amber, blue, green, rose }

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.income,
    required this.expense,
    required this.rule,
    required this.muted,
    required this.marker,
    required this.panel,
    required this.outline,
    required this.tagBg,
    required this.tagFg,
  });

  final Color income;
  final Color expense;
  final Color rule;
  final Color muted;
  final Color marker;
  final Color panel;
  final Color outline;
  final Map<TagTone, Color> tagBg;
  final Map<TagTone, Color> tagFg;

  static const light = AppTokens(
    income: Color(0xFF17724F),
    expense: Color(0xFFA83A2C),
    rule: Color(0xFFB6C8BE),
    muted: Color(0xFF4A5A52),
    marker: Color(0xFFF2C230),
    panel: Color(0xFFF3F7F4),
    outline: Color(0xFF9FB5AA),
    tagBg: {
      TagTone.amber: Color(0xFFF3E3D3),
      TagTone.blue: Color(0xFFDCE7F6),
      TagTone.green: Color(0xFFD1EADA),
      TagTone.rose: Color(0xFFF6DADD),
    },
    tagFg: {
      TagTone.amber: Color(0xFF7A4A1F),
      TagTone.blue: Color(0xFF1F4E8C),
      TagTone.green: Color(0xFF0F5C3F),
      TagTone.rose: Color(0xFF8C2B33),
    },
  );

  static const dark = AppTokens(
    income: Color(0xFF6CCB9A),
    expense: Color(0xFFF08A7E),
    rule: Color(0xFF2F2F2F),
    muted: Color(0xFF9B9B9B),
    marker: Color(0xFFEDEDED),
    panel: Color(0xFF202020),
    outline: Color(0xFF3A3A3A),
    tagBg: {
      TagTone.amber: Color(0xFF3B2A1F),
      TagTone.blue: Color(0xFF1F2F45),
      TagTone.green: Color(0xFF1F3A2C),
      TagTone.rose: Color(0xFF3A2427),
    },
    tagFg: {
      TagTone.amber: Color(0xFFE8A87C),
      TagTone.blue: Color(0xFF7FB2F0),
      TagTone.green: Color(0xFF7DD3A0),
      TagTone.rose: Color(0xFFF0929A),
    },
  );

  @override
  AppTokens copyWith({
    Color? income,
    Color? expense,
    Color? rule,
    Color? muted,
    Color? marker,
    Color? panel,
    Color? outline,
    Map<TagTone, Color>? tagBg,
    Map<TagTone, Color>? tagFg,
  }) {
    return AppTokens(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      rule: rule ?? this.rule,
      muted: muted ?? this.muted,
      marker: marker ?? this.marker,
      panel: panel ?? this.panel,
      outline: outline ?? this.outline,
      tagBg: tagBg ?? this.tagBg,
      tagFg: tagFg ?? this.tagFg,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      rule: Color.lerp(rule, other.rule, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      marker: Color.lerp(marker, other.marker, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      tagBg: t < 0.5 ? tagBg : other.tagBg,
      tagFg: t < 0.5 ? tagFg : other.tagFg,
    );
  }
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}