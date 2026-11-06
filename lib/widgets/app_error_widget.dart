import 'package:flutter/widgets.dart';

/// Ditampilkan menggantikan widget yang gagal dibangun (hanya di versi rilis).
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: Color(0xFF191919),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Terjadi kesalahan pada tampilan ini.\n'
              'Coba kembali ke layar sebelumnya.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFEDEDED),
                fontSize: 14,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}