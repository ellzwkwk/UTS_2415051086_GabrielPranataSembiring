import '../utils/formatters.dart';

class ExchangeRates {
  const ExchangeRates({
    required this.base,
    required this.date,
    required this.rates,
  });

  /// Mata uang dasar, misalnya "USD".
  final String base;

  /// Tanggal kurs dipublikasikan.
  final DateTime date;

  /// Nilai 1 [base] dalam mata uang lain, misalnya {"IDR": 18148.0}.
  final Map<String, double> rates;

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    final raw = json['rates'] as Map<String, dynamic>;
    return ExchangeRates(
      base: json['base'] as String,
      date: parseIsoDate(json['date'] as String),
      // IDR dikirim sebagai bilangan bulat (18148), mata uang lain desimal.
      // `as double` akan crash pada int, jadi lewat `num`.
      rates: {
        for (final entry in raw.entries) entry.key: (entry.value as num).toDouble(),
      },
    );
  }

  Map<String, dynamic> toJson() => {
        'base': base,
        'date': formatIsoDate(date),
        'rates': rates,
      };

  /// Berapa rupiah untuk 1 satuan [currency]. Null jika kurs tidak tersedia.
  double? idrPerUnit(String currency) {
    if (currency == 'IDR') return 1;

    if (base == 'IDR') {
      final r = rates[currency];
      return (r == null || r == 0) ? null : 1 / r;
    }

    final idr = rates['IDR'];
    if (idr == null) return null;
    if (currency == base) return idr;

    final r = rates[currency];
    return (r == null || r == 0) ? null : idr / r;
  }

  /// Nilai [rupiah] dalam [currency]. Null jika kurs tidak tersedia.
  double? convertFromIdr(int rupiah, String currency) {
    final perUnit = idrPerUnit(currency);
    if (perUnit == null || perUnit == 0) return null;
    return rupiah / perUnit;
  }
}