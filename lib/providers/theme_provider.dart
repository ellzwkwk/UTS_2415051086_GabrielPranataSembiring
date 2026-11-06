import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import '../services/theme_mode_store.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._store);

  final ThemeModeStore _store;

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  /// Membaca pilihan tersimpan. Jika gagal atau belum ada, mengikuti sistem.
  Future<void> load() async {
    try {
      _mode = await _store.read() ?? ThemeMode.system;
    } catch (_) {
      _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  /// Mengganti tema langsung, lalu menyimpannya. Jika penyimpanan gagal,
  /// tema tetap berubah untuk sesi ini.
  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();

    try {
      await _store.write(mode);
    } catch (_) {
      // Pilihan hanya tidak bertahan setelah aplikasi ditutup.
    }
  }
}