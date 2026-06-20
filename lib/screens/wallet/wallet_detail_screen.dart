import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/wallet_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class WalletDetailScreen extends StatefulWidget {
  final WalletModel wallet;

  const WalletDetailScreen({super.key, required this.wallet});

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadWalletTransactions);
  }

  Future<void> _loadWalletTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      final response = await _apiService.get(
        '/api/Transfer/history/${widget.wallet.id}?pageNumber=1&pageSize=20',
        token: auth.token,
      );

      final data = response['data'];
      final items = data?['items'];

      setState(() {
        _transactions = items is List
            ? items.map((e) => Map<String, dynamic>.from(e)).toList()
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

  String _formatDate(String value) {
    if (value.isEmpty) return '';
    return value.replaceAll('T', ' ').split('.').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('محفظة ${widget.wallet.currencyCode}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWalletTransactions,
          ),
        ],
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
                    widget.wallet.balance.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.wallet.currencyCode,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'العمليات الأخيرة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text(_error!))
                  : _transactions.isEmpty
                  ? const Center(child: Text('لا توجد عمليات لهذه المحفظة'))
                  : ListView.separated(
                itemCount: _transactions.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tx = _transactions[index];

                  final amount =
                  (tx['amount'] ?? 0).toDouble();
                  final receiver =
                      tx['receiverName']?.toString() ??
                          tx['receiverPhoneOrEmail']?.toString() ??
                          'مستلم';
                  final status =
                      tx['status']?.toString() ?? '';
                  final date =
                      tx['transferredAt']?.toString() ?? '';

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFEBEE),
                        child: Icon(
                          Icons.arrow_upward,
                          color: AppColors.error,
                        ),
                      ),
                      title: Text('تحويل إلى $receiver'),
                      subtitle:
                      Text('$status - ${_formatDate(date)}'),
                      trailing: Text(
                        '-${amount.toStringAsFixed(2)} ${widget.wallet.currencyCode}',
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}