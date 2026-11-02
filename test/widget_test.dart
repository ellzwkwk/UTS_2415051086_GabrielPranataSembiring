import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/main.dart';

void main() {
  testWidgets('menampilkan nama aplikasi dan identitas', (tester) async {
    await tester.pumpWidget(const DompetkuApp());

    expect(find.text('Dompetku'), findsOneWidget);
    expect(
      find.text('2415051086 - Gabriel Pranata Sembiring'),
      findsOneWidget,
    );
  });
}