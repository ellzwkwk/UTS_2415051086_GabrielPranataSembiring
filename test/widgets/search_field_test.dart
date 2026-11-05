import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/theme/app_tokens.dart';
import 'package:dompetku/widgets/search_field.dart';

Widget host({required String query, required ValueChanged<String> onChanged}) {
  return MaterialApp(
    theme: ThemeData(extensions: const [AppTokens.light]),
    home: Scaffold(body: SearchField(query: query, onChanged: onChanged)),
  );
}

String fieldText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

void main() {
  testWidgets('mengetik memanggil onChanged', (tester) async {
    String? last;
    await tester.pumpWidget(host(query: '', onChanged: (v) => last = v));

    await tester.enterText(find.byType(TextField), 'warteg');

    expect(last, 'warteg');
  });

  testWidgets('tombol hapus hanya muncul saat ada teks', (tester) async {
    await tester.pumpWidget(host(query: '', onChanged: (_) {}));
    expect(find.byTooltip('Hapus pencarian'), findsNothing);

    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump();

    expect(find.byTooltip('Hapus pencarian'), findsOneWidget);
  });

  testWidgets('tombol hapus mengosongkan isi dan memanggil onChanged',
      (tester) async {
    String? last;
    await tester.pumpWidget(host(query: '', onChanged: (v) => last = v));

    await tester.enterText(find.byType(TextField), 'kos');
    await tester.pump();
    await tester.tap(find.byTooltip('Hapus pencarian'));
    await tester.pump();

    expect(fieldText(tester), '');
    expect(last, '');
    expect(find.byTooltip('Hapus pencarian'), findsNothing);
  });

  testWidgets('isi awal mengikuti query', (tester) async {
    await tester.pumpWidget(host(query: 'abc', onChanged: (_) {}));

    expect(fieldText(tester), 'abc');
    expect(find.byTooltip('Hapus pencarian'), findsOneWidget);
  });

  testWidgets('query yang dikosongkan dari luar ikut mengosongkan isi',
      (tester) async {
    await tester.pumpWidget(host(query: 'abc', onChanged: (_) {}));
    expect(fieldText(tester), 'abc');

    // Misalnya tombol "Reset filter" ditekan.
    await tester.pumpWidget(host(query: '', onChanged: (_) {}));
    await tester.pump();

    expect(fieldText(tester), '');
  });
}