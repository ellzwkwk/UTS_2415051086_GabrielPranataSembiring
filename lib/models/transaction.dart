import '../utils/formatters.dart';

enum TransactionType {
  income('income'),
  expense('expense');

  const TransactionType(this.value);

  /// Nilai yang disimpan di database.
  final String value;

  bool get isIncome => this == TransactionType.income;

  static TransactionType fromValue(String value) {
    return TransactionType.values.firstWhere(
      (t) => t.value == value,
      orElse: () =>
          throw FormatException('Jenis transaksi tidak dikenal: $value'),
    );
  }
}

class Transaction {
  const Transaction({
    this.id,
    required this.studentId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.account,
    this.note = '',
    required this.date,
  });

  /// Dibuat oleh server, jadi kosong untuk transaksi yang belum disimpan.
  final int? id;
  final String studentId;
  final String title;

  /// Nominal dalam rupiah (bilangan bulat).
  final int amount;
  final TransactionType type;
  final String category;
  final String account;
  final String note;
  final DateTime date;

  bool get isIncome => type.isIncome;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: (json['id'] as num?)?.toInt(),
      studentId: json['student_id'] as String,
      title: json['title'] as String,
      // `num` menerima int maupun double dari JSON.
      amount: (json['amount'] as num).toInt(),
      type: TransactionType.fromValue(json['type'] as String),
      category: json['category'] as String,
      account: json['account'] as String,
      note: (json['note'] as String?) ?? '',
      date: parseIsoDate(json['trx_date'] as String),
    );
  }

  /// `id` tidak dikirim karena dibuat oleh database.
  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'title': title,
        'amount': amount,
        'type': type.value,
        'category': category,
        'account': account,
        'note': note,
        'trx_date': formatIsoDate(date),
      };

  Transaction copyWith({
    int? id,
    String? studentId,
    String? title,
    int? amount,
    TransactionType? type,
    String? category,
    String? account,
    String? note,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      account: account ?? this.account,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }
}