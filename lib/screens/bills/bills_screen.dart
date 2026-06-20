import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bill_history_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _billers = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadBillers);
  }

  Future<void> _loadBillers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final response = await _apiService.get(
        ApiConstants.billers,
        token: auth.token,
      );

      final data = response['data'];

      setState(() {
        _billers = data is List
            ? data.map((e) => Map<String, dynamic>.from(e)).toList()
            : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  Future<void> _payBill(Map<String, dynamic> biller) async {
    final amountCtrl = TextEditingController();
    final otpCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('دفع ${biller['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: otpCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'كود OTP'),
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
              Navigator.pop(ctx);

              final auth = Provider.of<AuthProvider>(context, listen: false);
              final walletProvider =
              Provider.of<WalletProvider>(context, listen: false);

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

              try {
                final response = await _apiService.post(
                  ApiConstants.billPay,
                  token: auth.token,
                  body: {
                    "walletId": walletId,
                    "billerId": biller['id'],
                    "amount": double.parse(amountCtrl.text.trim()),
                    "otpCode": otpCtrl.text.trim(),
                  },
                );

                await walletProvider.loadWallets(token: auth.token);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      response['message']?.toString() ?? 'تم دفع الفاتورة بنجاح',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      e.toString().replaceAll('Exception:', '').trim(),
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('ادفع'),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Water':
        return Icons.water_drop;
      case 'Electricity':
        return Icons.electrical_services;
      case 'Internet':
        return Icons.wifi;
      case 'Subscription':
        return Icons.subscriptions;
      default:
        return Icons.receipt_long;
    }
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'Water':
        return Colors.blue;
      case 'Electricity':
        return Colors.orange;
      case 'Internet':
        return Colors.purple;
      case 'Subscription':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفع الفواتير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BillHistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBillers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _billers.isEmpty
          ? const Center(child: Text('لا توجد فواتير'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _billers.length,
        itemBuilder: (context, index) {
          final biller = _billers[index];
          final name = biller['name']?.toString() ?? '';
          final category = biller['category']?.toString() ?? '';
          final color = _colorForCategory(category);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(
                  _iconForCategory(category),
                  color: color,
                ),
              ),
              title: Text(name),
              subtitle: Text(category),
              trailing:
              const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _payBill(biller),
            ),
          );
        },
      ),
    );
  }
}