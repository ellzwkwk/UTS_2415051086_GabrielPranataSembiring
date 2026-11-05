import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        scheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF16213A),
          onPrimary: Color(0xFFE8EFEA),
          secondary: Color(0xFFF2C230),
          onSecondary: Color(0xFF16213A),
          error: Color(0xFFA83A2C),
          onError: Colors.white,
          surface: Color(0xFFE8EFEA),
          onSurface: Color(0xFF16213A),
        ),
        tokens: AppTokens.light,
      );

  static ThemeData get dark => _build(
        scheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFEDEDED),
          onPrimary: Color(0xFF191919),
          secondary: Color(0xFFEDEDED),
          onSecondary: Color(0xFF191919),
          error: Color(0xFFF08A7E),
          onError: Color(0xFF191919),
          surface: Color(0xFF191919),
          onSurface: Color(0xFFEDEDED),
        ),
        tokens: AppTokens.dark,
      );

  static ThemeData _build({
    required ColorScheme scheme,
    required AppTokens tokens,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
    );
    final textTheme = GoogleFonts.figtreeTextTheme(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));

    TextStyle navLabel(bool selected) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected ? scheme.onSurface : tokens.muted,
        );

    UnderlineInputBorder line(Color color, [double width = 1]) =>
        UnderlineInputBorder(borderSide: BorderSide(color: color, width: width));

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(color: tokens.rule, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
          minimumSize: const Size.fromHeight(52),
          shape: shape,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: tokens.outline),
          shape: shape,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        elevation: 2,
        shape: shape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: tokens.muted),
        floatingLabelStyle: TextStyle(color: scheme.onSurface),
        helperStyle: TextStyle(color: tokens.muted),
        enabledBorder: line(tokens.outline),
        focusedBorder: line(scheme.onSurface, 2),
        errorBorder: line(scheme.error),
        focusedErrorBorder: line(scheme.error, 2),
        disabledBorder: line(tokens.rule),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondary,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onSecondary
                : tokens.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => navLabel(states.contains(WidgetState.selected)),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondary,
        selectedIconTheme: IconThemeData(color: scheme.onSecondary),
        unselectedIconTheme: IconThemeData(color: tokens.muted),
        selectedLabelTextStyle: navLabel(true),
        unselectedLabelTextStyle: navLabel(false),
      ),
      extensions: [tokens],
    );
  }
}