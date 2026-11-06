import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/widgets/app_error_widget.dart';
import 'package:dompetku/widgets/startup_error_app.dart';

void main() {
  group('StartupErrorApp', () {
    testWidgets('menampilkan identitas, pesan, dan rincian', (tester) async {
      await tester.pumpWidget(
        StartupErrorApp(
          message: 'Gagal terhubung',
          detail: 'rincian teknis',
          onRetry: () {},
        ),
      );

      expect(find.text('2415051086 - Gabriel Pranata Sembiring'), findsOneWidget);
      expect(find.text('Gagal terhubung'), findsOneWidget);
      expect(find.text('rincian teknis'), findsOneWidget);
    });

    testWidgets('tombol Coba lagi memanggil onRetry', (tester) async {
      var retried = 0;
      await tester.pumpWidget(
        StartupErrorApp(message: 'Gagal', onRetry: () => retried++),
      );

      await tester.tap(find.text('Coba lagi'));

      expect(retried, 1);
    });

    testWidgets('tanpa rincian tidak menampilkan teks rincian', (tester) async {
      await tester.pumpWidget(
        StartupErrorApp(message: 'Gagal', onRetry: () {}),
      );

      expect(find.text('rincian teknis'), findsNothing);
    });
  });

  testWidgets('AppErrorWidget menampilkan pesan yang jelas', (tester) async {
    await tester.pumpWidget(const AppErrorWidget());

    expect(find.textContaining('Terjadi kesalahan'), findsOneWidget);
  });
}