import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/constants.dart';
import 'wallet_detail_screen.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  static const List<String> _allCurrencies = [
    'EGP', 'USD', 'EUR', 'GBP', 'SAR', 'AED', 'JPY', 'KWD', 'CNY', 'TRY'
  ];

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('محافظي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: () => _showCreateWalletDialog(context, walletProvider),
          ),
        ],
      ),
      body: walletProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : walletProvider.wallets.isEmpty
          ? const Center(child: Text('لا توجد محافظ بعد'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: walletProvider.wallets.length,
        itemBuilder: (context, index) {
          final wallet = walletProvider.wallets[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  wallet.currencyCode,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                '${wallet.balance.toStringAsFixed(2)} ${wallet.currencyCode}',
              ),
              subtitle: Text(
                'تم الإنشاء: ${wallet.createdAt.substring(0, 10)}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        WalletDetailScreen(wallet: wallet),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreateWalletDialog(BuildContext context, WalletProvider provider) {
    String selectedCurrency = 'EGP';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إنشاء محفظة جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('اختر العملة اللي عايز تنشئ بيها المحفظة:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCurrency,
                decoration: const InputDecoration(labelText: 'العملة'),
                items: _allCurrencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCurrency = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final alreadyExists = provider.wallets.any(
                      (wallet) => wallet.currencyCode == selectedCurrency,
                );

                if (alreadyExists) {
                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('لديك محفظة $selectedCurrency بالفعل'),
                      backgroundColor: AppColors.warning,
                    ),
                  );

                  return;
                }

                Navigator.pop(ctx);

                final authProvider =
                Provider.of<AuthProvider>(context, listen: false);

                final success = await provider.createWallet(
                  selectedCurrency,
                  authProvider.token,
                );

                if (success) {
                  await provider.loadWallets(token: authProvider.token);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                        Text('تم إنشاء محفظة $selectedCurrency بنجاح'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.error ?? 'فشل إنشاء المحفظة'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('إنشاء'),
            ),
          ],
        ),
      ),
    );
  }
}