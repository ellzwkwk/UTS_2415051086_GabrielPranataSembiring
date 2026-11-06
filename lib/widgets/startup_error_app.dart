import 'package:flutter/material.dart';
import '../config/app_constants.dart';

/// Layar pengganti saat aplikasi gagal disiapkan (misalnya konfigurasi
/// Supabase salah), supaya pengguna tidak melihat layar putih.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({
    super.key,
    required this.message,
    required this.onRetry,
    this.detail,
  });

  final String message;

  /// Rincian teknis untuk debugging, ditampilkan kecil di bawah pesan.
  final String? detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      '${AppConstants.studentId} - ${AppConstants.studentName}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (detail != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        detail!,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 200,
                      child: FilledButton(
                        onPressed: onRetry,
                        child: const Text('Coba lagi'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}