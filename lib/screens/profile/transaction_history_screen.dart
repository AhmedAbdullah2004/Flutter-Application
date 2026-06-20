import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadHistory);
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);

      if (walletProvider.wallets.isEmpty) {
        await walletProvider.loadWallets(token: auth.token);
      }

      if (walletProvider.wallets.isEmpty) {
        setState(() {
          _transactions = [];
          _isLoading = false;
        });
        return;
      }

      final walletId = walletProvider.wallets.first.id;

      final response = await _apiService.get(
        '/api/Transfer/history/$walletId?pageNumber=1&pageSize=20',
        token: auth.token,
      );

      final data = response['data'];
      final items = data?['items'];

      if (items is List) {
        _transactions = items
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        _transactions = [];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل التحويلات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _transactions.isEmpty
          ? const Center(child: Text('لا توجد تحويلات حتى الآن'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tx = _transactions[index];

          final receiverName =
              tx['receiverName']?.toString() ?? 'مستلم';
          final amount = (tx['amount'] ?? 0).toDouble();
          final currency =
              tx['currencyCode']?.toString() ?? 'EGP';
          final status = tx['status']?.toString() ?? '';
          final date = tx['transferredAt']?.toString() ?? '';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تحويل إلى $receiverName',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$status - $date',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '-${amount.toStringAsFixed(2)} $currency',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}