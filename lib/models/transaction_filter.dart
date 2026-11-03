import 'transaction.dart';

enum TransactionPeriod { all, thisMonth, lastMonth }

class TransactionFilter {
  const TransactionFilter({
    this.type,
    this.query = '',
    this.period = TransactionPeriod.all,
  });

  /// Null berarti semua jenis.
  final TransactionType? type;
  final String query;
  final TransactionPeriod period;

  bool get isActive =>
      type != null ||
      query.trim().isNotEmpty ||
      period != TransactionPeriod.all;

  TransactionFilter copyWith({
    TransactionType? type,
    bool clearType = false,
    String? query,
    TransactionPeriod? period,
  }) {
    return TransactionFilter(
      type: clearType ? null : (type ?? this.type),
      query: query ?? this.query,
      period: period ?? this.period,
    );
  }
}