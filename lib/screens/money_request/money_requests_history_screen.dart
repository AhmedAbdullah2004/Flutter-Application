import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class MoneyRequestsHistoryScreen extends StatefulWidget {
  const MoneyRequestsHistoryScreen({super.key});

  @override
  State<MoneyRequestsHistoryScreen> createState() =>
      _MoneyRequestsHistoryScreenState();
}

class _MoneyRequestsHistoryScreenState
    extends State<MoneyRequestsHistoryScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;
  int _tabIndex = 0;

  List<Map<String, dynamic>> _sent = [];
  List<Map<String, dynamic>> _received = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadRequests);
  }

  Future<void> _loadRequests() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sentResponse = await _apiService.get(
        '/api/MoneyRequest/sent',
        token: auth.token,
      );

      final receivedResponse = await _apiService.get(
        '/api/MoneyRequest/received',
        token: auth.token,
      );

      final sentData = sentResponse['data'];
      final receivedData = receivedResponse['data'];

      setState(() {
        _sent = sentData is List
            ? sentData.map((e) => Map<String, dynamic>.from(e)).toList()
            : [];

        _received = receivedData is List
            ? receivedData.map((e) => Map<String, dynamic>.from(e)).toList()
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

  Future<void> _sendApprovalOtp() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final success = await auth.sendOtp(
      otpType: 'Transfer',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'تم إرسال OTP للموافقة'
              : auth.error ?? 'فشل إرسال OTP',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  Future<void> _respondToRequest(
      Map<String, dynamic> request,
      bool accept,
      ) async {
    final otpController = TextEditingController();

    if (accept) {
      final otp = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('قبول الطلب'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _sendApprovalOtp,
                  icon: const Icon(Icons.sms),
                  label: const Text('إرسال OTP للموافقة'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'كود OTP',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, otpController.text.trim()),
              child: const Text('قبول'),
            ),
          ],
        ),
      );

      if (otp == null || otp.isEmpty) return;

      await _sendRespond(request, true, otp);
    } else {
      await _sendRespond(request, false, '');
    }
  }

  Future<void> _sendRespond(
      Map<String, dynamic> request,
      bool accept,
      String otp,
      ) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    try {
      final response = await _apiService.put(
        '/api/MoneyRequest/respond',
        token: auth.token,
        body: {
          "requestId": request['id'],
          "accept": accept,
          "otpCode": otp,
        },
      );

      await walletProvider.loadWallets(token: auth.token);
      await _loadRequests();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']?.toString() ?? 'تم تنفيذ العملية'),
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
  }

  @override
  Widget build(BuildContext context) {
    final list = _tabIndex == 0 ? _received : _sent;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('طلبات الفلوس'),
        actions: [
          IconButton(
            onPressed: _loadRequests,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('المستلمة'),
                  icon: Icon(Icons.call_received),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('المرسلة'),
                  icon: Icon(Icons.call_made),
                ),
              ],
              selected: {_tabIndex},
              onSelectionChanged: (value) {
                setState(() => _tabIndex = value.first);
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : list.isEmpty
                ? Center(
              child: Text(
                _tabIndex == 0
                    ? 'لا توجد طلبات مستلمة'
                    : 'لا توجد طلبات مرسلة',
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildRequestCard(list[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final amount = (request['amount'] ?? 0).toDouble();
    final currency = request['currencyCode']?.toString() ?? '';
    final status = request['status']?.toString() ?? '';
    final fromName = request['fromUserName']?.toString() ?? 'مرسل';
    final toName = request['toUserName']?.toString() ?? 'مستلم';
    final date = request['createdAt']?.toString() ?? '';

    final isPending = status.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tabIndex == 0 ? 'من: $fromName' : 'إلى: $toName',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${amount.toStringAsFixed(2)} $currency',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$status - $date',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (_tabIndex == 0 && isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _respondToRequest(request, true),
                    child: const Text('قبول'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _respondToRequest(request, false),
                    child: const Text('رفض'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}