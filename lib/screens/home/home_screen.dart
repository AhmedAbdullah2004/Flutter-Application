import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../wallet/wallets_screen.dart';
import '../transfer/transfer_screen.dart';
import '../bills/bills_screen.dart';
import '../profile/profile_screen.dart';
import 'home_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboard(),
    const WalletsScreen(),
    const TransferScreen(),
    const BillsScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavItem> _navItems = [
    BottomNavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    BottomNavItem(icon: Icons.account_balance_wallet_rounded, label: 'المحافظ'),
    BottomNavItem(icon: Icons.send_rounded, label: 'تحويل'),
    BottomNavItem(icon: Icons.receipt_long_rounded, label: 'الفواتير'),
    BottomNavItem(icon: Icons.person_rounded, label: 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: _navItems.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(item.icon, size: 26),
              activeIcon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 26, color: AppColors.primary),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  BottomNavItem({required this.icon, required this.label});
}