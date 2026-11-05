import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.query,
    required this.onChanged,
    this.hint = 'Cari transaksi',
  });

  /// Isi pencarian saat ini (sumbernya provider).
  final String query;
  final ValueChanged<String> onChanged;
  final String hint;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sinkron dengan perubahan dari luar, misalnya tombol "Reset filter".
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: tokens.muted),
        prefixIcon: Icon(Icons.search, color: tokens.muted),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Hapus pencarian',
              icon: const Icon(Icons.close),
              onPressed: () {
                _controller.clear();
                widget.onChanged('');
              },
            );
          },
        ),
      ),
    );
  }
}