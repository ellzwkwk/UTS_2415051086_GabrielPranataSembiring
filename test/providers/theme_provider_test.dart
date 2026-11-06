import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/providers/theme_provider.dart';
import 'package:dompetku/services/theme_mode_store.dart';

class FakeThemeStore implements ThemeModeStore {
  FakeThemeStore({this.stored, this.failRead = false, this.failWrite = false});

  ThemeMode? stored;
  final bool failRead;
  final bool failWrite;
  int writes = 0;

  @override
  Future<ThemeMode?> read() async {
    if (failRead) throw Exception('gagal baca');
    return stored;
  }

  @override
  Future<void> write(ThemeMode mode) async {
    writes++;
    if (failWrite) throw Exception('gagal tulis');
    stored = mode;
  }
}

void main() {
  group('load', () {
    test('tanpa pilihan tersimpan mengikuti sistem', () async {
      final p = ThemeProvider(FakeThemeStore());
      await p.load();

      expect(p.mode, ThemeMode.system);
    });

    test('memakai pilihan yang tersimpan', () async {
      final p = ThemeProvider(FakeThemeStore(stored: ThemeMode.dark));
      await p.load();

      expect(p.mode, ThemeMode.dark);
    });

    test('gagal membaca kembali ke sistem tanpa error', () async {
      final p = ThemeProvider(FakeThemeStore(failRead: true));
      await p.load();

      expect(p.mode, ThemeMode.system);
    });
  });

  group('setMode', () {
    test('mengubah tema, memberi tahu listener, dan menyimpannya', () async {
      final store = FakeThemeStore();
      final p = ThemeProvider(store);
      var notified = 0;
      p.addListener(() => notified++);

      await p.setMode(ThemeMode.light);

      expect(p.mode, ThemeMode.light);
      expect(notified, 1);
      expect(store.stored, ThemeMode.light);
    });

    test('nilai yang sama tidak menyimpan dan tidak memberi tahu', () async {
      final store = FakeThemeStore();
      final p = ThemeProvider(store);
      var notified = 0;
      p.addListener(() => notified++);

      await p.setMode(ThemeMode.system);

      expect(notified, 0);
      expect(store.writes, 0);
    });

    test('gagal menyimpan: tema tetap berubah untuk sesi ini', () async {
      final p = ThemeProvider(FakeThemeStore(failWrite: true));

      await p.setMode(ThemeMode.dark);

      expect(p.mode, ThemeMode.dark);
    });
  });
}