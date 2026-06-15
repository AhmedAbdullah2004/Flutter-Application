import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/constants.dart';

class CurrencyExchangeScreen extends StatefulWidget {
  const CurrencyExchangeScreen({super.key});

  @override
  State<CurrencyExchangeScreen> createState() => _CurrencyExchangeScreenState();
}

class _CurrencyExchangeScreenState extends State<CurrencyExchangeScreen> {
  final TextEditingController _amountController = TextEditingController(text: '100');

  String _fromCurrency = 'EGP';
  String _toCurrency = 'USD';
  double _convertedAmount = 0.0;

  final Map<String, double> _rates = {
    'EGP': 1.0, 'USD': 48.5, 'EUR': 52.3, 'GBP': 61.8,
    'SAR': 12.95, 'AED': 13.2, 'JPY': 0.32, 'KWD': 158.0,
  };

  final List<String> _currencies = ['EGP', 'USD', 'EUR', 'GBP', 'SAR', 'AED', 'JPY', 'KWD'];

  @override
  void initState() {
    super.initState();
    _calculateConversion();
    _amountController.addListener(_calculateConversion);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _calculateConversion() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      setState(() => _convertedAmount = 0);
      return;
    }
    final result = amount * (_rates[_toCurrency]! / _rates[_fromCurrency]!);
    setState(() => _convertedAmount = result);
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _calculateConversion();
  }

  Future<void> _performExchange() async {
    if (_convertedAmount <= 0) return;

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    final fromWallet = walletProvider.wallets.firstWhere(
      (w) => w.currencyCode == _fromCurrency,
      orElse: () => throw Exception('not found'),
    );
    final toWallet = walletProvider.wallets.firstWhere(
      (w) => w.currencyCode == _toCurrency,
      orElse: () => throw Exception('not found'),
    );

    final amount = double.parse(_amountController.text);

    if (fromWallet.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رصيد غير كافي'), backgroundColor: Colors.red),
      );
      return;
    }

    // تحديث الرصيد باستخدام الدالة الموجودة في الـ Provider
    walletProvider.updateWalletBalance(fromWallet.id, fromWallet.balance - amount);
    walletProvider.updateWalletBalance(toWallet.id, toWallet.balance + _convertedAmount);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 32),
            SizedBox(width: 12),
            Text('تم التحويل بنجاح!'),
          ],
        ),
        content: Text(
          'تم تحويل $amount $_fromCurrency إلى ${_convertedAmount.toStringAsFixed(2)} $_toCurrency بنجاح',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('صرف العملات'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('حول بين محافظك بسهولة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('اختر العملتين وأدخل المبلغ', style: TextStyle(color: AppColors.textSecondary)),

            const SizedBox(height: 32),

            const Text('من العملة', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildCurrencyDropdown(_fromCurrency, (val) {
              setState(() => _fromCurrency = val!);
              _calculateConversion();
            }),

            const SizedBox(height: 16),
            Center(
              child: InkWell(
                onTap: _swapCurrencies,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.swap_vert, color: AppColors.primary, size: 28),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text('إلى العملة', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildCurrencyDropdown(_toCurrency, (val) {
              setState(() => _toCurrency = val!);
              _calculateConversion();
            }),

            const SizedBox(height: 28),

            const Text('المبلغ', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'أدخل المبلغ',
                suffixText: _fromCurrency,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  const Text('المبلغ بعد التحويل', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(
                    '${_convertedAmount.toStringAsFixed(2)} $_toCurrency',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _convertedAmount > 0 ? _performExchange : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('تحويل الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}