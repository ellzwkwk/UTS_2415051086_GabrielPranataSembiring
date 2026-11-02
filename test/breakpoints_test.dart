import 'package:flutter_test/flutter_test.dart';
import 'package:dompetku/utils/breakpoints.dart';

void main() {
  group('screenSizeOf', () {
    test('compact di bawah 600', () {
      expect(screenSizeOf(320), ScreenSize.compact);
      expect(screenSizeOf(599), ScreenSize.compact);
    });

    test('medium dari 600 sampai 839', () {
      expect(screenSizeOf(600), ScreenSize.medium);
      expect(screenSizeOf(839), ScreenSize.medium);
    });

    test('expanded mulai 840', () {
      expect(screenSizeOf(840), ScreenSize.expanded);
      expect(screenSizeOf(1400), ScreenSize.expanded);
    });
  });
}