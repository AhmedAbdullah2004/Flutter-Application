import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../wallet/wallet_detail_screen.dart';
import '../wallet/wallets_screen.dart';
import '../transfer/transfer_screen.dart';

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
      final token =
          Provider.of<AuthProvider>(context, listen: false).token;

      Provider.of<WalletProvider>(
        context,
        listen: false,
      ).loadWallets(token: token);
      _balanceController.forward();
    });
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('الإشعارات',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildNotificationItem(
                'تم استلام 250 ج.م من أحمد', 'منذ 3 ساعات', true),
            _buildNotificationItem('تم تحويل 180 يورو بنجاح', 'منذ يوم', true),
            _buildNotificationItem(
                'طلب صداقة جديد من سارة', 'منذ يومين', false),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String time, bool isRead) {
    return ListTile(
      leading: Icon(
        isRead ? Icons.check_circle : Icons.notifications_active,
        color: isRead ? AppColors.success : AppColors.primary,
      ),
      title: Text(title),
      subtitle: Text(time, style: const TextStyle(fontSize: 12)),
      trailing: isRead
          ? null
          : const Icon(Icons.circle, color: AppColors.primary, size: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet_rounded,
                color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Digital Wallet',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _showNotifications,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            walletProvider.loadWallets(token: authProvider.token),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'أهلاً، ${authProvider.user?.name.split(' ').first ?? 'صديقي'} 👋',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                'إليك نظرة سريعة على محفظتك اليوم',
                style: TextStyle(color: AppColors.textSecondary),
              ),

              const SizedBox(height: 24),

              // Total Balance Card
              ScaleTransition(
                scale: _balanceAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C853), Color(0xFF00A844)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الرصيد الإجمالي',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _balanceAnimation,
                        builder: (context, child) {
                          final total = walletProvider.totalBalance *
                              _balanceAnimation.value;
                          return Text(
                            '${total.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up,
                                color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('+12.4% هذا الشهر',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Quick Actions - الآن شغالة!
              const Text('إجراءات سريعة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickAction(
                      Icons.send_rounded, 'إرسال', AppColors.primary, () {
                    Navigator.pushNamed(context, '/transfer');
                  }),
                  _buildQuickAction(
                      Icons.request_page_rounded, 'طلب', AppColors.accent, () {
                    Navigator.pushNamed(context, '/money-request');
                  }),
                  _buildQuickAction(
                      Icons.currency_exchange_rounded, 'صرف', Colors.purple,
                      () {
                    Navigator.pushNamed(context, '/currency');
                  }),
                ],
              ),

              const SizedBox(height: 32),

              // My Wallets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('محافظي',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WalletsScreen()));
                    },
                    child: const Text('الكل',
                        style: TextStyle(color: AppColors.primary)),
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

              // Recent Transactions
              const Text('آخر العمليات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...List.generate(3, (index) => _buildTransactionTile(index)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const TransferScreen()));
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('عملية جديدة'),
      ),
    );
  }

  Widget _buildQuickAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet,
                      color: AppColors.primary, size: 22),
                ),
                const Spacer(),
                Text(
                  wallet.currencyCode,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '${wallet.balance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              wallet.currencyCode == 'EGP' ? 'جنيه مصري' : wallet.currencyCode,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWallets() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.wallet, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('لا توجد محافظ بعد'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // يمكنك ربطه بإنشاء محفظة لاحقاً
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('سيتم إضافة إنشاء محفظة جديدة قريباً')),
              );
            },
            child: const Text('أنشئ محفظة جديدة'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(int index) {
    final bool isCredit = index % 2 == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isCredit ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isCredit ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCredit ? 'استلام من أحمد' : 'تحويل إلى سارة',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Text('منذ 3 ساعات',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'} 250.00 ج.م',
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
