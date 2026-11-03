import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_constants.dart';
import 'providers/transaction_provider.dart';
import 'repositories/transaction_repository.dart';
import 'screens/app_shell.dart';
import 'services/sample_transaction_data_source.dart';
import 'theme/app_theme.dart';

void main() {
  // Sementara memakai data contoh. Diganti sumber data Supabase di milestone 9.
  final repository = TransactionRepository(SampleTransactionDataSource());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(repository)..load(),
        ),
      ],
      child: const DompetkuApp(),
    ),
  );
}

class DompetkuApp extends StatelessWidget {
  const DompetkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}