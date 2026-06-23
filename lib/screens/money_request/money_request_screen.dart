import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import 'money_requests_history_screen.dart';

class MoneyRequestScreen extends StatefulWidget {
  const MoneyRequestScreen({super.key});

  @override
  State<MoneyRequestScreen> createState() => _MoneyRequestScreenState();
}

class _MoneyRequestScreenState extends State<MoneyRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneOrEmailController = TextEditingController();
  final _amountController = TextEditingController();
  final _otpController = TextEditingController();

  final ApiService _apiService = ApiService();

  String _selectedCurrency = 'EGP';
  final List<String> _currencies = ['EGP', 'USD', 'EUR', 'GBP', 'SAR'];

  bool _isLoading = false;
  bool _isSendingOtp = false;

  @override
  void dispose() {
    _phoneOrEmailController.dispose();
    _amountController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendMoneyRequestOtp() async {
    setState(() => _isSendingOtp = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final success = await auth.sendOtp(
      otpType: 'Transfer',
    );

    if (!mounted) return;

    setState(() => _isSendingOtp = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'تم إرسال OTP لطلب الفلوس' : auth.error ?? 'فشل إرسال OTP',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  Future<void> _sendRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final amount = double.tryParse(_amountController.text.trim());
    final otp = _otpController.text.trim();

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب مبلغ صحيح')),
      );
      return;
    }

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب كود OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.post(
        '/api/MoneyRequest',
        token: auth.token,
        body: {
          "toUserPhoneOrEmail": _phoneOrEmailController.text.trim(),
          "amount": amount,
          "currencyCode": _selectedCurrency,
          "otpCode": otp,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text(response['message']?.toString() ?? 'تم إرسال الطلب بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );

      _phoneOrEmailController.clear();
      _amountController.clear();
      _otpController.clear();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const MoneyRequestsHistoryScreen(),
        ),
      );
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('طلب فلوس'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MoneyRequestsHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اطلب فلوس من شخص آخر',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'أدخل البريد أو رقم الهاتف والمبلغ',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _phoneOrEmailController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف أو البريد الإلكتروني',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'مطلوب' : null,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'المبلغ'),
                      validator: (v) =>
                      v == null || v.trim().isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      decoration: const InputDecoration(labelText: 'العملة'),
                      items: _currencies
                          .map(
                            (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ),
                      )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedCurrency = v);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _isSendingOtp ? null : _sendMoneyRequestOtp,
                  icon: _isSendingOtp
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.sms),
                  label: const Text('إرسال OTP لطلب الفلوس'),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'كود OTP',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty ? 'مطلوب' : null,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendRequest,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'إرسال طلب الفلوس',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}