import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import 'config/app_constants.dart';
import 'config/supabase_config.dart';
import 'providers/exchange_rate_provider.dart';
import 'providers/transaction_provider.dart';
import 'repositories/exchange_rate_repository.dart';
import 'repositories/transaction_repository.dart';
import 'screens/app_shell.dart';
import 'services/exchange_rate_service.dart';
import 'services/supabase_transaction_data_source.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  // Satu baris inilah yang menentukan sumber data transaksi.
  // Untuk data contoh: TransactionRepository(SampleTransactionDataSource())
  final transactionRepository =
      TransactionRepository(SupabaseTransactionDataSource());
  final rateRepository = ExchangeRateRepository(ExchangeRateService());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(transactionRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExchangeRateProvider(rateRepository)..load(),
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