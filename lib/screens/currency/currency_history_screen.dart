import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class CurrencyHistoryScreen extends StatefulWidget {
  const CurrencyHistoryScreen({super.key});

  @override
  State<CurrencyHistoryScreen> createState() => _CurrencyHistoryScreenState();
}

class _CurrencyHistoryScreenState extends State<CurrencyHistoryScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _items = [];

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

      final response = await _apiService.get(
        ApiConstants.currencyHistory,
        token: auth.token,
      );

      final data = response['data'];

      setState(() {
        _items = data is List
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

  String _date(String? value) {
    if (value == null || value.isEmpty) return '';
    return value.replaceAll('T', ' ').split('.').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('سجل صرف العملات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _items.isEmpty
          ? const Center(child: Text('لا يوجد سجل صرف عملات حتى الآن'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _items[index];

          final from = item['fromCurrency']?.toString() ?? '';
          final to = item['toCurrency']?.toString() ?? '';
          final amount = (item['amount'] ?? 0).toDouble();
          final converted =
          (item['convertedAmount'] ?? item['receivedAmount'] ?? 0)
              .toDouble();
          final rate = (item['rate'] ?? 0).toDouble();
          final createdAt =
              item['createdAt']?.toString() ??
                  item['exchangedAt']?.toString() ??
                  '';

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEDE7F6),
                child: Icon(
                  Icons.currency_exchange,
                  color: Colors.purple,
                ),
              ),
              title: Text('$amount $from → $converted $to'),
              subtitle: Text('Rate: $rate\n${_date(createdAt)}'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}