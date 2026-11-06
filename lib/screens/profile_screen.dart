import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_constants.dart';
import '../providers/theme_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/breakpoints.dart';
import '../widgets/ledger_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide =
              screenSizeOf(constraints.maxWidth) == ScreenSize.expanded;
          const identity = _Identity();
          const display = _DisplaySettings();

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: wide ? 1000 : 640),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: wide
                    ? const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: identity),
                          SizedBox(width: 24),
                          Expanded(child: display),
                        ],
                      )
                    : const Column(children: [identity, display]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        LedgerRow(label: 'Nama', value: AppConstants.studentName),
        LedgerRow(label: 'NIM', value: AppConstants.studentId),
        LedgerRow(label: 'Kelas', value: AppConstants.studentClass),
        LedgerRow(label: 'Aplikasi', value: AppConstants.appName),
      ],
    );
  }
}

class _DisplaySettings extends StatelessWidget {
  const _DisplaySettings();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final tokens = context.tokens;

    Widget option(String label, String description, ThemeMode mode) {
      return _ThemeOptionRow(
        label: label,
        description: description,
        selected: theme.mode == mode,
        onTap: () => theme.setMode(mode),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 4),
          child: Text(
            'Tampilan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        option(
          'Ikuti sistem',
          'Mengikuti pengaturan terang atau gelap di perangkat',
          ThemeMode.system,
        ),
        option('Terang', 'Selalu memakai tampilan terang', ThemeMode.light),
        option('Gelap', 'Selalu memakai tampilan gelap', ThemeMode.dark),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Text(
            'Pilihan disimpan di perangkat.',
            style: TextStyle(fontSize: 13, color: tokens.muted),
          ),
        ),
      ],
    );
  }
}

class _ThemeOptionRow extends StatelessWidget {
  const _ThemeOptionRow({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: tokens.rule)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: tokens.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 24,
                child: selected ? const Icon(Icons.check, size: 22) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}