import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../widgets/app_error_widget.dart';

/// Memasang penangkap kesalahan global.
void installErrorHooks() {
  // Kesalahan async yang tidak tertangani: dicatat, aplikasi tetap berjalan.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Kesalahan tidak tertangani: $error');
    debugPrintStack(stackTrace: stack);
    return true;
  };

  // Di versi rilis, layar abu-abu bawaan diganti pesan yang jelas.
  // Di mode debug tetap layar merah bawaan agar mudah dilacak.
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const AppErrorWidget();
  }
}