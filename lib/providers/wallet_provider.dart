import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class WalletProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<WalletModel> _wallets = [];
  bool _isLoading = false;
  String? _error;

  List<WalletModel> get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBalance =>
      _wallets.fold(0.0, (sum, wallet) => sum + wallet.balance);

  String? _userIdFromToken(String? token) {
    if (token == null || token.isEmpty) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final data = jsonDecode(payload);

    return data['nameid']?.toString();
  }

  Future<void> loadWallets({String? token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiConstants.myWallets,
        token: token,
      );

      debugPrint('LOAD WALLETS RESPONSE: $response');

      final data = response['data'];

      if (data is List) {
        _wallets = data.map((item) => WalletModel.fromJson(item)).toList();
      } else {
        _wallets = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception:', '').trim();
      debugPrint('LOAD WALLETS ERROR: $_error');

      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createWallet(String currencyCode, String? token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _userIdFromToken(token);

      final response = await _apiService.post(
        '/api/Wallet',
        token: token,
        body: {
          "userId": userId,
          "currencyCode": currencyCode,
        },
      );

      debugPrint('CREATE WALLET RESPONSE: $response');

      await loadWallets(token: token);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception:', '').trim();
      debugPrint('CREATE WALLET ERROR: $_error');

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<double?> getWalletBalance(String walletId, String? token) async {
    try {
      final endpoint =
      ApiConstants.walletBalance.replaceAll('{walletId}', walletId);

      final response = await _apiService.get(endpoint, token: token);
      final data = response['data'];

      if (data is num) return data.toDouble();

      if (data is Map<String, dynamic>) {
        return (data['balance'] ?? 0).toDouble();
      }

      return null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception:', '').trim();
      notifyListeners();
      return null;
    }
  }

  void updateWalletBalance(String walletId, double newBalance) {
    final index = _wallets.indexWhere((wallet) => wallet.id == walletId);

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