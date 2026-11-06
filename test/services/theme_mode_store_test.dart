import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/services/theme_mode_store.dart';

void main() {
  group('themeModeFromName', () {
    test('mengenali ketiga nama tema', () {
      expect(themeModeFromName('system'), ThemeMode.system);
      expect(themeModeFromName('light'), ThemeMode.light);
      expect(themeModeFromName('dark'), ThemeMode.dark);
    });

    test('nilai kosong atau tidak dikenal menghasilkan null', () {
      expect(themeModeFromName(null), isNull);
      expect(themeModeFromName(''), isNull);
      expect(themeModeFromName('biru'), isNull);
    });

    test('nama dari ThemeMode.name bisa dikembalikan', () {
      for (final mode in ThemeMode.values) {
        expect(themeModeFromName(mode.name), mode);
      }
    });
  });
}