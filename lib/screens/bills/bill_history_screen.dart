import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class BillHistoryScreen extends StatefulWidget {
  const BillHistoryScreen({super.key});

  @override
  State<BillHistoryScreen> createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends State<BillHistoryScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _payments = [];

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
        ApiConstants.billHistory,
        token: auth.token,
      );

      final data = response['data'];

      setState(() {
        _payments = data is List
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
      appBar: AppBar(
        title: const Text('سجل الفواتير'),
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
          : _payments.isEmpty
          ? const Center(child: Text('لا توجد مدفوعات حتى الآن'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _payments.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _payments[index];

          final biller =
              item['billerName']?.toString() ?? 'فاتورة';
          final amount =
          (item['amount'] ?? 0).toDouble();
          final status =
              item['status']?.toString() ?? '';
          final createdAt =
              item['paidAt']?.toString() ??
                  item['createdAt']?.toString() ??
                  '';

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(
                  Icons.receipt_long,
                  color: Colors.green,
                ),
              ),
              title: Text(biller),
              subtitle: Text(
                '$status\n${_date(createdAt)}',
              ),
              isThreeLine: true,
              trailing: Text(
                amount.toStringAsFixed(2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}