import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/constants.dart';
import '../notifications/notifications_screen.dart';
import '../transfer/transfer_screen.dart';
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
  late AnimationController _balanceController;
  late Animation<double> _balanceAnimation;

  @override
  void initState() {
    super.initState();

    _balanceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _balanceAnimation = CurvedAnimation(
      parent: _balanceController,
      curve: Curves.easeOutBack,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      Provider.of<WalletProvider>(context, listen: false)
          .loadWallets(token: token);
      _balanceController.forward();
    });
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
            Icon(Icons.account_balance_wallet_rounded,
                color: AppColors.primary),
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
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await walletProvider.loadWallets(token: authProvider.token);
        },
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
                'إليك نظرة سريعة على محفظتك اليوم',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              ScaleTransition(
                scale: _balanceAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
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
                        'الرصيد الإجمالي',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${walletProvider.totalBalance.toStringAsFixed(2)} ج.م',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
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
                          builder: (_) =>
                          const MoneyRequestsHistoryScreen(),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WalletsScreen(),
                        ),
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
              ...List.generate(3, (index) => _buildTransactionTile(index)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransferScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('عملية جديدة'),
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
          MaterialPageRoute(
            builder: (_) => WalletDetailScreen(wallet: wallet),
          ),
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

  Widget _buildTransactionTile(int index) {
    final isCredit = index % 2 == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(isCredit ? 'استلام من أحمد' : 'تحويل إلى سارة'),
          ),
          Text(
            '${isCredit ? '+' : '-'}250.00 ج.م',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCredit ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}