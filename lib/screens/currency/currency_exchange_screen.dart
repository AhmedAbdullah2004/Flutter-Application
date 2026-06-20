import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'currency_history_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class CurrencyExchangeScreen extends StatefulWidget {
  const CurrencyExchangeScreen({super.key});

  @override
  State<CurrencyExchangeScreen> createState() => _CurrencyExchangeScreenState();
}

class _CurrencyExchangeScreenState extends State<CurrencyExchangeScreen> {
  final TextEditingController _amountController =
  TextEditingController(text: '100');
  final TextEditingController _otpController = TextEditingController();

  final ApiService _apiService = ApiService();

  String _fromCurrency = 'EGP';
  String _toCurrency = 'USD';

  double _rate = 0.0;
  double _convertedAmount = 0.0;

  bool _isLoadingRate = false;
  bool _isExchanging = false;

  final List<String> _currencies = [
    'EGP',
    'USD',
    'EUR',
    'GBP',
    'SAR',
    'AED',
    'JPY',
    'KWD',
  ];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculateConversion);
    _loadRate();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _loadRate() async {
    setState(() => _isLoadingRate = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final response = await _apiService.get(
        '${ApiConstants.currencyRate}?from=$_fromCurrency&to=$_toCurrency',
        token: auth.token,
      );

      final data = response['data'];

      setState(() {
        _rate = (data['rate'] as num).toDouble();
      });

      _calculateConversion();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception:', '').trim())),
      );
    }

    setState(() => _isLoadingRate = false);
  }

  void _calculateConversion() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _convertedAmount = amount * _rate;
    });
  }

  Future<void> _swapCurrencies() async {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });

    await _loadRate();
  }

  Future<void> _performExchange() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    if (auth.token == null || auth.token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول أولاً')),
      );
      return;
    }

    if (walletProvider.wallets.isEmpty) {
      await walletProvider.loadWallets(token: auth.token);
    }

    final fromWallet = walletProvider.wallets
        .where((w) => w.currencyCode == _fromCurrency)
        .toList();

    final toWallet = walletProvider.wallets
        .where((w) => w.currencyCode == _toCurrency)
        .toList();

    if (fromWallet.isEmpty || toWallet.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لازم يكون عندك محفظة للعملتين')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب مبلغ صحيح')),
      );
      return;
    }

    setState(() => _isExchanging = true);

    try {
      final response = await _apiService.post(
        ApiConstants.currencyExchange,
        token: auth.token,
        body: {
          "fromWalletId": fromWallet.first.id,
          "toWalletId": toWallet.first.id,
          "amount": amount,
          "otpCode": _otpController.text.trim(),
        },
      );

      await walletProvider.loadWallets(token: auth.token);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']?.toString() ?? 'تم تحويل العملة بنجاح'),
          backgroundColor: AppColors.success,
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

    if (mounted) setState(() => _isExchanging = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('صرف العملات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CurrencyHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'حول بين محافظك بسهولة',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'اختر العملتين وأدخل المبلغ',
              style: TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 32),

            const Text('من العملة', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildCurrencyDropdown(_fromCurrency, (val) async {
              setState(() => _fromCurrency = val!);
              await _loadRate();
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
                  child: const Icon(
                    Icons.swap_vert,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text('إلى العملة', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildCurrencyDropdown(_toCurrency, (val) async {
              setState(() => _toCurrency = val!);
              await _loadRate();
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'كود OTP',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'سعر الصرف',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingRate
                      ? const CircularProgressIndicator()
                      : Text(
                    '1 $_fromCurrency = $_rate $_toCurrency',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'المبلغ بعد التحويل',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_convertedAmount.toStringAsFixed(2)} $_toCurrency',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isExchanging ? null : _performExchange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _isExchanging
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'تحويل الآن',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: _currencies
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}