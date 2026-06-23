import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/wallet_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/wallet_selector_widget.dart';

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

  WalletModel? _selectedWallet;

  bool _isLoading = false;
  bool _isSendingOtp = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadWallets);
  }

  Future<void> _loadWallets() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    if (walletProvider.wallets.isEmpty) {
      await walletProvider.loadWallets(token: auth.token);
    }

    if (!mounted) return;

    if (walletProvider.wallets.isNotEmpty && _selectedWallet == null) {
      setState(() {
        _selectedWallet = walletProvider.wallets.first;
      });
    }
  }

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    _descController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendTransferOtp() async {
    setState(() => _isSendingOtp = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.sendOtp(otpType: 'Transfer');

    if (!mounted) return;

    setState(() => _isSendingOtp = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'تم إرسال OTP للتحويل' : auth.error ?? 'فشل إرسال OTP',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  Future<void> _sendTransfer() async {
    final receiver = _receiverController.text.trim();
    final amountText = _amountController.text.trim();
    final otp = _otpController.text.trim();

    if (_selectedWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر المحفظة أولاً')),
      );
      return;
    }

    if (receiver.isEmpty || amountText.isEmpty || otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب البريد والمبلغ وكود OTP')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب مبلغ صحيح')),
      );
      return;
    }

    if (_selectedWallet!.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رصيد المحفظة غير كافي'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.post(
        ApiConstants.transferSend,
        token: auth.token,
        body: {
          "senderWalletId": _selectedWallet!.id,
          "receiverPhoneOrEmail": receiver,
          "amount": amount,
          "description": _descController.text.trim(),
          "otpCode": otp,
        },
      );

      await walletProvider.loadWallets(token: auth.token);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']?.toString() ?? 'تم التحويل بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );

      _receiverController.clear();
      _amountController.clear();
      _descController.clear();
      _otpController.clear();

      setState(() {
        _selectedWallet = walletProvider.wallets.firstWhere(
              (wallet) => wallet.id == _selectedWallet!.id,
          orElse: () => walletProvider.wallets.first,
        );
      });
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
    final walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('إرسال أموال')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            WalletSelectorWidget(
              wallets: walletProvider.wallets,
              selectedWallet: _selectedWallet,
              onChanged: (wallet) {
                setState(() => _selectedWallet = wallet);
              },
            ),
            const SizedBox(height: 20),

            if (_selectedWallet != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'الرصيد المتاح: ${_selectedWallet!.balance.toStringAsFixed(2)} ${_selectedWallet!.currencyCode}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            TextField(
              controller: _receiverController,
              decoration: const InputDecoration(
                labelText: 'البريد أو رقم الهاتف',
                prefixIcon: Icon(Icons.person_search),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'المبلغ',
                suffixText: _selectedWallet?.currencyCode,
                prefixIcon: const Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'وصف اختياري',
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isSendingOtp ? null : _sendTransferOtp,
                icon: _isSendingOtp
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.sms),
                label: const Text('إرسال OTP للتحويل'),
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
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إرسال الآن', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}