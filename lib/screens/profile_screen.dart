import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../widgets/ledger_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            children: const [
              LedgerRow(label: 'Nama', value: AppConstants.studentName),
              LedgerRow(label: 'NIM', value: AppConstants.studentId),
              LedgerRow(label: 'Kelas', value: AppConstants.studentClass),
              LedgerRow(label: 'Aplikasi', value: AppConstants.appName),
            ],
          ),
        ),
      ),
    );
  }
}