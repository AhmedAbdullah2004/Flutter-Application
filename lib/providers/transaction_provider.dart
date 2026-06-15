import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions(String walletId, {String? token}) async {
    _isLoading = true;
    notifyListeners();

    // TODO: API call
    await Future.delayed(const Duration(milliseconds: 600));
    
    _transactions = []; // Mock
    _isLoading = false;
    notifyListeners();
  }
}