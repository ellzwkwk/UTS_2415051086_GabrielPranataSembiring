import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dompetku/providers/theme_provider.dart';
import 'package:dompetku/screens/profile_screen.dart';
import 'package:dompetku/services/theme_mode_store.dart';
import 'package:dompetku/theme/app_tokens.dart';

class _MemoryStore implements ThemeModeStore {
  _MemoryStore([this.stored]);

  ThemeMode? stored;

  @override
  Future<ThemeMode?> read() async => stored;

  @override
  Future<void> write(ThemeMode mode) async => stored = mode;
}

Future<(ThemeProvider, _MemoryStore)> pumpProfile(
  WidgetTester tester, {
  ThemeMode? stored,
}) async {
  final store = _MemoryStore(stored);
  final provider = ThemeProvider(store);
  await provider.load();

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        theme: ThemeData(extensions: const [AppTokens.light]),
        home: const ProfileScreen(),
      ),
    ),
  );
  return (provider, store);
}

void main() {
  testWidgets('menampilkan identitas dan tiga pilihan tampilan', (tester) async {
    await pumpProfile(tester);

    expect(find.text('Gabriel Pranata Sembiring'), findsOneWidget);
    expect(find.text('2415051086'), findsOneWidget);
    expect(find.text('Ikuti sistem'), findsOneWidget);
    expect(find.text('Terang'), findsOneWidget);
    expect(find.text('Gelap'), findsOneWidget);
  });

  testWidgets('pilihan awal diberi tanda centang', (tester) async {
    await pumpProfile(tester);

    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('pilihan tersimpan ditandai sejak awal', (tester) async {
    final (provider, _) = await pumpProfile(tester, stored: ThemeMode.dark);

    expect(provider.mode, ThemeMode.dark);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('memilih Gelap mengubah tema dan menyimpannya', (tester) async {
    final (provider, store) = await pumpProfile(tester);

    await tester.tap(find.text('Gelap'));
    await tester.pump();

    expect(provider.mode, ThemeMode.dark);
    expect(store.stored, ThemeMode.dark);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}