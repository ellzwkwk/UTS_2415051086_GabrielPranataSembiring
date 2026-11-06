import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

/// Mengubah nama tersimpan ("light", "dark", "system") menjadi [ThemeMode].
/// Nilai kosong atau tidak dikenal menghasilkan null.
ThemeMode? themeModeFromName(String? name) {
  for (final mode in ThemeMode.values) {
    if (mode.name == name) return mode;
  }
  return null;
}

/// Penyimpanan pilihan tema. Dipisah dari provider agar bisa dites
/// tanpa penyimpanan perangkat.
abstract class ThemeModeStore {
  Future<ThemeMode?> read();
  Future<void> write(ThemeMode mode);
}

class SharedPrefsThemeModeStore implements ThemeModeStore {
  static const _key = 'theme_mode';

  @override
  Future<ThemeMode?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return themeModeFromName(prefs.getString(_key));
  }

  @override
  Future<void> write(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}