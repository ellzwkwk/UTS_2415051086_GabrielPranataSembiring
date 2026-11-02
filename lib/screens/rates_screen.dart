import 'package:flutter/material.dart';

/// Kerangka sementara. Diisi data kurs dari REST API di milestone 8.
class RatesScreen extends StatelessWidget {
  const RatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kurs')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Kurs mata uang akan ditampilkan di sini.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}