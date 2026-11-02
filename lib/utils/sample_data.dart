import '../theme/app_tokens.dart';

class SampleTx {
  const SampleTx({
    required this.title,
    required this.category,
    required this.tone,
    required this.account,
    required this.date,
    required this.amount,
    required this.isIncome,
  });

  final String title;
  final String category;
  final TagTone tone;
  final String account;
  final String date;
  final int amount;
  final bool isIncome;

  String get meta => '$date, $account';
}

const sampleTransactions = <SampleTx>[
  SampleTx(
    title: 'Honor asisten lab',
    category: 'Honor',
    tone: TagTone.green,
    account: 'E-wallet',
    date: '2 Nov',
    amount: 450000,
    isIncome: true,
  ),
  SampleTx(
    title: 'Fotokopi modul',
    category: 'Kuliah',
    tone: TagTone.blue,
    account: 'Tunai',
    date: '2 Nov',
    amount: 12500,
    isIncome: false,
  ),
  SampleTx(
    title: 'Makan siang warteg',
    category: 'Makanan',
    tone: TagTone.amber,
    account: 'Tunai',
    date: '2 Nov',
    amount: 18000,
    isIncome: false,
  ),
  SampleTx(
    title: 'Bayar kos',
    category: 'Tempat tinggal',
    tone: TagTone.rose,
    account: 'Bank',
    date: '1 Nov',
    amount: 800000,
    isIncome: false,
  ),
  SampleTx(
    title: 'Uang saku',
    category: 'Uang saku',
    tone: TagTone.green,
    account: 'Bank',
    date: '1 Nov',
    amount: 2000000,
    isIncome: true,
  ),
];

const sampleAccounts = <(String, int)>[
  ('Tunai', 319500),
  ('Bank', 1900000),
  ('E-wallet', 400000),
];

int get sampleTotalBalance =>
    sampleAccounts.fold(0, (sum, account) => sum + account.$2);