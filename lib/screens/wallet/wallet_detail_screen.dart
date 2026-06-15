import 'package:flutter/material.dart';
import '../../models/wallet_model.dart';
import '../../utils/constants.dart';

class WalletDetailScreen extends StatelessWidget {
  final WalletModel wallet;

  const WalletDetailScreen({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('محفظة ${wallet.currencyCode}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF00A844)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    '${wallet.balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    wallet.currencyCode,
                    style: const TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text('العمليات الأخيرة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: List.generate(5, (i) => ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: Text('عملية رقم ${i + 1}'),
                  subtitle: const Text('منذ يومين'),
                  trailing: Text(i % 2 == 0 ? '+150' : '-80', style: TextStyle(color: i % 2 == 0 ? Colors.green : Colors.red)),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}