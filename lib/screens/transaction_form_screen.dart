import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_tokens.dart';
import '../theme/text_styles.dart';
import '../utils/category_style.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/option_chip.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({
    super.key,
    this.initialType = TransactionType.expense,
  });

  final TransactionType initialType;

  static Future<void> open(
    BuildContext context, {
    TransactionType type = TransactionType.expense,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TransactionFormScreen(initialType: type),
      ),
    );
  }

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  late TransactionType _type;
  late String _category;
  late DateTime _date;
  String _account = kAccounts.first;
  bool _isSaving = false;

  List<String> get _categories =>
      _type.isIncome ? kIncomeCategories : kExpenseCategories;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _category = _categories.first;
    _date = _today;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _setType(TransactionType type) {
    if (_isSaving || type == _type) return;
    setState(() {
      _type = type;
      _category = _categories.first;
    });
  }

  Future<void> _pickDate() async {
    final today = _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: DateTime(2020),
      lastDate: today,
    );
    if (picked != null && mounted) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save() async {
    // Lapis 1: abaikan ketukan kedua saat proses simpan masih berjalan.
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSaving = true);

    try {
      await provider.add(
        Transaction(
          studentId: AppConstants.studentId,
          title: _titleCtrl.text.trim(),
          amount: parseAmount(_amountCtrl.text)!,
          type: _type,
          category: _category,
          account: _account,
          note: _noteCtrl.text.trim(),
          date: _date,
        ),
      );
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil disimpan')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final amount = parseAmount(_amountCtrl.text);

    return PopScope(
      // Lapis 3: tombol kembali ditahan selama proses simpan.
      canPop: !_isSaving,
      child: Scaffold(
        appBar: AppBar(title: const Text('Tambah transaksi')),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    Text(
                      '${AppConstants.studentId} - ${AppConstants.studentName}',
                      style: TextStyle(fontSize: 13, color: tokens.muted),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        OptionChip(
                          label: 'Keluar',
                          selected: !_type.isIncome,
                          onTap: () => _setType(TransactionType.expense),
                        ),
                        const SizedBox(width: 10),
                        OptionChip(
                          label: 'Masuk',
                          selected: _type.isIncome,
                          onTap: () => _setType(TransactionType.income),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountCtrl,
                      enabled: !_isSaving,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                      style: moneyStyle(size: 24, weight: FontWeight.w700),
                      decoration: InputDecoration(
                        labelText: 'Nominal',
                        prefixText: 'Rp ',
                        helperText: (amount != null && amount > 0)
                            ? formatRupiah(amount)
                            : ' ',
                      ),
                      validator: validateAmount,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleCtrl,
                      enabled: !_isSaving,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: [LengthLimitingTextInputFormatter(60)],
                      decoration: const InputDecoration(labelText: 'Judul'),
                      validator: validateTitle,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: ValueKey('kategori-${_type.name}'),
                      initialValue: _category,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: [
                        for (final c in _categories)
                          DropdownMenuItem(value: c, child: Text(c)),
                      ],
                      onChanged: _isSaving
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _category = value);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _account,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Akun'),
                      items: [
                        for (final a in kAccounts)
                          DropdownMenuItem(value: a, child: Text(a)),
                      ],
                      onChanged: _isSaving
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _account = value);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _isSaving ? null : _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal',
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(formatLongDate(_date)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteCtrl,
                      enabled: !_isSaving,
                      maxLength: 100,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (opsional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      // Lapis 2: tampilan sibuk selama menyimpan.
                      onPressed: _save,
                      child: _isSaving
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: scheme.onSecondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('Menyimpan...'),
                              ],
                            )
                          : const Text('Simpan'),
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