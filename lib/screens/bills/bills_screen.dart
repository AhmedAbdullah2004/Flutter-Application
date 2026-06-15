import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  final List<Map<String, dynamic>> _billers = const [
    {'name': 'كهرباء مصر', 'icon': Icons.electrical_services, 'color': Colors.orange},
    {'name': 'مياه الشرب', 'icon': Icons.water_drop, 'color': Colors.blue},
    {'name': 'WE للإنترنت', 'icon': Icons.wifi, 'color': Colors.purple},
    {'name': 'فودافون', 'icon': Icons.phone_android, 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دفع الفواتير')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _billers.length,
        itemBuilder: (context, index) {
          final biller = _billers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: biller['color'].withOpacity(0.15),
                child: Icon(biller['icon'], color: biller['color']),
              ),
              title: Text(biller['name']),
              subtitle: const Text('اضغط للدفع'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showPayDialog(context, biller['name']),
            ),
          );
        },
      ),
    );
  }

  void _showPayDialog(BuildContext context, String billerName) {
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('دفع فاتورة $billerName'),
        content: TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'المبلغ'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم دفع فاتورة $billerName بنجاح!')),
              );
            },
            child: const Text('ادفع'),
          ),
        ],
      ),
    );
  }
}