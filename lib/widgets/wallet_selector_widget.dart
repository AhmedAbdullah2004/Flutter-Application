import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../utils/constants.dart';

class WalletSelectorWidget extends StatelessWidget {
  final List<WalletModel> wallets;
  final WalletModel? selectedWallet;
  final ValueChanged<WalletModel?> onChanged;

  const WalletSelectorWidget({
    super.key,
    required this.wallets,
    required this.selectedWallet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (wallets.isEmpty) {
      return const Text('لا توجد محافظ متاحة');
    }

    return DropdownButtonFormField<WalletModel>(
      value: selectedWallet,
      decoration: const InputDecoration(
        labelText: 'اختر المحفظة',
        prefixIcon: Icon(Icons.account_balance_wallet),
      ),
      items: wallets.map((wallet) {
        return DropdownMenuItem(
          value: wallet,
          child: Text(
            '${wallet.currencyCode} - ${wallet.balance.toStringAsFixed(2)}',
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}