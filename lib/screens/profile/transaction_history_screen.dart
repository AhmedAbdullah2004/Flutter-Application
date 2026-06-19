import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'الكل';

  final List<String> _filters = ['الكل', 'مُرسَل', 'مُستَلَم', 'فواتير', 'تحويل عملة'];

  final List<Map<String, dynamic>> _transactions = [
    {
      'type': 'مُرسَل',
      'description': 'تحويل إلى محمد أحمد',
      'amount': -500.0,
      'date': '2026-06-18',
      'currency': 'EGP',
    },
    {
      'type': 'مُستَلَم',
      'description': 'استلام من سارة علي',
      'amount': 1200.0,
      'date': '2026-06-17',
      'currency': 'EGP',
    },
    {
      'type': 'فواتير',
      'description': 'فاتورة الكهرباء',
      'amount': -350.0,
      'date': '2026-06-16',
      'currency': 'EGP',
    },
    {
      'type': 'تحويل عملة',
      'description': 'تحويل EGP إلى USD',
      'amount': -1000.0,
      'date': '2026-06-15',
      'currency': 'EGP',
    },
    {
      'type': 'مُستَلَم',
      'description': 'استلام من عمر خالد',
      'amount': 800.0,
      'date': '2026-06-14',
      'currency': 'EGP',
    },
    {
      'type': 'فواتير',
      'description': 'فاتورة الإنترنت',
      'amount': -199.0,
      'date': '2026-06-13',
      'currency': 'EGP',
    },
    {
      'type': 'مُرسَل',
      'description': 'تحويل إلى ليلى حسن',
      'amount': -300.0,
      'date': '2026-06-12',
      'currency': 'EGP',
    },
  ];

  List<Map<String, dynamic>> get _filtered => _selectedFilter == 'الكل'
      ? _transactions
      : _transactions.where((t) => t['type'] == _selectedFilter).toList();

  IconData _iconForType(String type) {
    switch (type) {
      case 'مُرسَل':
        return Icons.arrow_upward;
      case 'مُستَلَم':
        return Icons.arrow_downward;
      case 'فواتير':
        return Icons.receipt_long;
      case 'تحويل عملة':
        return Icons.currency_exchange;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'مُستَلَم':
        return AppColors.success;
      case 'مُرسَل':
        return AppColors.error;
      case 'فواتير':
        return AppColors.warning;
      case 'تحويل عملة':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل العمليات')),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final f = _filters[index];
                final selected = f == _selectedFilter;
                return ChoiceChip(
                  label: Text(f),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedFilter = f),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('لا توجد عمليات'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tx = _filtered[index];
                      final amount = tx['amount'] as double;
                      final isPositive = amount > 0;
                      final color = _colorForType(tx['type']);
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_iconForType(tx['type']), color: color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx['description'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tx['date'],
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isPositive ? '+' : ''}${amount.toStringAsFixed(0)} ${tx['currency']}',
                              style: TextStyle(
                                color: isPositive ? AppColors.success : AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}