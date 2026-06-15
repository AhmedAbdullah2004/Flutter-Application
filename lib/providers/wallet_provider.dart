import 'package:flutter/material.dart';
import '../models/wallet_model.dart';

class WalletProvider extends ChangeNotifier {
  List<WalletModel> _wallets = [];
  bool _isLoading = false;
  String? _error;

  List<WalletModel> get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalBalance => _wallets.fold(0.0, (sum, w) => sum + w.balance);

  Future<void> loadWallets({String? token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    
    _wallets = [
      WalletModel(
        id: 'w1',
        userId: 'd2a979a4-3c0c-44ca-99d6-c3d4d860ca80',
        currencyCode: 'EGP',
        balance: 12450.75,
        createdAt: DateTime.now().toIso8601String(),
      ),
      WalletModel(
        id: 'w2',
        userId: 'd2a979a4-3c0c-44ca-99d6-c3d4d860ca80',
        currencyCode: 'USD',
        balance: 320.50,
        createdAt: DateTime.now().toIso8601String(),
      ),
      WalletModel(
        id: 'w3',
        userId: 'd2a979a4-3c0c-44ca-99d6-c3d4d860ca80',
        currencyCode: 'EUR',
        balance: 180.00,
        createdAt: DateTime.now().toIso8601String(),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createWallet(String currencyCode, String? token) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    final newWallet = WalletModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'd2a979a4-3c0c-44ca-99d6-c3d4d860ca80',
      currencyCode: currencyCode,
      balance: 0.0,
      createdAt: DateTime.now().toIso8601String(),
    );

    _wallets.add(newWallet);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // ✅ الدالة المهمة للصرف
  void updateWalletBalance(String walletId, double newBalance) {
    final index = _wallets.indexWhere((w) => w.id == walletId);
    if (index != -1) {
      final oldWallet = _wallets[index];
      _wallets[index] = WalletModel(
        id: oldWallet.id,
        userId: oldWallet.userId,
        currencyCode: oldWallet.currencyCode,
        balance: newBalance,
        createdAt: oldWallet.createdAt,
      );
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}