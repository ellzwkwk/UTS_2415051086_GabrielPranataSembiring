import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_tokens.dart';
import '../theme/text_styles.dart';
import '../utils/category_style.dart';
import '../utils/formatters.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/ledger_row.dart';
import '../widgets/tag_chip.dart';
import 'transaction_form_screen.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key, required this.transaction});

  final Transaction transaction;

  static Future<void> open(BuildContext context, Transaction transaction) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transaction: transaction),
      ),
    );
  }

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  bool _isDeleting = false;

  Future<void> _confirmAndDelete(Transaction t) async {
    // Abaikan ketukan kedua selama proses hapus masih berjalan.
    if (_isDeleting) return;

    final sign = t.isIncome ? '+' : '−';
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus transaksi?',
      message: '"${t.title}" ($sign${formatRupiah(t.amount)}) akan dihapus '
          'permanen. Tindakan ini tidak dapat dibatalkan.',
    );
    if (!confirmed || !mounted) return;

    final provider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isDeleting = true);

    try {
      await provider.remove(t);
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('"${t.title}" berhasil dihapus')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      messenger.showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;

    // Ambil versi terbaru dari provider, supaya hasil edit langsung terlihat.
    final t = context
            .watch<TransactionProvider>()
            .findById(widget.transaction.id) ??
        widget.transaction;
    final color = t.isIncome ? tokens.income : tokens.expense;
    final sign = t.isIncome ? '+' : '−';

    return PopScope(
      // Tombol kembali ditahan selama proses hapus berjalan.
      canPop: !_isDeleting,
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail transaksi')),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$sign${formatRupiah(t.amount)}',
                        style: moneyStyle(
                          size: 30,
                          weight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
                LedgerRow(
                  label: 'Jenis',
                  value: t.isIncome ? 'Pemasukan' : 'Pengeluaran',
                ),
                LedgerRow(
                  label: 'Kategori',
                  valueWidget: TagChip(
                    label: t.category,
                    tone: toneForCategory(t.category, isIncome: t.isIncome),
                  ),
                ),
                LedgerRow(label: 'Akun', value: t.account),
                LedgerRow(label: 'Tanggal', value: formatLongDate(t.date)),
                LedgerRow(
                  label: 'Catatan',
                  value: t.note.isEmpty ? '-' : t.note,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: OutlinedButton.icon(
                    onPressed: _isDeleting
                        ? null
                        : () => TransactionFormScreen.openEdit(context, t),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit transaksi'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: OutlinedButton.icon(
                    onPressed: _isDeleting ? null : () => _confirmAndDelete(t),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                      side: BorderSide(color: scheme.error),
                    ),
                    icon: _isDeleting
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.error,
                            ),
                          )
                        : const Icon(Icons.delete_outline),
                    label: Text(
                      _isDeleting ? 'Menghapus...' : 'Hapus transaksi',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}