class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String description;
  final String date;
  final String status;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.date,
    required this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'transfer',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EGP',
      description: json['description'] ?? '',
      date: json['date'] ?? json['createdAt'] ?? '',
      status: json['status'] ?? 'completed',
    );
  }
}