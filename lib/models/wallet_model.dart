class WalletModel {
  final String id;
  final String userId;
  final String currencyCode;
  final double balance;
  final String createdAt;

  WalletModel({
    required this.id,
    required this.userId,
    required this.currencyCode,
    required this.balance,
    required this.createdAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? json['walletId'] ?? '',
      userId: json['userId'] ?? '',
      currencyCode: json['currencyCode'] ?? 'EGP',
      balance: (json['balance'] ?? 0).toDouble(),
      createdAt: json['createdAt'] ?? '',
    );
  }
}