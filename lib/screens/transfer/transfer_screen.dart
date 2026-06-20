import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _receiverController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _otpController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    _descController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendTransfer() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    if (auth.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
      );
      return;
    }

    if (walletProvider.wallets.isEmpty) {
      await walletProvider.loadWallets(token: auth.token);
    }

    if (walletProvider.wallets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد محفظة')),
      );
      return;
    }

    final walletId = walletProvider.wallets.first.id;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.post(
        ApiConstants.transferSend,
        token: auth.token,
        body: {
          "senderWalletId": walletId,
          "receiverPhoneOrEmail": _receiverController.text.trim(),
          "amount": double.parse(_amountController.text.trim()),
          "description": _descController.text.trim(),
          "otpCode": _otpController.text.trim(),
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message']?.toString() ?? 'تم التحويل بنجاح')),
      );

      await walletProvider.loadWallets(token: auth.token);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception:', '').trim())),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إرسال أموال'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _receiverController,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف أو البريد',
                prefixIcon: Icon(Icons.person_search),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'وصف (اختياري)',
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'كود OTP',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendTransfer,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('إرسال الآن', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}