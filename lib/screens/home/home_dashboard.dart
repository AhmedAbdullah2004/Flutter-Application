import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../notifications/notifications_screen.dart';
import '../wallet/wallet_detail_screen.dart';
import '../wallet/wallets_screen.dart';
import '../money_request/money_requests_history_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  late AnimationController _balanceController;
  late Animation<double> _balanceAnimation;

  bool _isLoadingTransactions = false;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();

    _balanceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _balanceAnimation = CurvedAnimation(
      parent: _balanceController,
      curve: Curves.easeOutBack,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadHomeData();
      _balanceController.forward();
    });
  }

  Future<void> _loadHomeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    await authProvider.fetchUserProfile();
    await walletProvider.loadWallets(token: authProvider.token);
    await _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    setState(() => _isLoadingTransactions = true);

    final List<Map<String, dynamic>> all = [];

    try {
      for (final wallet in walletProvider.wallets) {
        try {
          final response = await _apiService.get(
            '/api/Transfer/history/${wallet.id}?pageNumber=1&pageSize=10',
            token: auth.token,
          );

          final data = response['data'];
          final items = data is Map ? data['items'] : null;

          if (items is List) {
            for (final item in items) {
              final tx = Map<String, dynamic>.from(item);
              all.add({
                'type': 'transfer',
                'title': 'تحويل أموال',
                'subtitle':
                'إلى ${tx['receiverName'] ?? tx['recipientName'] ?? tx['toUserName'] ?? tx['receiver'] ?? tx['recipient'] ?? 'مستلم'}',
                'amount': tx['amount'] ?? 0,
                'currencyCode': tx['currencyCode'] ?? wallet.currencyCode,
                'date': tx['transferredAt'] ?? tx['createdAt'] ?? '',
                'status': tx['status'] ?? '',
                'isDebit': true,
              });
            }
          }
        } catch (_) {}
      }

      try {
        final response = await _apiService.get(
          ApiConstants.billHistory,
          token: auth.token,
        );

        final data = response['data'];
        final items = data is Map ? data['items'] : data;

        if (items is List) {
          for (final item in items) {
            final bill = Map<String, dynamic>.from(item);
            all.add({
              'type': 'bill',
              'title': 'دفع فاتورة',
              'subtitle': bill['billerName'] ?? 'فاتورة',
              'amount': bill['amount'] ?? 0,
              'currencyCode': bill['currencyCode'] ?? '',
              'date': bill['createdAt'] ?? '',
              'status': bill['status'] ?? '',
              'isDebit': true,
            });
          }
        }
      } catch (_) {}

      try {
        final response = await _apiService.get(
          ApiConstants.currencyHistory,
          token: auth.token,
        );

        final data = response['data'];
        final items = data is Map ? data['items'] : data;

        if (items is List) {
          for (final item in items) {
            final ex = Map<String, dynamic>.from(item);
            all.add({
              'type': 'exchange',
              'title': 'صرف عملات',
              'subtitle':
              '${ex['fromCurrencyCode'] ?? ''} إلى ${ex['toCurrencyCode'] ?? ''}',
              'amount': ex['fromAmount'] ?? ex['amount'] ?? 0,
              'currencyCode': ex['fromCurrencyCode'] ?? '',
              'date': ex['createdAt'] ?? ex['exchangedAt'] ?? '',
              'status': ex['status'] ?? '',
              'isDebit': true,
            });
          }
        }
      } catch (_) {}

      try {
        final sentResponse = await _apiService.get(
          '/api/MoneyRequest/sent',
          token: auth.token,
        );

        final sentData = sentResponse['data'];

        if (sentData is List) {
          for (final item in sentData) {
            final req = Map<String, dynamic>.from(item);
            all.add({
              'type': 'money_request_sent',
              'title': 'طلب فلوس مرسل',
              'subtitle': 'إلى ${req['toUserName'] ?? 'مستخدم'}',
              'amount': req['amount'] ?? 0,
              'currencyCode': req['currencyCode'] ?? '',
              'date': req['createdAt'] ?? '',
              'status': req['status'] ?? '',
              'isDebit': false,
            });
          }
        }
      } catch (_) {}

      try {
        final receivedResponse = await _apiService.get(
          '/api/MoneyRequest/received',
          token: auth.token,
        );

        final receivedData = receivedResponse['data'];

        if (receivedData is List) {
          for (final item in receivedData) {
            final req = Map<String, dynamic>.from(item);
            all.add({
              'type': 'money_request_received',
              'title': 'طلب فلوس مستلم',
              'subtitle': 'من ${req['fromUserName'] ?? 'مستخدم'}',
              'amount': req['amount'] ?? 0,
              'currencyCode': req['currencyCode'] ?? '',
              'date': req['createdAt'] ?? '',
              'status': req['status'] ?? '',
              'isDebit': false,
            });
          }
        }
      } catch (_) {}

      all.sort((a, b) {
        final da = DateTime.tryParse(a['date']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final db = DateTime.tryParse(b['date']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return db.compareTo(da);
      });

      setState(() {
        _transactions = all.take(10).toList();
      });
    } catch (_) {
      setState(() => _transactions = []);
    }

    if (mounted) {
      setState(() => _isLoadingTransactions = false);
    }
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Digital Wallet',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadHomeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            Text(
            'أهلاً، ${authProvider.user?.name.split(' ').first ?? 'صديقي'} 👋',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'إليك نظرة سريعة على محافظك اليوم',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          ScaleTransition(
            scale: _balanceAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF00A844)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'أرصدة المحافظ',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 14),
                  if (walletProvider.wallets.isEmpty)
                    const Text(
                      'لا توجد محافظ',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    )
                  else
                    ...walletProvider.wallets.map(
                          (wallet) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              wallet.currencyCode,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${wallet.balance.toStringAsFixed(2)} ${wallet.currencyCode}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'إجراءات سريعة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Wrap(
            alignment: WrapAlignment.start,
            spacing: 24,
            runSpacing: 20,
            children: [
              _buildQuickAction(
                Icons.send_rounded,
                'إرسال',
                AppColors.primary,
                    () => Navigator.pushNamed(context, '/transfer'),
              ),
              _buildQuickAction(
                Icons.request_page_rounded,
                'طلب',
                AppColors.accent,
                    () => Navigator.pushNamed(context, '/money-request'),
              ),
              _buildQuickAction(
                Icons.currency_exchange_rounded,
                'صرف',
                Colors.purple,
                    () => Navigator.pushNamed(context, '/currency'),
              ),
              _buildQuickAction(
                Icons.history,
                'طلبات الفلوس',
                Colors.orange,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MoneyRequestsHistoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 32),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'محافظي',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WalletsScreen()),
                          );
                        },
                        child: const Text('الكل'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (walletProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (walletProvider.wallets.isEmpty)
                    _buildEmptyWallets()
                  else
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: walletProvider.wallets.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final wallet = walletProvider.wallets[index];
                          return _buildWalletCard(wallet);
                        },
                      ),
                    ),

                  const SizedBox(height: 32),

                  const Text(
                    'آخر العمليات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (_isLoadingTransactions)
                    const Center(child: CircularProgressIndicator())
                  else if (_transactions.isEmpty)
                    _buildNoTransactions()
                  else
                    ..._transactions.map((tx) => _buildTransactionTile(tx)),
                ],
            ),
          ),
        ),
    );
  }

  Widget _buildQuickAction(
      IconData icon,
      String label,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(dynamic wallet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WalletDetailScreen(wallet: wallet)),
        );
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(wallet.currencyCode),
            const Spacer(),
            Text(
              wallet.balance.toStringAsFixed(2),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              wallet.currencyCode,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWallets() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.wallet, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('لا توجد محافظ بعد'),
        ],
      ),
    );
  }

  Widget _buildNoTransactions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'لا توجد عمليات حتى الآن',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> tx) {
    final type = tx['type']?.toString() ?? '';
    final title = tx['title']?.toString() ?? 'عملية';
    final subtitle = tx['subtitle']?.toString() ?? '';
    final amount = (tx['amount'] ?? 0).toDouble();
    final currency = tx['currencyCode']?.toString() ?? '';
    final status = tx['status']?.toString() ?? '';
    final date = tx['date']?.toString() ?? '';
    final isDebit = tx['isDebit'] == true;

    IconData icon;
    Color color;

    switch (type) {
      case 'transfer':
        icon = Icons.arrow_upward_rounded;
        color = AppColors.error;
        break;
      case 'bill':
        icon = Icons.receipt_long_rounded;
        color = Colors.orange;
        break;
      case 'exchange':
        icon = Icons.currency_exchange_rounded;
        color = Colors.purple;
        break;
      case 'money_request_sent':
        icon = Icons.call_made_rounded;
        color = AppColors.accent;
        break;
      case 'money_request_received':
        icon = Icons.call_received_rounded;
        color = AppColors.success;
        break;
      default:
        icon = Icons.history_rounded;
        color = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '$subtitle${status.isNotEmpty ? ' - $status' : ''}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    date,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${isDebit ? '-' : '+'}${amount.toStringAsFixed(2)} $currency',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDebit ? AppColors.error : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}