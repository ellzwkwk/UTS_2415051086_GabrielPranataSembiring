import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

/// Memuat ulang transaksi tanpa menghapus daftar yang sedang tampil.
/// Jika gagal, data lama tetap ada dan pengguna diberi tahu lewat SnackBar.
Future<void> refreshTransactions(BuildContext context) async {
  final provider = context.read<TransactionProvider>();
  final messenger = ScaffoldMessenger.of(context);

  final error = await provider.refresh();
  if (error != null) {
    messenger.showSnackBar(
      SnackBar(content: Text('Gagal memuat ulang: $error')),
    );
  }
}