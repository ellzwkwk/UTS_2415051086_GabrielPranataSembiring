import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/widgets/confirm_dialog.dart';

Future<void> pumpHost(
  WidgetTester tester,
  void Function(bool result) onResult,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                final result = await showConfirmDialog(
                  context,
                  title: 'Hapus transaksi?',
                  message: 'Data akan dihapus permanen.',
                );
                onResult(result);
              },
              child: const Text('buka'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('menampilkan judul, pesan, dan dua tombol', (tester) async {
    await pumpHost(tester, (_) {});

    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();

    expect(find.text('Hapus transaksi?'), findsOneWidget);
    expect(find.text('Data akan dihapus permanen.'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Hapus'), findsOneWidget);
  });

  testWidgets('tombol Batal mengembalikan false', (tester) async {
    bool? result;
    await pumpHost(tester, (r) => result = r);

    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(find.text('Hapus transaksi?'), findsNothing);
  });

  testWidgets('tombol Hapus mengembalikan true', (tester) async {
    bool? result;
    await pumpHost(tester, (r) => result = r);

    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('menutup dialog dengan menyentuh luar dianggap batal',
      (tester) async {
    bool? result;
    await pumpHost(tester, (r) => result = r);

    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}