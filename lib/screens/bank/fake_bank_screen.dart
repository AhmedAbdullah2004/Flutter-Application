import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class FakeBankScreen extends StatefulWidget {
  const FakeBankScreen({super.key});

  @override
  State<FakeBankScreen> createState() => _FakeBankScreenState();
}

class _FakeBankScreenState extends State<FakeBankScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _amountController = TextEditingController();

  bool _isLoading = false;
  String _type = 'deposit';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? _userIdFromToken(String? token) {
    if (token == null || token.isEmpty) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );

    final data = jsonDecode(payload);
    return data['nameid']?.toString();
  }

  Future<void> _submit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    final amount = double.tryParse(_amountController.text.trim());
    final userId = _userIdFromToken(auth.token);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب مبلغ صحيح')),
      );
      return;
    }

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم تحديد المستخدم')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final endpoint = _type == 'deposit'
          ? '/api/FakeBank/deposit'
          : '/api/FakeBank/withdraw';

      final response = await _apiService.post(
        endpoint,
        token: auth.token,
        body: {
          "userId": userId,
          "amount": amount,
        },
      );

      await walletProvider.loadWallets(token: auth.token);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']?.toString() ?? 'تمت العملية بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );

      _amountController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '').trim()),
          backgroundColor: AppColors.error,
        ),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDeposit = _type == 'deposit';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('البنك والمحفظة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'deposit',
                  label: Text('من البنك للمحفظة'),
                  icon: Icon(Icons.account_balance),
                ),
                ButtonSegment(
                  value: 'withdraw',
                  label: Text('من المحفظة للبنك'),
                  icon: Icon(Icons.account_balance_wallet),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (value) {
                setState(() => _type = value.first);
              },
            ),
            const SizedBox(height: 32),
            Icon(
              isDeposit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              size: 70,
              color: isDeposit ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(height: 16),
            Text(
              isDeposit
                  ? 'إيداع من البنك إلى المحفظة'
                  : 'سحب من المحفظة إلى البنك',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  isDeposit ? 'إيداع الآن' : 'سحب الآن',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}